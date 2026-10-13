# Histórico de mudanças

Segue o formato do [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/). As versões `1.x` são as do **aplicativo**
(releases do GitHub). O site e a API ainda não têm versão própria e ficam em "Não lançado".

## Não lançado

### Site (`site/`)
- Versão para site da loja, em React: vitrine, página de cada peça, sacola, "Meus pedidos", Sobre, Contato e Privacidade.
- Rolagem suave do mouse, transição de foto entre a vitrine e a peça, e "linha de tinta" animada nas opções do cabeçalho.
- Landing page com o resumo da coleção por categoria e o guia "Antes de escolher" (tamanhos, cores, preços, atendimento).
- A vitrine vem sempre do `catalogo.json`, com ou sem API: a API só devolve o que a administradora ativou, e com o catálogo
  desativado a loja ficaria vazia. A API serve ao site só para gravar e consultar pedidos.
- Sem deslocamento de layout ao carregar (CLS 0 na home e na loja), nomes acessíveis dos cartões corrigidos, `robots.txt`
  e pré-carregamento do catálogo. Lighthouse no celular: acessibilidade, boas práticas e SEO em 100.

### API (`api/`)
- API em Node + MySQL na pasta própria, sem o `.env` (a chave nunca vai para o GitHub).
- **Segurança:** a consulta "Meus pedidos" não pode mais ser enganada por um pedido com o mesmo CPF e outro telefone: o nome e
  o telefone ficam gravados no próprio pedido e o cadastro da cliente nunca é reescrito por um pedido anônimo.
- Limite de requisições por IP nas rotas públicas de pedido (erro 429), `TRUST_PROXY` para uso atrás de proxy, cabeçalhos
  seguros, `Cache-Control: no-store` em `/pedidos` e `/admin`, e limites de tamanho (nome, itens, quantidade).
- `GET /saude` para monitoramento, `npm run backup` (mysqldump com rodízio, fora do git) e `npm run migrar` (migrações
  numeradas em `migracoes/`, anotadas em `schema_migracoes`).
- A senha da administradora precisa ter 10+ caracteres e não pode conter o e-mail nem palavras comuns.
- A mensagem de peça indisponível mostra o nome da peça, não o código interno.
- A migração `001` guarda nome e telefone no pedido e tira a máscara do telefone das clientes (`(35) 99999-9999` vira
  `35999999999`); sem isso os pedidos antigos não apareciam na consulta.

### App
- O catálogo vem todo desativado: a administradora decide o que aparece no app pelo painel.

### Projeto
- CI no GitHub Actions: testes do site, da API (com MySQL) e do app em todo PR.
- `README` com a seção do site e do catálogo desativado; este `CHANGELOG`.
- O `.gitignore` da raiz deixou de ser versionado (os de `android/`, `api/`, `ios/`, `site/` e `windows/` continuam).

## 1.1.1 — 2026-10-10
- Ícone novo do aplicativo: o letreiro RV·LABEL, em Windows, Android, iOS e web.
- Pacote do app para Windows (`.zip`), com as bibliotecas do Visual C++ incluídas. Ainda sem assinatura digital.

## 1.1.0 — 2026-10-10
- O catálogo ignora uma peça com categoria desconhecida em vez de quebrar.
- Painel da administradora: mostra o motivo real do erro em vez de "Sem conexão" genérico.
- Indicadores de vendas e rolagem suave no painel.
- Loja do app com Sobre, Contato, coleções, novidades e efeitos de rolagem.

## Primeira versão do app, antes da 1.1.0 — 2026-10-09
Sem tag nem release no GitHub.
- App RV Label: loja com animações, área administrativa oculta, pedidos e assistente.
- Documentação: diagrama de classes, decisões do projeto e evolução futura.
