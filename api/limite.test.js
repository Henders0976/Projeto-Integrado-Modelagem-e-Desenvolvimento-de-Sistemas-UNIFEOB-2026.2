// Teste sem banco nem servidor: npm run test:unit
const test = require('node:test');
const assert = require('node:assert/strict');
const { criarLimite } = require('./limite');

// Resposta e requisição de mentira, só com o que o limite usa.
const chama = (limite, ip) => {
  const res = { cabecalhos: {}, status(c) { this.codigo = c; return this; }, json(c) { this.corpo = c; return this; }, set(k, v) { this.cabecalhos[k] = v; } };
  let passou = false;
  limite({ ip }, res, () => { passou = true; });
  return { passou, res };
};

test('deixa passar até o máximo e barra a requisição seguinte com 429 e Retry-After', () => {
  const agora = 1_000_000;
  const limite = criarLimite({ janelaMs: 60_000, max: 3, relogio: () => agora });
  for (let i = 0; i < 3; i++) assert.equal(chama(limite, '1.1.1.1').passou, true);
  const barrada = chama(limite, '1.1.1.1');
  assert.equal(barrada.passou, false);
  assert.equal(barrada.res.codigo, 429);
  assert.equal(barrada.res.cabecalhos['Retry-After'], '60');
});

test('cada IP tem o seu limite', () => {
  const limite = criarLimite({ janelaMs: 60_000, max: 1, relogio: () => 1 });
  assert.equal(chama(limite, '1.1.1.1').passou, true);
  assert.equal(chama(limite, '1.1.1.1').passou, false);
  assert.equal(chama(limite, '2.2.2.2').passou, true);
});

test('libera de novo quando a janela passa', () => {
  let agora = 0;
  const limite = criarLimite({ janelaMs: 60_000, max: 1, relogio: () => agora });
  assert.equal(chama(limite, '1.1.1.1').passou, true);
  agora = 59_999;
  assert.equal(chama(limite, '1.1.1.1').passou, false);
  agora = 60_000;
  assert.equal(chama(limite, '1.1.1.1').passou, true);
});

test('requisição barrada não prolonga o bloqueio', () => {
  let agora = 0;
  const limite = criarLimite({ janelaMs: 60_000, max: 1, relogio: () => agora });
  chama(limite, '1.1.1.1');
  agora = 30_000;
  chama(limite, '1.1.1.1'); // barrada: não entra na contagem
  agora = 60_000;
  assert.equal(chama(limite, '1.1.1.1').passou, true);
});
