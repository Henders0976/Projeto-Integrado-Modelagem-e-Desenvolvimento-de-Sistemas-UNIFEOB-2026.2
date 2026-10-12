# Decisões do projeto

Aqui estão as escolhas que moldaram o app da RV Label e o motivo de cada uma, para quem for ler o código ou continuar o projeto depois.

## O pedido fecha no WhatsApp

A loja é pequena e vende conversando, então o app não cobra nada. O cliente monta a sacola, informa nome e telefone e o WhatsApp abre com a lista pronta. O app tenta registrar o pedido antes disso. Se não conseguir (sem conexão, por exemplo), avisa e segue só pelo WhatsApp, para a venda não travar por causa de um problema técnico. Se o registro recusar o pedido por uma regra, como falta de estoque, o app para e mostra o motivo.

## Uma foto, várias cores

Cada peça tem uma foto original, e as outras cores são o mesmo arquivo com um filtro de cor por cima. Para lançar uma cor nova basta uma linha de descrição no catálogo. A troca tem limite: o resultado fica bom em peças lisas e perde fidelidade em estampas. Quando uma cor precisar de foto própria, o produto aceita uma foto de frente e de costas por cor.

## O catálogo tem cópia dentro do app

O app carrega o catálogo da fonte principal e, se ela estiver fora do ar, usa uma cópia que vai junto com o aplicativo. A vitrine abre sempre. A desvantagem é que produtos criados depois só aparecem para o cliente quando o app é reaberto.

## Preço a definir e estoque sem controle

Uma peça pode ficar sem preço e aparece como "Preço a definir". O pedido segue com o aviso de que esse item será combinado. O estoque funciona do mesmo jeito: se a loja não informa a quantidade, o app não barra a compra. A quantidade só passa a valer quando a dona da loja a preenche.

## Produtos saem de cena, não são apagados

Um produto desativado some da vitrine, mas continua existindo. Pedidos antigos dependem dele, e apagar quebraria o histórico.

## Área da administradora escondida

Clientes não veem nenhum link para a administração. Quem sabe o gesto abre: segurar o dedo (ou o clique) sobre a logo "RV·LABEL" na tela inicial. A tela pede e-mail e senha, e não existe cadastro público de administrador, o acesso é criado direto pela equipe. O login tem limite de tentativas, e a sessão acaba quando o app fecha. Nessa área a administradora vê pedidos e muda o andamento, ajusta preço e estoque, tira peças da vitrine e cadastra produtos novos.

## Consulta de pedido com número e telefone

Em "Meus pedidos" o cliente precisa informar o número do pedido e o telefone usado nele. Só com um dos dois não aparece nada, assim ninguém espia o pedido de outra pessoa. A tela de privacidade e termos explica quais dados são guardados e quais são os direitos do titular, conforme a LGPD.

## Orientação a objetos como estrutura

`Produto` é abstrata, `Peca` e `Acessorio` herdam dela, os dados ficam privados e as mudanças passam por validação. A escolha cumpre os requisitos da disciplina e também protege o app de dados inválidos, como preço negativo. O diagrama está em [diagrama-de-classes.md](diagrama-de-classes.md).

## Interface animada sem pacotes extras

O fundo líquido, o efeito de rolagem, a barra de vidro e as entradas de seção usam só recursos do Flutter. Menos dependências deixam o app mais leve e mais fácil de atualizar. Quem ativa "reduzir movimento" no aparelho recebe a mesma interface sem as animações.

## Assistente de estilo é opcional

O assistente usa GenUI e o Firebase. Se o Firebase não estiver configurado, o app abre normalmente e o assistente aparece como indisponível. Por isso o repositório não traz chaves reais, e o README explica como colocar as suas.

## Catálogo desativado por padrão

O catálogo (`assets/catalogo.json`) fica no repositório com todas as peças em `"ativo": false`. A administradora tem o controle total da loja do app: só aparece lá o que ela ativa no painel. O `seed.js` grava `ativo = 0` ao importar e nunca mexe em quem já existe, para não desfazer a escolha dela.

Consequência aceita: sem a API (fora do ar ou ainda não configurada), o app abre com a vitrine vazia, em vez de mostrar o catálogo embutido por cima da decisão da administradora. As fotos das peças desativadas continuam disponíveis no formulário de novo produto.

O site **não** segue essa regra: ele ignora o campo `ativo` e mostra o catálogo inteiro do `catalogo.json`. Só quando o site usa a API é que ele mostra o que a administradora ativou.

## Segredos fora do repositório

O número de WhatsApp da loja e as chaves do Firebase ficam só na máquina de quem roda o app. No repositório entram valores de exemplo.
