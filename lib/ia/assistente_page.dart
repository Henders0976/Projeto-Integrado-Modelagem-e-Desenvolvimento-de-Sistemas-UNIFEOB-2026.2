import 'dart:async';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:genui/genui.dart' hide TextPart;
import 'package:genui/genui.dart' as genui;

import '../services/catalogo_repository.dart';
import '../services/sacola.dart';
import '../ui/componentes.dart';
import '../ui/fundo_liquido.dart';
import '../ui/message_bubble.dart';
import '../ui/rolagem_suave.dart';
import '../ui/tema.dart';
import 'catalogo_pecas.dart';
import 'instrucoes.dart';

/// Modelo do codelab; troque se ele não estiver disponível no seu projeto.
const _modelo = 'gemini-3.5-flash';

sealed class _ItemConversa {}

class _Texto extends _ItemConversa {
  _Texto(this.texto, {this.doUsuario = false});
  final String texto;
  final bool doUsuario;
}

class _Superficie extends _ItemConversa {
  _Superficie(this.id);
  final String id;
}

/// Chat com a assistente de estilo, usando Firebase AI Logic + GenUI.
class AssistentePage extends StatefulWidget {
  const AssistentePage({super.key, required this.catalogo, required this.sacola});
  final CatalogoRepository catalogo;
  final Sacola sacola;

  @override
  State<AssistentePage> createState() => _AssistentePageState();
}

class _AssistentePageState extends State<AssistentePage> {
  final _itens = <_ItemConversa>[];
  final _texto = TextEditingController();
  final _rolagem = ControladorSuave();

  late final ChatSession _chat;
  late final SurfaceController _controller;
  late final A2uiTransportAdapter _transport;
  late final Conversation _conversa;
  StreamSubscription<dynamic>? _eventos;

  @override
  void initState() {
    super.initState();
    _chat = FirebaseAI.googleAI().generativeModel(model: _modelo).startChat();

    final catalogo = BasicCatalogItems.asCatalog().copyWith(newItems: [
      criarItemPecasSugeridas(catalogo: widget.catalogo, sacola: widget.sacola),
    ]);
    _controller = SurfaceController(catalogs: [catalogo]);
    _transport = A2uiTransportAdapter(onSend: _enviarEReceber);
    _conversa = Conversation(controller: _controller, transport: _transport);

    _eventos = _conversa.events.listen((evento) {
      if (!mounted) return;
      setState(() {
        switch (evento) {
          case ConversationSurfaceAdded added:
            _itens.add(_Superficie(added.surfaceId));
            _rolarParaOFim();
          case ConversationSurfaceRemoved removed:
            _itens.removeWhere(
                (i) => i is _Superficie && i.id == removed.surfaceId);
          case ConversationContentReceived conteudo:
            _itens.add(_Texto(conteudo.text));
            _rolarParaOFim();
          case ConversationError erro:
            debugPrint('GenUI error: ${erro.error}');
          default:
        }
      });
    });

    final prompt = PromptBuilder.chat(
      catalog: catalogo,
      systemPromptFragments: [instrucaoSistema(widget.catalogo)],
    );
    _conversa.sendRequest(ChatMessage.system(prompt.systemPromptJoined()));
  }

  /// Ponte GenUI -> Gemini (Firebase AI Logic) -> GenUI.
  Future<void> _enviarEReceber(ChatMessage msg) async {
    final buffer = StringBuffer();
    for (final parte in msg.parts) {
      if (parte.isUiInteractionPart) {
        buffer.write(parte.asUiInteractionPart!.interaction);
      } else if (parte is genui.TextPart) {
        buffer.write(parte.text);
      }
    }
    if (buffer.isEmpty) return;
    final resposta = await _chat.sendMessage(Content.text(buffer.toString()));
    if (resposta.text?.isNotEmpty ?? false) _transport.addChunk(resposta.text!);
  }

  /// Envia o que está no campo, ou a [sugestao] tocada.
  Future<void> _enviar([String? sugestao]) async {
    final texto = sugestao ?? _texto.text;
    if (texto.trim().isEmpty) return;
    if (sugestao == null) _texto.clear();
    setState(() => _itens.add(_Texto(texto, doUsuario: true)));
    _rolarParaOFim();
    await _conversa.sendRequest(ChatMessage.user(texto));
  }

  void _rolarParaOFim() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_rolagem.hasClients) {
          _rolagem.animateTo(_rolagem.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
        }
      });

  @override
  void dispose() {
    _eventos?.cancel();
    _texto.dispose();
    _rolagem.dispose();
    super.dispose();
  }

  static const _sugestoes = ['Look para casamento', 'Algo casual', 'Combina com vermelho?'];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Assistente RV')),
        body: FundoLiquido(
          child: ValueListenableBuilder<ConversationState>(
            valueListenable: _conversa.state,
            builder: (context, estado, _) {
              final jaPerguntou = _itens.any((i) => i is _Texto && i.doUsuario);
              return Column(children: [
                Expanded(
                  child: ListView(
                    controller: _rolagem,
                    padding: const EdgeInsets.all(RvSpace.lg),
                    children: [
                      if (_itens.isEmpty)
                        const MessageBubble(
                            text: 'Oi! Me conta o que você procura '
                                '(ex.: "um look pra jantar") e eu separo peças pra você.',
                            isUser: false),
                      for (final item in _itens)
                        switch (item) {
                          _Texto() =>
                            MessageBubble(text: item.texto, isUser: item.doUsuario),
                          _Superficie() => Surface(
                              surfaceContext: _controller.contextFor(item.id)),
                        },
                      if (estado.isWaiting && jaPerguntou) const Digitando(),
                    ],
                  ),
                ),
                if (!jaPerguntou)
                  SizedBox(
                    height: 52,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: RvSpace.lg),
                      children: [
                        for (final s in _sugestoes)
                          Padding(
                            padding: const EdgeInsets.only(right: RvSpace.sm),
                            child: PilulaEscolha(
                              rotulo: s,
                              selecionada: false,
                              aoTocar: () {
                                if (!estado.isWaiting) _enviar(s);
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        RvSpace.lg, RvSpace.sm, RvSpace.lg, RvSpace.md),
                    child: Row(children: [
                      Expanded(
                        child: TextField(
                          controller: _texto,
                          onSubmitted: estado.isWaiting ? null : (_) => _enviar(),
                          decoration:
                              const InputDecoration(hintText: 'Digite sua mensagem'),
                        ),
                      ),
                      const SizedBox(width: RvSpace.sm),
                      IconButton.filled(
                        tooltip: 'Enviar',
                        icon: const Icon(Icons.arrow_upward),
                        onPressed: estado.isWaiting ? null : _enviar,
                      ),
                    ]),
                  ),
                ),
              ]);
            },
          ),
        ),
      );
}
