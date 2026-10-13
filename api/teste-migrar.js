// Teste da ferramenta de migração. Precisa só do MySQL (sem a API no ar): npm run test:migrar
// Cria um banco temporário (rv_teste_migrar_*), usa nele o schema.sql e apaga o banco no fim.
require('dotenv').config();
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('fs');
const path = require('path');
const mysql = require('mysql2/promise');
const { migrar } = require('./migrar');

// Cria e apaga um banco: não deixa rodar contra um servidor que não seja local.
const local = (h) => ['localhost', '127.0.0.1', '[::1]', '::1'].includes(h);
if (!local(process.env.DB_HOST || 'localhost') && process.env.TESTE_EM_BANCO_REMOTO !== 'sim') {
  console.error('Recusado: o teste cria e apaga um banco e o MySQL não é local. Se for de propósito, rode com TESTE_EM_BANCO_REMOTO=sim.');
  process.exit(1);
}

const BANCO = `rv_teste_migrar_${process.pid}`;
const silencio = () => {};
let con;

test.before(async () => {
  con = await mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    port: Number(process.env.DB_PORT || 3306),
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    multipleStatements: true,
  });
  await con.query(fs.readFileSync(path.join(__dirname, 'schema.sql'), 'utf8').replaceAll('Rv_Label', BANCO));
  await con.query(`USE \`${BANCO}\``);
});
test.after(async () => {
  await con.query(`DROP DATABASE IF EXISTS \`${BANCO}\``);
  await con.end();
});

test('banco criado pelo schema.sql atual: a 001 é só anotada, e rodar de novo não faz nada', async () => {
  assert.deepEqual(await migrar(con, { log: silencio }), { aplicadas: [], puladas: ['001-pedido-contato'] });
  assert.deepEqual(await migrar(con, { log: silencio }), { aplicadas: [], puladas: [] });
});

test('banco antigo (sem as colunas, telefone com máscara): aplica, tira a máscara e copia para o pedido', async () => {
  await con.query('ALTER TABLE pedido DROP COLUMN nome_comprador, DROP COLUMN telefone');
  await con.query('DELETE FROM schema_migracoes');
  await con.query("INSERT INTO cliente (nome, telefone) VALUES ('Fulana', '(35) 99999-0000')");
  await con.query('INSERT INTO pedido (id_cliente) SELECT id_cliente FROM cliente');

  assert.deepEqual(await migrar(con, { log: silencio }), { aplicadas: ['001-pedido-contato'], puladas: [] });

  const [[pedido]] = await con.query('SELECT nome_comprador, telefone FROM pedido');
  assert.deepEqual({ ...pedido }, { nome_comprador: 'Fulana', telefone: '35999990000' });
  const [[cliente]] = await con.query('SELECT telefone FROM cliente');
  assert.equal(cliente.telefone, '35999990000');
  const [[coluna]] = await con.query(
    "SELECT IS_NULLABLE AS n FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'pedido' AND COLUMN_NAME = 'telefone'");
  assert.equal(coluna.n, 'NO');
  assert.deepEqual(await migrar(con, { log: silencio }), { aplicadas: [], puladas: [] });
});
