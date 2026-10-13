// Aplica as migrações pendentes da pasta migracoes/, em ordem de nome, e anota cada uma na tabela schema_migracoes.
// Uso: npm run migrar   (seguro rodar de novo: o que já foi aplicado é pulado)
//
// Cada arquivo é SQL puro, sem "USE": roda no banco do .env. Um arquivo pode ter, em qualquer linha, o comentário
//   -- ja-aplicada: SELECT ...
// com uma consulta que devolve linha se a mudança já existe (banco criado pelo schema.sql atual, ou migração feita
// à mão antes desta ferramenta). Nesse caso ela só é anotada, sem rodar. Isso só importa para migrações antigas.
//
// shortcut: o MySQL não desfaz ALTER TABLE. Se uma migração falhar no meio, conserte o banco à mão e rode de novo;
// por isso cada arquivo deve ser pequeno. Para desfazer de verdade, seria preciso um arquivo de volta por migração.
const fs = require('fs');
const path = require('path');

const PASTA = path.join(__dirname, 'migracoes');

async function migrar(con, { pasta = PASTA, log = console.log } = {}) {
  await con.query(`CREATE TABLE IF NOT EXISTS schema_migracoes (
    nome        VARCHAR(120) NOT NULL PRIMARY KEY,
    aplicada_em TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
  ) ENGINE=InnoDB`);
  const [feitas] = await con.query('SELECT nome FROM schema_migracoes');
  const ja = new Set(feitas.map((r) => r.nome));

  const resultado = { aplicadas: [], puladas: [] };
  const arquivos = fs.readdirSync(pasta).filter((f) => /^\d+.*\.sql$/.test(f)).sort();
  for (const arquivo of arquivos) {
    const nome = arquivo.replace(/\.sql$/, '');
    if (ja.has(nome)) continue;
    const sql = fs.readFileSync(path.join(pasta, arquivo), 'utf8');

    const guarda = /^--\s*ja-aplicada:\s*(.+)$/m.exec(sql)?.[1];
    const [existe] = guarda ? await con.query(guarda) : [[]];
    if (existe.length) {
      log(`já estava aplicada: ${nome}`);
      resultado.puladas.push(nome);
    } else {
      log(`aplicando: ${nome}`);
      await con.query(sql);
      resultado.aplicadas.push(nome);
    }
    await con.query('INSERT INTO schema_migracoes (nome) VALUES (?)', [nome]);
  }
  if (!resultado.aplicadas.length && !resultado.puladas.length) log('nada a fazer: o banco já está em dia');
  return resultado;
}

module.exports = { migrar };

if (require.main === module) {
  require('dotenv').config();
  const mysql = require('mysql2/promise');
  (async () => {
    const con = await mysql.createConnection({
      host: process.env.DB_HOST || 'localhost',
      port: Number(process.env.DB_PORT || 3306),
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || '',
      database: process.env.DB_NAME || 'Rv_Label',
      multipleStatements: true, // só aqui: as migrações têm vários comandos, e a API não usa isto
    });
    try {
      await migrar(con);
    } finally {
      await con.end();
    }
  })().catch((e) => {
    console.error('erro:', e.code || e.message);
    process.exit(1);
  });
}
