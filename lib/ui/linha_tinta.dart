import 'package:flutter/material.dart';

import 'tema.dart';

/// "Linha de tinta" do cabeçalho: uma só linha fina que desliza até a opção sob o mouse ou o teclado e some ao sair.
/// Envolva a barra com [TintaNav] e cada opção com [ItemTinta]. Quando a linha ainda não estava visível, ela aparece
/// no lugar da opção (sem viajar desde a anterior); depois, de uma opção para outra, ela desliza.
class TintaNav extends StatefulWidget {
  const TintaNav({super.key, required this.child});

  final Widget child;

  @override
  State<TintaNav> createState() => _TintaNavState();
}

class _TintaNavState extends State<TintaNav> {
  BuildContext? _alvo;
  double _x = 0, _y = 0, _largura = 1;
  bool _visivel = false;
  bool _deslizar = false;

  void escolher(BuildContext item, double recuo) {
    _alvo = item;
    WidgetsBinding.instance
      ..addPostFrameCallback((_) => _medir(item, recuo))
      ..scheduleFrame(); // o callback sozinho não pede quadro: sem isto a linha esperaria a próxima atualização
  }

  void largar(BuildContext item) {
    if (_alvo != item) return; // já escolheram outra: a linha vai para ela, não some
    _alvo = null;
    // Depois do quadro: pode vir do dispose de uma opção, quando a árvore ainda está sendo desmontada.
    WidgetsBinding.instance
      ..addPostFrameCallback((_) {
        if (mounted && _alvo == null) setState(() => _visivel = false);
      })
      ..scheduleFrame();
  }

  void _medir(BuildContext item, double recuo) {
    if (!mounted || _alvo != item || !item.mounted) return;
    final nav = context.findRenderObject();
    final caixa = item.findRenderObject();
    if (nav is! RenderBox || caixa is! RenderBox || !caixa.attached || !caixa.hasSize) return;
    final canto = caixa.localToGlobal(Offset.zero, ancestor: nav);
    setState(() {
      _deslizar = _visivel;
      _x = canto.dx + recuo;
      _largura = (caixa.size.width - 2 * recuo).clamp(1.0, double.infinity);
      _y = canto.dy + caixa.size.height / 2 + 16; // logo abaixo do texto ou do ícone
      _visivel = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final reduzir = MediaQuery.disableAnimationsOf(context);
    return _EscopoTinta(
      estado: this,
      child: Stack(clipBehavior: Clip.none, children: [
        widget.child,
        AnimatedPositioned(
          duration: reduzir || !_deslizar ? Duration.zero : const Duration(milliseconds: 380),
          curve: const Cubic(0.22, 1, 0.36, 1),
          left: _x,
          top: _y,
          width: _largura,
          child: IgnorePointer(
            child: AnimatedOpacity(
              duration: reduzir ? Duration.zero : const Duration(milliseconds: 200),
              opacity: _visivel ? 1 : 0,
              child: const SizedBox(key: Key('linha-tinta'), height: 2, child: ColoredBox(color: corTexto)),
            ),
          ),
        ),
      ]),
    );
  }
}

class _EscopoTinta extends InheritedWidget {
  const _EscopoTinta({required this.estado, required super.child});

  final _TintaNavState estado;

  @override
  bool updateShouldNotify(_EscopoTinta antigo) => false;
}

/// Uma opção da barra: avisa o [TintaNav] quando o mouse passa ou o teclado chega nela.
/// [recuo] encurta a linha dos dois lados (o respiro do botão), para ela cobrir só o texto ou o ícone.
class ItemTinta extends StatefulWidget {
  const ItemTinta({super.key, required this.child, this.recuo = 12});

  final Widget child;
  final double recuo;

  @override
  State<ItemTinta> createState() => _ItemTintaState();
}

class _ItemTintaState extends State<ItemTinta> {
  bool _mouse = false;
  bool _teclado = false;
  _TintaNavState? _nav;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _nav = context.getInheritedWidgetOfExactType<_EscopoTinta>()?.estado;
  }

  @override
  void dispose() {
    if (_mouse || _teclado) _nav?.largar(context);
    super.dispose();
  }

  void _atualizar() {
    if (_mouse || _teclado) {
      _nav?.escolher(context, widget.recuo);
    } else {
      _nav?.largar(context);
    }
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
        onEnter: (_) {
          _mouse = true;
          _atualizar();
        },
        onExit: (_) {
          _mouse = false;
          _atualizar();
        },
        // Só o foco de teclado conta: clicar com o mouse também foca o botão e deixaria a linha parada nele.
        child: Focus(
          canRequestFocus: false,
          skipTraversal: true,
          onFocusChange: (foco) {
            _teclado = foco && FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
            _atualizar();
          },
          child: widget.child,
        ),
      );
}
