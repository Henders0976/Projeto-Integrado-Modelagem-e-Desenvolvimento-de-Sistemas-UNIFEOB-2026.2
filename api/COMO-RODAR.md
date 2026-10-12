# API e banco (uso local, não vai no README do GitHub)

## Subir
1. No MySQL Workbench, abra `schema.sql` e execute. Só cria o que falta.
2. Copie `.env.example` para `.env` e preencha `DB_USER`, `DB_PASSWORD` e `JWT_SECRET` (texto aleatório com 48+ caracteres).
3. `npm install`, depois `npm run seed` (importa o `catalogo.json`) e `npm start`.
4. Defina a senha da administradora: `npm run admin -- admin@rvlabel.com.br "uma senha com 8+ caracteres"`.
5. No app: `flutter run` (web/desktop) ou `flutter run --dart-define=API_URL=http://10.0.2.2:3000` (emulador Android). Celular físico: use o IP do PC na rede.

Se o banco `Rv_Label` já existia com as tabelas da atividade, rode `migracao.sql` uma vez.

## Rotas
Públicas: `GET /produtos`, `GET /estoque`, `POST /pedidos`, `GET /pedidos/:id?telefone=` (precisa dos dois).
Admin (Bearer token de `POST /admin/login`): `GET/POST /admin/produtos`, `PATCH /admin/produtos/:codigo`, `PUT /admin/estoque`, `GET /admin/pedidos`, `PATCH /admin/pedidos/:id`.

## Regras que valem a pena lembrar
- Estoque vazio (NULL) = sem controle; só barra o pedido quem tem número.
- Cancelar um pedido devolve o estoque e não pode ser desfeito.
- Produto nunca é apagado (pedidos antigos dependem dele): desative em vez disso.
- O login bloqueia o IP por 15 min depois de 5 erros.
- Limite conhecido: o CORS está aberto e o bloqueio de login fica em memória. Para produção, restrinja a origem e use HTTPS.

## Testes
Com a API no ar: `npm test`. Cria dados temporários e apaga no fim.
