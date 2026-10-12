const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('./db');

const segredo = () => {
  const s = process.env.JWT_SECRET;
  if (!s || s.length < 32) throw new Error('Defina JWT_SECRET (32+ caracteres) no .env.');
  return s;
};

// Limite simples de tentativas de login por IP (em memória, basta para um servidor só).
const tentativas = new Map();
const JANELA_MS = 15 * 60 * 1000;
const MAX_TENTATIVAS = 5;

function bloqueado(ip) {
  const agora = Date.now();
  const lista = (tentativas.get(ip) ?? []).filter((t) => agora - t < JANELA_MS);
  tentativas.set(ip, lista);
  return lista.length >= MAX_TENTATIVAS;
}

async function login(ip, email, senha) {
  if (bloqueado(ip)) return { status: 429, erro: 'Muitas tentativas. Aguarde alguns minutos.' };
  const [[adm]] = await db.query(
    'SELECT id_admin, nome, senha FROM administrador WHERE email = ?', [String(email ?? '')]);
  // Compara mesmo sem usuário, para o tempo de resposta não revelar se o e-mail existe.
  const hash = adm?.senha?.startsWith('$2') ? adm.senha : '$2a$10$invalidinvalidinvalidinvalidinvalidinvalidinvalidinvalidi';
  const ok = await bcrypt.compare(String(senha ?? ''), hash);
  if (!adm || !ok) {
    tentativas.get(ip).push(Date.now());
    return { status: 401, erro: 'E-mail ou senha incorretos.' };
  }
  tentativas.delete(ip);
  const token = jwt.sign({ sub: adm.id_admin }, segredo(), { expiresIn: '8h' });
  return { status: 200, token, nome: adm.nome };
}

function exigirAdmin(req, res, next) {
  const m = /^Bearer (.+)$/.exec(req.headers.authorization ?? '');
  if (!m) return res.status(401).json({ erro: 'Faça login.' });
  try {
    req.admin = { id: Number(jwt.verify(m[1], segredo()).sub) };
    next();
  } catch {
    res.status(401).json({ erro: 'Sessão expirada. Entre de novo.' });
  }
}

module.exports = { login, exigirAdmin, bcrypt };
