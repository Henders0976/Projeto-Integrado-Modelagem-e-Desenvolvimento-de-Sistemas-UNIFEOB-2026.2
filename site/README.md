# RV Label: site

Versão para site da loja **RV Label** (coleção Essence). É um projeto separado do app Flutter (`../rvlabel_app`): mesmo catálogo, mesmas fotos, mesma fonte e as mesmas cores, em React.

- **React 18 + Vite + TypeScript + Tailwind 3.** Só 5 dependências de execução.
- **Páginas:** Início, Loja (filtro por categoria; vitrine em lista com prévia da foto e transição para overlay, ou grade), Peça, Sacola, Coleções, Sobre, Contato, Novidades, Meus pedidos e Privacidade/termos.
- **Animações ligadas à rolagem** (scroll-linked, parallax nas fotos), que respeitam "reduzir movimento" do sistema.
- **Fechamento de pedido:** a sacola (guardada no navegador) vira uma mensagem de WhatsApp igual à do app. Se houver API, o pedido também é gravado no MySQL.

## Rodar

```bash
npm install
npm run sync      # copia fotos, fontes, ícones e catalogo.json do ../rvlabel_app para public/
npm run dev       # http://localhost:5173
```

`npm run sync` usa o app da pasta de cima (este site mora em `site/`, dentro do repositório do app) ou, se o site estiver solto, `../rvlabel_app`; outro caminho: `RVLABEL_APP=D:\caminho\rvlabel_app npm run sync`. Rode de novo sempre que o catálogo ou as fotos do app mudarem.

Outros comandos: `npm test` (testes), `npm run build` (gera `dist/`), `npm run preview` (serve o `dist/`).

## Configuração (`.env`, veja `.env.example`)

| Variável | Para quê | Sem ela |
|---|---|---|
| `VITE_WHATSAPP` | WhatsApp da loja (DDI + DDD + número, só dígitos) | usa um número **fictício** (`5511999990000`) |
| `VITE_API_URL` | Endereço da API (Node + MySQL) | site estático: usa o `catalogo.json`, que vem **todo desativado** (loja sem peças até alguém ligar `"ativo": true`), pedido só pelo WhatsApp e "Meus pedidos" desligado |
| `VITE_BASE` | Subpasta de hospedagem (ex.: `/rvlabel_site/`) | `/` |

Tudo isso vai para o navegador: **nunca** coloque senhas ou chaves secretas aqui.

### Com a API ligada

O site usa as mesmas rotas do app: `GET /produtos`, `POST /pedidos` e `GET /pedidos/:id?telefone=`. A API só devolve as peças que a administradora ativou no painel. Se ela estiver fora do ar, o catálogo cai no `catalogo.json` (todo desativado, então a loja aparece sem peças) e o pedido segue só pelo WhatsApp, avisando a cliente. A API precisa aceitar o endereço do site no CORS e usar HTTPS quando o site estiver em HTTPS.

## Publicar (grátis)

O resultado é um site estático (`dist/`, cerca de 2,6 MB, quase tudo fotos):

- **Cloudflare Pages ou Netlify:** build `npm run build`, pasta `dist`. O arquivo `public/_redirects` já faz os links diretos (como `/loja`) abrirem.
- **GitHub Pages:** defina `VITE_BASE=/nome-do-repositorio/` no build. Como o Pages não tem redirecionamento, copie `dist/index.html` para `dist/404.html` depois do build.

Antes de divulgar: defina `VITE_WHATSAPP` com o número real da loja.

## Estrutura

```
src/
  lib/         regras sem tela: catálogo, pedido, API, formatação, rolagem (com testes)
  context/     catálogo e sacola
  components/  cabeçalho, rodapé, cartões, efeitos de rolagem, formulário do comprador
  pages/       uma por rota
public/        catalogo.json, fotos, fontes e ícones (vêm do app por `npm run sync`)
scripts/       sync-assets.mjs
```

## Limites conhecidos

- **Novidades** e **Contato** não têm servidor de e-mail: a mensagem segue pelo WhatsApp da marca.
- **Fundo:** é um degradê em CSS, não o shader animado do app.
- **Área administrativa** não existe no site (fica só no app).
- O painel de pedidos do admin continua dependendo da API; o site só grava e consulta pedidos.
