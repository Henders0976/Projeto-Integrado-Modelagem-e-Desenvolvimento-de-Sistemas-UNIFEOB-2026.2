// Regras mínimas para a senha do painel da administradora. Devolve o motivo da recusa, ou null se a senha serve.
// Fraca = fácil de adivinhar por quem só conhece o e-mail e o nome da loja.
const COMUNS = ['123456', 'qwerty', 'abcdef', 'senha', 'password', 'rvlabel', 'essence', 'admin'];

function motivoSenhaFraca(senha, email = '') {
  const s = String(senha ?? '');
  const minusculas = s.toLowerCase();
  const usuario = String(email).split('@')[0].toLowerCase();
  if (s.length < 10) return 'Use 10 caracteres ou mais.';
  if (usuario.length >= 3 && minusculas.includes(usuario)) return 'A senha não pode conter o seu e-mail.';
  if (COMUNS.some((c) => minusculas.includes(c))) return 'Evite palavras e sequências comuns (senha, 123456, rvlabel...).';
  if (new Set(minusculas).size < 5) return 'Misture mais caracteres diferentes.';
  if (!/[a-z]/i.test(s) || !/[^a-z]/i.test(s)) return 'Misture letras com números ou símbolos.';
  return null;
}

module.exports = { motivoSenhaFraca };
