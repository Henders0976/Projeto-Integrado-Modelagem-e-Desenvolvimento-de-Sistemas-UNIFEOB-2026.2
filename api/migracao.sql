-- Migração do banco da atividade (rv_label_estrutura.sql) para o schema do app.
-- Rodar UMA vez em um banco Rv_Label que já tenha as tabelas da atividade.
-- Não apaga linhas: só acrescenta colunas e aceita NULL onde o app precisa.
-- Os produtos que já estavam lá (dados de demonstração) ficam inativos e o app não os lista.
USE Rv_Label;

ALTER TABLE produto
  ADD COLUMN codigo   VARCHAR(40) NULL AFTER id_produto,
  ADD COLUMN tipo     ENUM('peca','acessorio') NOT NULL DEFAULT 'peca' AFTER codigo,
  ADD COLUMN material VARCHAR(80) NULL,
  ADD COLUMN ativo    TINYINT(1)  NOT NULL DEFAULT 1,
  MODIFY preco DECIMAL(10,2) NULL;
UPDATE produto SET codigo = CONCAT('demo-', id_produto), ativo = 0;
ALTER TABLE produto
  MODIFY codigo VARCHAR(40) NOT NULL,
  ADD CONSTRAINT uq_produto_codigo UNIQUE (codigo);

ALTER TABLE produto_cor
  MODIFY foto_costas VARCHAR(255) NULL,
  ADD COLUMN hue   DOUBLE  NULL,
  ADD COLUMN tom   CHAR(7) NULL,
  ADD COLUMN ordem INT NOT NULL DEFAULT 0;

ALTER TABLE variacao MODIFY quantidade_estoque INT NULL;

ALTER TABLE cliente
  MODIFY endereco VARCHAR(255) NULL,
  ADD COLUMN cpf       CHAR(11) NULL,
  ADD COLUMN criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ADD CONSTRAINT uq_cliente_cpf UNIQUE (cpf);

ALTER TABLE pedido ADD COLUMN preco_pendente TINYINT(1) NOT NULL DEFAULT 0;

ALTER TABLE item_pedido
  MODIFY preco_unitario DECIMAL(10,2) NULL,
  MODIFY subtotal DECIMAL(10,2) NULL;
