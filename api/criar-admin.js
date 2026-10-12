// Define a senha do administrador. Uso: node criar-admin.js email@exemplo.com "senha com 8+ caracteres"
require('dotenv').config();
const db = require('./db');
const { bcrypt } = require('./auth');

(async () => {
  const [email, senha] = process.argv.slice(2);
  if (!email || !senha || senha.length < 8) {
    console.error('Uso: node criar-admin.js <email> "<senha com 8+ caracteres>"');
    process.exit(1);
  }
  const hash = await bcrypt.hash(senha, 12);
  const [r] = await db.query('UPDATE administrador SET senha = ? WHERE email = ?', [hash, email]);
  if (r.affectedRows === 0) {
    await db.query('INSERT INTO administrador (nome, email, senha) VALUES (?, ?, ?)', ['Administradora RV Label', email, hash]);
  }
  console.log('Senha do administrador definida para', email);
  await db.end();
})().catch((e) => { console.error(e.message); process.exit(1); });
