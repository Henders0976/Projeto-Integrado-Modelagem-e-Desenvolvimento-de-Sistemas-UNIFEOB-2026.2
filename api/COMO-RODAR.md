# API e banco (uso local, não vai no README do GitHub)

## Subir
1. No MySQL Workbench, abra `schema.sql` e execute. Só cria o que falta.
2. Copie `.env.example` para `.env` e preencha `DB_USER`, `DB_PASSWORD` e `JWT_SECRET` (texto aleatório com 48+ caracteres).
3. `npm install`, depois `npm run seed` (importa o `catalogo.json` **todo desativado**: a loja fica vazia até a administradora ativar as peças no painel) e `npm start`.
4. Defina a senha da administradora: `npm run admin -- admin@rvlabel.com.br "uma senha com 10+ caracteres"`. A senha é recusada se for curta, contiver o e-mail, a marca ou sequências como `123456`, ou tiver só letras ou só números.
5. No app: `flutter run` (web/desktop) ou `flutter run --dart-define=API_URL=http://10.0.2.2:3000` (emulador Android). Celular físico: use o IP do PC na rede.

Se o banco `Rv_Label` já existia com as tabelas da atividade, rode `migracao.sql` uma vez.

**Mudanças no banco (migrações):** depois de atualizar o código, rode `npm run migrar` **antes** de subir a API. Ele aplica, em ordem, os arquivos novos de `migracoes/` e anota cada um na tabela `schema_migracoes`; rodar de novo não faz nada. Banco novo, criado com o `schema.sql` atual, só anota as migrações antigas sem rodá-las. Para criar uma migração nova, acrescente `migracoes/002-o-que-faz.sql` com SQL puro (sem `USE`); o MySQL não desfaz `ALTER TABLE`, então faça backup antes (`npm run backup`) e mantenha cada arquivo pequeno. A `001` guarda nome e telefone no próprio pedido e tira a máscara do telefone das clientes; sem ela o `POST /pedidos` dá erro.

**O `.env` nunca vai para o GitHub.** Ele tem a senha do banco e a chave do JWT e já está no `.gitignore`. O repositório só tem o `.env.example`, com valores de exemplo.

## Rotas
Públicas: `GET /produtos`, `GET /estoque`, `POST /pedidos`, `GET /pedidos/:id?telefone=` (precisa dos dois) e `GET /saude` (200 se a API alcança o banco, 503 se não; use no monitor de disponibilidade da hospedagem).
Admin (Bearer token de `POST /admin/login`): `GET/POST /admin/produtos`, `PATCH /admin/produtos/:codigo`, `PUT /admin/estoque`, `GET /admin/pedidos`, `PATCH /admin/pedidos/:id`.

## Regras que valem a pena lembrar
- Estoque vazio (NULL) = sem controle; só barra o pedido quem tem número.
- Cancelar um pedido devolve o estoque e não pode ser desfeito.
- Produto nunca é apagado (pedidos antigos dependem dele): desative em vez disso.
- O login bloqueia o IP por 15 min depois de 5 erros.
- A consulta `GET /pedidos/:id?telefone=` compara com o telefone gravado no pedido. Um pedido novo nunca reescreve o cadastro de uma cliente que já existe (mesmo CPF ou telefone).
- CORS: defina `CORS_ORIGIN` no `.env` com o endereço do site (ex.: `https://meusite.com`; vários, separados por vírgula). Sem isso a API fica aberta para qualquer site em desenvolvimento, e com `NODE_ENV=production` fica fechada para navegadores.
- Limites por IP: `POST /pedidos` aceita 20 pedidos a cada 10 minutos, `GET /pedidos/:id` aceita 30 consultas a cada 10 minutos (depois, erro 429 com `Retry-After`), e o login bloqueia após 5 erros. Um pedido aceita no máximo 50 itens, até 99 peças por item, e o nome até 120 caracteres.
- Atrás de um proxy ou hospedagem (Render, Railway, Nginx...), defina `TRUST_PROXY=1` (quantos proxies ficam entre o cliente e a API). Sem isso todos os visitantes aparecem com o IP do proxy e dividem o mesmo limite; com um valor maior que o real, o cliente consegue forjar o IP e fugir dos limites. Use HTTPS.
- Limite conhecido: os contadores (limites e bloqueio de login) ficam em memória, zeram ao reiniciar e não são compartilhados entre servidores. Com mais de um servidor, troque por um contador compartilhado (Redis, por exemplo).
- `/pedidos` e `/admin` respondem com `Cache-Control: no-store`: têm dado pessoal.

## Backup
`npm run backup` gera `backups/Rv_Label-AAAA-MM-DD-HH-MM.sql` com o `mysqldump` e guarda os 14 mais recentes (`BACKUP_MANTER` muda isso). Se o programa não estiver no PATH, defina `MYSQLDUMP` com o caminho dele. A pasta `backups/` está no `.gitignore`: tem telefone e CPF das clientes e **nunca** vai para o GitHub. Agende o comando todo dia (cron ou Agendador de Tarefas) e copie a pasta para fora da máquina. Para restaurar: `mysql -u root -p Rv_Label < backups/arquivo.sql`.

## Testes
- Sem banco: `npm run test:unit` (limite de requisições e regra de senha).
- Só com o MySQL: `npm run test:migrar` (cria um banco temporário `rv_teste_migrar_*` e apaga no fim).
- Com a API no ar: `npm test`. Cria dados temporários e apaga no fim.

Os dois últimos **recusam rodar** se o banco do `.env` ou a API não forem locais (`localhost`); nunca aponte para o banco de produção.
