<p align="center">
  <img src="assets/icon/app_icon.png" alt="RV·LABEL" width="160">
</p>

# RV Label

App da loja de roupas **RV Label**, coleção **Essence**, feito em Flutter/Dart para Android, iOS, web e Windows.
Projeto Integrado de Modelagem e Desenvolvimento de Sistemas, UNIFEOB 2026.2.

## Baixar o app (Windows)

Pegue o `.zip` da versão mais recente em **[Releases](../../releases/latest)**.

1. **Descompacte a pasta inteira** (não abra o `.exe` de dentro do `.zip`).
2. Abra `rvlabel_app.exe`.

Funciona em Windows 10/11 de 64 bits (Intel/AMD); as bibliotecas do Visual C++ já vão no pacote. Como o app ainda não tem assinatura digital, o Windows pode avisar "O Windows protegeu o seu computador": clique em **Mais informações** e depois em **Executar assim mesmo**. No Windows edição "N", instale o *Media Feature Pack* da Microsoft.

Sem o servidor (veja [Servidor e banco](#servidor-e-banco)) o app mostra o catálogo embutido, mas não registra pedidos e a área administrativa não abre.

## O que o app faz

- **Vitrine** com a coleção Essence, filtro por categoria e página de cada peça (cor, tamanho, foto de frente e de costas).
- **Coleções**, páginas **Sobre** e **Contato** e a faixa **Novidades RV**, com navegação Loja / Sobre / Contato.
- **Sacola** e fechamento do pedido pelo **WhatsApp**. O formulário de Contato e as Novidades também seguem pelo WhatsApp.
- **Meus pedidos:** o cliente acompanha o andamento com o número do pedido e o telefone.
- **Área administrativa** com login: pedidos (com indicadores de vendas), preços, estoque, o que aparece na loja e cadastro de produtos.
- **Assistente de estilo com IA** (GenUI + Firebase AI Logic).
- **Animações ligadas à rolagem** (scroll-linked, parallax nas fotos), **rolagem suave** com a roda do mouse e fundo líquido animado (shader).
- Tela de **privacidade e termos** (LGPD).
- O catálogo tem cópia embutida em `assets/catalogo.json` e as fotos ficam em `assets/fotos/`, então o app abre mesmo sem conexão.

## Como rodar (desenvolvimento)

Requisitos: [Flutter](https://docs.flutter.dev/get-started/install) estável recente (testado com 3.47) e, para Windows, o Visual Studio com a carga "Desenvolvimento para desktop com C++".

```bash
flutter pub get
flutter run -d windows     # ou: -d chrome, ou o id de um emulador/celular
```

As pastas `android`, `ios`, `web` e `windows` já estão no repositório; não é preciso rodar `flutter create`. Use `flutter devices` para ver os dispositivos disponíveis.

Só com isso o app já abre. O Assistente de IA e a parte do servidor são opcionais e estão descritos abaixo.

## Servidor e banco

Pedidos, "Meus pedidos", o login e o painel administrativo conversam com uma API Node.js + MySQL (banco `Rv_Label`). **A pasta `api/` não faz parte deste repositório** (fica só na máquina local, como diz o `.gitignore`), e as credenciais e o `.env` nunca são versionados.

O app procura a API em `http://localhost:3000`. Para outro endereço:

```bash
flutter run -d windows --dart-define=API_URL=http://192.168.0.10:3000
# emulador Android: --dart-define=API_URL=http://10.0.2.2:3000
```

Rotas que o app usa:

| Rota | Quem usa | Para quê |
|---|---|---|
| `GET /produtos` | público | catálogo (se falhar, usa o `catalogo.json` embutido) |
| `POST /pedidos` | público | registrar o pedido |
| `GET /pedidos/:id?telefone=` | público | consultar o andamento (exige os dois dados) |
| `POST /admin/login` | admin | entrar e receber o token |
| `GET/POST /admin/produtos`, `PATCH /admin/produtos/:codigo` | admin | listar, cadastrar e alterar produtos |
| `PUT /admin/estoque` | admin | ajustar o estoque de uma variação |
| `GET /admin/pedidos`, `PATCH /admin/pedidos/:id` | admin | listar pedidos e mudar o status |

**Acesso ao painel:** não há link para clientes. Segure o clique (ou o dedo) sobre a logo **RV·LABEL** na tela inicial. Não existe cadastro público de administrador: a conta é criada direto no banco pela equipe e a senha é guardada criptografada.

## Assistente de IA (Firebase)

O Assistente usa o Firebase AI Logic. Sem configurar, o resto do app funciona normalmente e só o Assistente fica indisponível.

1. No [console do Firebase](https://console.firebase.google.com), crie um projeto e ative o **Firebase AI Logic**.
2. Instale as ferramentas e gere a configuração:
   ```bash
   npm install -g firebase-tools
   firebase login
   dart pub global activate flutterfire_cli
   flutterfire configure --platforms=android,ios,web,windows
   ```
   Isso cria o `lib/firebase_options.dart` com as suas chaves, no lugar do arquivo de exemplo.
3. No Android, baixe o `google-services.json` do console e coloque em `android/app/`, no lugar do de exemplo.
4. **App Check (debug):** gere um token qualquer (por exemplo, um GUID), cadastre-o em *App Check → Apps → cada app → Gerenciar tokens de debug* e rode com:
   ```bash
   flutter run -d windows --dart-define=APP_CHECK_DEBUG_TOKEN=<seu-token>
   ```
   Se guardar o token num arquivo, use `.appcheck-token`, que o git ignora.

As chaves do Firebase e o número real do WhatsApp **não ficam no repositório**: em `lib/firebase_options.dart` e `android/app/google-services.json` os valores estão como `COLE_SUA_...`.

## Número do WhatsApp

Em `lib/main.dart`, troque o número fictício (`5511999990000`) pelo da loja: DDI + DDD + número, só dígitos. Enquanto isso não for feito, o fechamento de pedido, o Contato e as Novidades abrem uma conversa com um número que não existe.

## Gerar o app de Windows

```bash
flutter build windows --release
```

O executável sai em `build/windows/x64/runner/Release/`. Para distribuir, leve a pasta inteira (o `.exe`, as DLLs e a pasta `data`) mais as DLLs do Visual C++ (`msvcp140.dll`, `vcruntime140.dll` e `vcruntime140_1.dll`) no mesmo diretório. O pacote pronto da última versão fica em [`release/`](release/) e nas [Releases](../../releases).

## Ícone do app

O ícone é o letreiro RV·LABEL. As imagens-base ficam em `assets/icon/`; para trocar, substitua-as e rode:

```bash
flutter pub run flutter_launcher_icons
```

## Orientação a objetos

- **Herança e polimorfismo:** `Produto` é abstrata; `Peca` e `Acessorio` herdam dela e definem `tamanhos` e `rotuloTipo`.
- **Encapsulamento:** os atributos são privados (`_nome`, `_preco`) e só mudam por get/set com validação.
- **Ocultação:** a sacola guarda os itens num mapa privado e a tela só enxerga getters e métodos.

## Estrutura do código

```
lib/
  main.dart            ponto de entrada e número do WhatsApp
  core/                moeda, indicadores de vendas, App Check
  models/              Produto, Peca, Acessorio, Categoria, VarianteCor...
  services/            API, catálogo, sacola, WhatsApp
  ui/                  telas, componentes, efeitos e rolagem suave
  ia/                  Assistente de IA
assets/                catálogo, fotos, fontes e ícone
docs/                  documentação do projeto
release/               pacote pronto do app (Windows)
test/                  testes automatizados
```

## Documentação

- [Diagrama de classes](docs/diagrama-de-classes.md): as classes do app e onde aparece cada requisito de orientação a objetos.
- [Decisões do projeto](docs/decisoes.md): o que foi escolhido e por quê.
- [Evolução futura](docs/evolucao-futura.md): o que pode vir depois.

## Testes

```bash
flutter test
```
