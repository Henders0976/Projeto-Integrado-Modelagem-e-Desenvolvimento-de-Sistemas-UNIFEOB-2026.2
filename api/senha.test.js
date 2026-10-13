// Teste sem banco nem servidor: npm run test:unit
const test = require('node:test');
const assert = require('node:assert/strict');
const { motivoSenhaFraca } = require('./senha');

const EMAIL = 'dona@rvlabel.com.br';

test('aceita senha longa, com letras e números, sem palavra comum', () => {
  assert.equal(motivoSenhaFraca('Tec1do-Azul-93', EMAIL), null);
  assert.equal(motivoSenhaFraca('cafe com leite 2026!', EMAIL), null);
});

test('recusa senha curta', () => {
  assert.match(motivoSenhaFraca('Abc123!x', EMAIL), /10 caracteres/);
});

test('recusa a que contém o e-mail, a marca ou sequências comuns', () => {
  assert.match(motivoSenhaFraca('dona-da-loja-9', EMAIL), /e-mail/);
  assert.match(motivoSenhaFraca('RvLabel2026!!', EMAIL), /comuns/);
  assert.match(motivoSenhaFraca('minha-senha-77x', EMAIL), /comuns/);
  assert.match(motivoSenhaFraca('x123456789y', 'ana@x.com'), /comuns/);
});

test('recusa repetição e senha só de letras ou só de números', () => {
  assert.match(motivoSenhaFraca('aaaaaabbbbbb', EMAIL), /diferentes/);
  assert.match(motivoSenhaFraca('florzinhaazul', EMAIL), /letras com números/);
  assert.match(motivoSenhaFraca('4829173650', EMAIL), /letras com números/);
});

test('valor ausente não quebra', () => {
  assert.match(motivoSenhaFraca(undefined, EMAIL), /10 caracteres/);
});
