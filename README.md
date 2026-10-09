# RV Label (Flutter/Dart)

App da loja de roupas RV Label, coleção Essence. Projeto Integrado de Modelagem e Desenvolvimento de Sistemas, UNIFEOB 2026.2.

## O que o app faz
- Vitrine com a coleção, filtro por categoria e página de cada peça (cor, tamanho, foto de frente e de costas).
- Sacola e fechamento do pedido pelo WhatsApp.
- "Meus pedidos": o cliente acompanha o andamento com o número do pedido e o telefone.
- Área administrativa com login: pedidos, preços, estoque e o que aparece na loja.
- Assistente de estilo com IA (GenUI + Firebase AI Logic).
- Fundo líquido animado e tela de privacidade e termos (LGPD).
- O catálogo tem cópia embutida em `assets/catalogo.json`, então o app abre mesmo sem conexão. Fotos em `assets/fotos/`.

## Orientação a objetos
- **Herança e polimorfismo:** `Produto` é abstrata; `Peca` e `Acessorio` herdam dela e definem `tamanhos` e `rotuloTipo`.
- **Encapsulamento:** os atributos são privados (`_nome`, `_preco`) e só mudam por get/set com validação.
- **Ocultação:** a sacola guarda os itens num mapa privado e a tela só enxerga getters e métodos.

## Como rodar
1. `flutter create . --platforms=android,ios,web`
2. `flutter pub get`
3. `flutter run`

Para o Assistente de IA: `firebase login`, `dart pub global activate flutterfire_cli`, `flutterfire configure` e ative o Firebase AI Logic no console. Sem isso o resto do app funciona normalmente.

O número do WhatsApp da marca fica em `lib/main.dart`.

## Chaves do Firebase e número do WhatsApp
As chaves do Firebase e o número real de WhatsApp não ficam neste repositório. Em `lib/firebase_options.dart` e `android/app/google-services.json` os valores estão como `COLE_SUA_...`, e o número em `lib/main.dart` é fictício.

Para usar com o seu projeto:
1. No [console do Firebase](https://console.firebase.google.com), crie um projeto e ative o Firebase AI Logic.
2. Rode `flutterfire configure`. Ele gera o `lib/firebase_options.dart` já com as suas chaves, no lugar do arquivo de exemplo.
3. No Android, baixe o `google-services.json` do console e coloque em `android/app/`, no lugar do de exemplo.
4. Em `lib/main.dart`, troque o número do WhatsApp pelo da loja (DDI + DDD + número, só dígitos).

Sem as chaves o app abre normalmente; só o Assistente de IA fica indisponível.

## Documentação
- [Diagrama de classes](docs/diagrama-de-classes.md): as classes do app e onde aparece cada requisito de orientação a objetos.
- [Decisões do projeto](docs/decisoes.md): o que foi escolhido e por quê.
- [Evolução futura](docs/evolucao-futura.md): o que pode vir depois.

## Testes
`flutter test`
