-- Guarda o nome e o telefone informados no próprio pedido.
-- Por quê: a consulta "Meus pedidos" autoriza pelo telefone, e antes ela lia o telefone da cliente, que um pedido
-- anônimo com o mesmo CPF conseguia trocar. Agora o telefone do pedido não muda depois de gravado.
--
-- Rodar UMA vez, num banco que já tenha as tabelas (schema.sql de uma versão anterior). Não apaga linhas;
-- só tira a máscara do telefone das clientes ("(35) 99999-9999" vira "35999999999").
-- Banco novo, criado com o schema.sql atual? Não precisa rodar.
-- Se rodar duas vezes o MySQL avisa que a coluna já existe e para: nada é estragado.
USE Rv_Label;

ALTER TABLE pedido
  ADD COLUMN nome_comprador VARCHAR(120) NULL AFTER id_cliente,
  ADD COLUMN telefone       VARCHAR(20)  NULL AFTER nome_comprador;

-- A API grava e compara o telefone só com dígitos. Cadastros antigos com máscara, como "(35) 99999-9999", nunca
-- bateriam com a consulta, então a máscara sai antes de o telefone ser copiado para o pedido.
UPDATE cliente
SET telefone = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(telefone, ' ', ''), '(', ''), ')', ''), '-', ''), '+', ''), '.', '');

-- Pedidos antigos ficam com os dados que a cliente tem hoje (é o que a consulta já usava).
UPDATE pedido pe JOIN cliente cl ON cl.id_cliente = pe.id_cliente
SET pe.nome_comprador = cl.nome, pe.telefone = cl.telefone;

ALTER TABLE pedido
  MODIFY nome_comprador VARCHAR(120) NOT NULL,
  MODIFY telefone       VARCHAR(20)  NOT NULL;
