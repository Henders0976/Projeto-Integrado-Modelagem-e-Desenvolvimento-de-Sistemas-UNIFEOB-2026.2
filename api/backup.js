// Backup do banco com o mysqldump do MySQL, em api/backups/ (fora do git: tem telefone e CPF das clientes).
// Uso: npm run backup. Guarda os BACKUP_MANTER mais recentes (padrão 14) e apaga só os mais velhos deste mesmo banco.
// MYSQLDUMP = caminho do programa, se ele não estiver no PATH (no Windows: "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqldump.exe").
// Para rodar todo dia, agende este comando no servidor (cron no Linux, Agendador de Tarefas no Windows) e copie a pasta
// backups/ para fora da máquina: um backup que fica só no mesmo disco do banco não protege de perder o disco.
require('dotenv').config();
const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

const pasta = path.join(__dirname, 'backups');
const banco = process.env.DB_NAME || 'Rv_Label';
const manter = Math.max(1, parseInt(process.env.BACKUP_MANTER ?? '14', 10) || 14);
const carimbo = new Date().toISOString().slice(0, 16).replace(/[T:]/g, '-'); // 2026-10-12-15-30 (UTC)
const arquivo = path.join(pasta, `${banco}-${carimbo}.sql`);

fs.mkdirSync(pasta, { recursive: true });

const dump = spawn(
  process.env.MYSQLDUMP || 'mysqldump',
  [
    '--host', process.env.DB_HOST || 'localhost',
    '--port', String(process.env.DB_PORT || 3306),
    '--user', process.env.DB_USER || 'root',
    '--single-transaction', '--routines', '--no-tablespaces', '--default-character-set=utf8mb4',
    '--result-file', arquivo,
    banco,
  ],
  { env: { ...process.env, MYSQL_PWD: process.env.DB_PASSWORD || '' }, stdio: ['ignore', 'inherit', 'inherit'] }, // a senha não vai na linha de comando
);

dump.on('error', (e) => {
  console.error(`Não consegui rodar o mysqldump (${e.code}). Defina MYSQLDUMP com o caminho do programa.`);
  process.exit(1);
});

dump.on('close', (codigo) => {
  if (codigo !== 0) {
    fs.rmSync(arquivo, { force: true }); // não deixa um arquivo incompleto passando por backup bom
    console.error(`mysqldump falhou (código ${codigo}). Nenhum backup foi guardado.`);
    process.exit(1);
  }
  try {
    fs.chmodSync(arquivo, 0o600); // só o dono lê (não tem efeito no Windows)
  } catch { /* sem suporte a permissões: segue */ }
  console.log(`Backup guardado: ${arquivo}`);

  const meus = new RegExp(`^${banco.replace(/[^\w]/g, '\\$&')}-\\d{4}-\\d\\d-\\d\\d-\\d\\d-\\d\\d\\.sql$`);
  const antigos = fs.readdirSync(pasta).filter((f) => meus.test(f)).sort().reverse().slice(manter);
  for (const f of antigos) fs.rmSync(path.join(pasta, f));
  if (antigos.length) console.log(`Apagados ${antigos.length} backup(s) mais antigo(s); ficam os ${manter} mais recentes.`);
});
