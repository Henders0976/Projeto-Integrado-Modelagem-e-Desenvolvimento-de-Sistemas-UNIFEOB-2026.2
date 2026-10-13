import 'dart:math' as math;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

import '../models/models.dart';
import 'componentes.dart';
import 'tema.dart';

/// Vitrine em lista: os nomes das peças e uma janela com a foto de quem está sob o mouse (ou o foco, ou o último
/// toque). Tocar no nome abre a peça, e a foto da janela "voa" até a página dela.
/// No desktop a janela acompanha a rolagem enquanto a lista passa ([rolagem] avisa a posição da página); no celular
/// ela fica acima da lista.
class Vitrine extends StatefulWidget {
  const Vitrine({super.key, required this.pecas, required this.aoAbrir, required this.rolagem});

  final List<Produto> pecas;
  final void Function(Produto) aoAbrir;
  final ValueListenable<double> rolagem;

  @override
  State<Vitrine> createState() => _VitrineState();
}

class _VitrineState extends State<Vitrine> {
  String? _ativaId;

  /// Distância da janela ao topo da tela quando ela gruda (abaixo da barra do topo).
  static const _topoFixo = 112.0;

  // Sem firstWhere(orElse:): se a lista chegar como List<Peca>, o orElse devolvendo Produto quebra em tempo de execução.
  Produto get _ativa => widget.pecas.where((p) => p.id == _ativaId).firstOrNull ?? widget.pecas.first;

  Widget _janela(bool largo) {
    final ativa = _ativa;
    final reduzir = MediaQuery.disableAnimationsOf(context);
    return AspectRatio(
      aspectRatio: largo ? 4 / 5 : 4 / 3,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: const Color(0x1AFFFFFF),
          boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 40, offset: Offset(0, 16))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(fit: StackFit.expand, children: [
          for (final p in widget.pecas)
            AnimatedOpacity(
              duration: reduzir ? Duration.zero : const Duration(milliseconds: 500),
              opacity: p.id == ativa.id ? 1 : 0,
              child: fotoOuPlaceholder(p.fotos.firstOrNull,
                  variante: p.cores.first, heroTag: p.id == ativa.id ? 'foto-${p.id}' : null),
            ),
        ]),
      ),
    );
  }

  Widget _lista() {
    final ativa = _ativa;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [
        Text('NOSSAS PEÇAS', style: TextStyle(fontSize: 12, letterSpacing: 3.6, color: corTextoSuave)),
        SizedBox(width: 16),
        Expanded(child: Divider(height: 1, color: corLinha)),
      ]),
      const SizedBox(height: 20),
      for (final p in widget.pecas)
        _Linha(
          peca: p,
          ativa: p.id == ativa.id,
          aoPassar: () => setState(() => _ativaId = p.id),
          aoAbrir: () => widget.aoAbrir(p),
        ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pecas.isEmpty) return const SizedBox.shrink();
    WidgetsBinding.instance.addPostFrameCallback((_) => _medir());
    return LayoutBuilder(builder: (context, caixa) {
      if (caixa.maxWidth < 760) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _janela(false),
          const SizedBox(height: 32),
          _lista(),
        ]);
      }
      final larguraJanela = (caixa.maxWidth - 56) * 5 / 11;
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: larguraJanela,
          child: ValueListenableBuilder<double>(
            valueListenable: widget.rolagem,
            builder: (_, y, __) => Transform.translate(
              offset: Offset(0, _deslocamento(y, larguraJanela * 5 / 4)),
              child: _janela(true),
            ),
          ),
        ),
        const SizedBox(width: 56),
        Expanded(child: _lista()),
      ]);
    });
  }

  // Onde o bloco está na página (a partir do topo do conteúdo) e a altura dele, medidos depois de cada layout.
  // Medir na hora de desenhar leria o layout do quadro anterior e a janela ficaria deslocada.
  double _topoNaPagina = 0;
  double _alturaBloco = 0;

  void _medir() {
    if (!mounted) return;
    final caixa = context.findRenderObject();
    if (caixa is! RenderBox || !caixa.attached || !caixa.hasSize) return;
    final topo = caixa.localToGlobal(Offset.zero).dy + widget.rolagem.value;
    if ((topo - _topoNaPagina).abs() < 0.5 && (caixa.size.height - _alturaBloco).abs() < 0.5) return;
    setState(() {
      _topoNaPagina = topo;
      _alturaBloco = caixa.size.height;
    });
  }

  /// Quanto a janela desce para continuar à vista: acompanha a tela até acabar a lista (como o "sticky" da web).
  double _deslocamento(double rolagemY, double alturaJanela) {
    final sobra = _alturaBloco - alturaJanela;
    return math.max(0, math.min(_topoFixo - (_topoNaPagina - rolagemY), sobra));
  }
}

class _Linha extends StatelessWidget {
  const _Linha({required this.peca, required this.ativa, required this.aoPassar, required this.aoAbrir});

  final Produto peca;
  final bool ativa;
  final VoidCallback aoPassar;
  final VoidCallback aoAbrir;

  @override
  Widget build(BuildContext context) {
    final reduzir = MediaQuery.disableAnimationsOf(context);
    final tamanho = (MediaQuery.sizeOf(context).width * 0.046).clamp(28.0, 46.0);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => aoPassar(),
      child: Semantics(
        button: true,
        label: '${peca.nome}, ${peca.precoFormatado}. Abrir peça',
        excludeSemantics: true,
        child: InkWell(
          onTap: () {
            aoPassar(); // no toque (sem mouse) a janela já mostra a peça antes de abrir
            aoAbrir();
          },
          onFocusChange: (foco) {
            if (foco) aoPassar();
          },
          hoverColor: Colors.transparent,
          focusColor: Colors.white12,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: reduzir ? Duration.zero : const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontFamily: fonteTitulo,
                      fontSize: tamanho,
                      height: 1.15,
                      color: ativa ? corTexto : corTexto.withValues(alpha: 0.4),
                    ),
                    child: Text('${peca.nome}${ativa ? ' ·' : ''}'),
                  ),
                ),
                const SizedBox(width: 12),
                Text(peca.precoFormatado,
                    style: const TextStyle(
                        fontSize: 12,
                        letterSpacing: 0.5,
                        color: corTextoSuave,
                        fontFeatures: [FontFeature.tabularFigures()])),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
