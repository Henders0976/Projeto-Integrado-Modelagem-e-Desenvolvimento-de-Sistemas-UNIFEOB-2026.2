# API e banco (uso local, não vai no README do GitHub)

## Subir
1. No MySQL Workbench, abra `schema.sql` e execute. Só cria o que falta.
2. Copie `.env.example` para `.env` e preencha `DB_USER`, `DB_PASSWORD` e `JWT_SECRET` (texto aleatório com 48+ caracteres).
3. `npm install`, depois `npm run seed` (importa o `catalogo.json` **todo desativado**: a loja fica vazia até a administradora ativar as peças no painel) e `npm start`.
4. Defina a senha da administradora: `npm run admin -- admin@rvlabel.com.br "uma senha com 8+ caracteres"`.
5. No app: `flutter run` (web/desktop) ou `flutter run --dart-define=API_URL=http://10.0.2.2:3000` (emulador Android). Celular físico: use o IP do PC na rede.

Se o banco `Rv_Label` já existia com as tabelas da atividade, rode `migracao.sql` uma vez.

**Banco criado antes desta versão** (com um `schema.sql` anterior): rode `migracao-pedido-contato.sql` uma vez no MySQL Workbench, **antes** de subir a API. Ela guarda nome e telefone no próprio pedido e preenche os pedidos antigos; sem ela o `POST /pedidos` dá erro. Banco novo, criado com o `schema.sql` atual, não precisa.

**O `.env` nunca vai para o GitHub.** Ele tem a senha do banco e a chave do JWT e já está no `.gitignore`. O repositório só tem o `.env.example`, com valores de exemplo.

## Rotas
Públicas: `GET /produtos`, `GET /estoque`, `POST /pedidos`, `GET /pedidos/:id?telefone=` (precisa dos dois).
Admin (Bearer token de `POST /admin/login`): `GET/POST /admin/produtos`, `PATCH /admin/produtos/:codigo`, `PUT /admin/estoque`, `GET /admin/pedidos`, `PATCH /admin/pedidos/:id`.

## Regras que valem a pena lembrar
- Estoque vazio (NULL) = sem controle; só barra o pedido quem tem número.
- Cancelar um pedido devolve o estoque e não pode ser desfeito.
- Produto nunca é apagado (pedidos antigos dependem dele): desative em vez disso.
- O login bloqueia o IP por 15 min depois de 5 erros.
- A consulta `GET /pedidos/:id?telefone=` compara com o telefone gravado no pedido. Um pedido novo nunca reescreve o cadastro de uma cliente que já existe (mesmo CPF ou telefone).
- CORS: defina `CORS_ORIGIN` no `.env` com o endereço do site (ex.: `https://meusite.com`; vários, separados por vírgula). Sem isso a API fica aberta para qualquer site em desenvolvimento, e com `NODE_ENV=production` fica fechada para navegadores.
- Limite conhecido: o bloqueio de login fica em memória (zera ao reiniciar e não é compartilhado entre servidores) e conta pelo IP que o Express enxerga; atrás de um proxy/hospedagem todos os visitantes podem aparecer com o mesmo IP. Ao hospedar, configure `app.set('trust proxy', ...)` e use HTTPS.

## Testes
Com a API no ar: `npm test`. Cria dados temporários e apaga no fim. Por isso o teste **recusa rodar** se o banco do `.env` ou a API não forem locais (`localhost`); nunca aponte para o banco de produção.
