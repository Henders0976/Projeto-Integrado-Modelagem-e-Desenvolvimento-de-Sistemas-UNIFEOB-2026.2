-- Schema do banco Rv_Label, no modelo lógico da atividade (Rv_Label.mwb).
-- Só cria o que ainda não existe (não apaga nada).
-- Rodar no MySQL Workbench: File > Open SQL Script > Execute (raio). Precisa de MySQL 8.
--
-- Diferenças em relação ao modelo do Workbench, todas por causa do app:
--   produto.codigo            id de texto do catálogo (ex.: essence-001)
--   produto.preco             aceita NULL ("preço a definir")
--   produto_cor.foto_costas   aceita NULL (acessórios e alguns vestidos não têm)
--   produto_cor.hue / tom     como a cor é aplicada na foto
--   variacao.quantidade_estoque  NULL = peça sem controle de estoque
--   cliente.cpf               opcional; cliente.endereco aceita NULL
--   pedido.preco_pendente     o pedido tem item sem preço
CREATE DATABASE IF NOT EXISTS Rv_Label CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE Rv_Label;

CREATE TABLE IF NOT EXISTS administrador (
  id_admin INT          NOT NULL AUTO_INCREMENT,
  nome     VARCHAR(120) NOT NULL,
  email    VARCHAR(150) NOT NULL,
  senha    VARCHAR(255) NOT NULL,           -- hash, nunca a senha pura
  CONSTRAINT pk_administrador PRIMARY KEY (id_admin),
  CONSTRAINT uq_administrador_email UNIQUE (email)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS cor (
  id_cor INT         NOT NULL AUTO_INCREMENT,
  nome   VARCHAR(40) NOT NULL,
  CONSTRAINT pk_cor PRIMARY KEY (id_cor),
  CONSTRAINT uq_cor_nome UNIQUE (nome)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tamanho (
  id_tamanho INT         NOT NULL AUTO_INCREMENT,
  nome       VARCHAR(10) NOT NULL,          -- P, M, G, GG, Único
  CONSTRAINT pk_tamanho PRIMARY KEY (id_tamanho),
  CONSTRAINT uq_tamanho_nome UNIQUE (nome)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS cliente (
  id_cliente INT          NOT NULL AUTO_INCREMENT,
  nome       VARCHAR(120) NOT NULL,
  telefone   VARCHAR(20)  NOT NULL,         -- o app grava só dígitos
  cpf        CHAR(11)     NULL,             -- opcional, só dígitos
  endereco   VARCHAR(255) NULL,
  criado_em  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_cliente PRIMARY KEY (id_cliente),
  CONSTRAINT uq_cliente_cpf UNIQUE (cpf)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS categoria (
  id_categoria INT         NOT NULL AUTO_INCREMENT,
  nome         VARCHAR(60) NOT NULL,        -- mesmo texto usado em catalogo.json
  id_admin     INT         NOT NULL,
  CONSTRAINT pk_categoria PRIMARY KEY (id_categoria),
  CONSTRAINT uq_categoria_nome UNIQUE (nome),
  CONSTRAINT fk_categoria_admin FOREIGN KEY (id_admin)
    REFERENCES administrador (id_admin) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS produto (
  id_produto   INT           NOT NULL AUTO_INCREMENT,
  codigo       VARCHAR(40)   NOT NULL,      -- id que o app enxerga
  tipo         ENUM('peca','acessorio') NOT NULL DEFAULT 'peca',
  nome         VARCHAR(120)  NOT NULL,
  descricao    VARCHAR(500)  NULL,
  preco        DECIMAL(10,2) NULL,          -- NULL = "Preço a definir"
  material     VARCHAR(80)   NULL,          -- acessórios
  ativo        TINYINT(1)    NOT NULL DEFAULT 1,
  id_categoria INT           NOT NULL,
  id_admin     INT           NOT NULL,
  CONSTRAINT pk_produto PRIMARY KEY (id_produto),
  CONSTRAINT uq_produto_codigo UNIQUE (codigo),
  CONSTRAINT ck_produto_preco CHECK (preco >= 0),
  CONSTRAINT fk_produto_categoria FOREIGN KEY (id_categoria)
    REFERENCES categoria (id_categoria) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_produto_admin FOREIGN KEY (id_admin)
    REFERENCES administrador (id_admin) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Cada cor de um produto tem as suas fotos.
CREATE TABLE IF NOT EXISTS produto_cor (
  id_produto  INT          NOT NULL,
  id_cor      INT          NOT NULL,
  foto_frente VARCHAR(255) NOT NULL,
  foto_costas VARCHAR(255) NULL,
  hue         DOUBLE       NULL,
  tom         CHAR(7)      NULL,            -- '#RRGGBB'
  ordem       INT          NOT NULL DEFAULT 0,  -- a primeira é a cor da foto original
  CONSTRAINT pk_produto_cor PRIMARY KEY (id_produto, id_cor),
  CONSTRAINT fk_produtocor_produto FOREIGN KEY (id_produto)
    REFERENCES produto (id_produto) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_produtocor_cor FOREIGN KEY (id_cor)
    REFERENCES cor (id_cor) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- O SKU (produto + cor + tamanho) e o seu estoque.
CREATE TABLE IF NOT EXISTS variacao (
  id_produto         INT NOT NULL,
  id_cor             INT NOT NULL,
  id_tamanho         INT NOT NULL,
  quantidade_estoque INT NULL,              -- NULL = sem controle (pedido nunca é barrado)
  CONSTRAINT pk_variacao PRIMARY KEY (id_produto, id_cor, id_tamanho),
  CONSTRAINT ck_variacao_estoque CHECK (quantidade_estoque >= 0),
  CONSTRAINT fk_variacao_produtocor FOREIGN KEY (id_produto, id_cor)
    REFERENCES produto_cor (id_produto, id_cor) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_variacao_tamanho FOREIGN KEY (id_tamanho)
    REFERENCES tamanho (id_tamanho) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS pedido (
  id_pedido      INT           NOT NULL AUTO_INCREMENT,
  id_cliente     INT           NOT NULL,
  data_pedido    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status         ENUM('Recebido','Em separação','Enviado','Cancelado') NOT NULL DEFAULT 'Recebido',
  valor_total    DECIMAL(10,2) NOT NULL DEFAULT 0,
  preco_pendente TINYINT(1)    NOT NULL DEFAULT 0,  -- tem item "a combinar"
  CONSTRAINT pk_pedido PRIMARY KEY (id_pedido),
  CONSTRAINT ck_pedido_total CHECK (valor_total >= 0),
  CONSTRAINT fk_pedido_cliente FOREIGN KEY (id_cliente)
    REFERENCES cliente (id_cliente) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS item_pedido (
  id_item        INT           NOT NULL AUTO_INCREMENT,
  id_pedido      INT           NOT NULL,
  id_produto     INT           NOT NULL,
  id_cor         INT           NOT NULL,
  id_tamanho     INT           NOT NULL,
  quantidade     INT           NOT NULL,
  preco_unitario DECIMAL(10,2) NULL,        -- preço na hora da compra; NULL = a combinar
  subtotal       DECIMAL(10,2) NULL,
  CONSTRAINT pk_item_pedido PRIMARY KEY (id_item),
  CONSTRAINT ck_item_quantidade CHECK (quantidade > 0),
  CONSTRAINT ck_item_preco CHECK (preco_unitario >= 0),
  CONSTRAINT ck_item_subtotal CHECK (subtotal = quantidade * preco_unitario),
  CONSTRAINT fk_item_pedido FOREIGN KEY (id_pedido)
    REFERENCES pedido (id_pedido) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_item_variacao FOREIGN KEY (id_produto, id_cor, id_tamanho)
    REFERENCES variacao (id_produto, id_cor, id_tamanho) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Tabelas do modelo antigo do app (produtos, estoque, compradores...) ficam intactas.
-- Quando não precisar mais delas, descomente para apagar:
-- DROP TABLE IF EXISTS pedido_itens, pedidos, compradores, estoque,
--                      produto_tamanhos, produto_cores, produto_fotos, produtos;
