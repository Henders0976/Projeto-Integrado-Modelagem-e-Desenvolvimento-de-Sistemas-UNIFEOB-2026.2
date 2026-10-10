import 'package:flutter/material.dart';

/// Rolagem animada para a roda do mouse. Sem isto o Flutter pula a distância
/// inteira de cada "clique" da roda de uma vez (rolagem seca no web e no desktop).
/// Aqui cada clique vira um alvo: os cliques seguidos se somam e a tela desliza
/// até ele com desaceleração.
class ControladorSuave extends ScrollController {
  ControladorSuave({super.initialScrollOffset});

  @override
  ScrollPosition createScrollPosition(ScrollPhysics physics,
          ScrollContext context, ScrollPosition? oldPosition) =>
      _PosicaoSuave(
        physics: physics,
        context: context,
        initialPixels: initialScrollOffset,
        oldPosition: oldPosition,
        debugLabel: debugLabel,
      );
}

class _PosicaoSuave extends ScrollPositionWithSingleContext {
  _PosicaoSuave({
    required super.physics,
    required super.context,
    super.initialPixels,
    super.oldPosition,
    super.debugLabel,
  });

  double? _alvo; // para onde a animação em curso está indo

  @override
  void pointerScroll(double delta) {
    if (delta == 0) {
      goBallistic(0);
      return;
    }
    final alvo = ((_alvo ?? pixels) + delta).clamp(minScrollExtent, maxScrollExtent);
    _alvo = alvo;
    animateTo(alvo, duration: const Duration(milliseconds: 480), curve: Curves.easeOutCubic)
        .then((_) {
      if (_alvo == alvo) _alvo = null; // só limpa se nenhum clique novo chegou
    });
  }
}

/// [ListView] simples com [ControladorSuave]: troca direta onde só se usa
/// `children` e `padding`.
class ListaSuave extends StatefulWidget {
  const ListaSuave({super.key, required this.children, this.padding});

  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  @override
  State<ListaSuave> createState() => _ListaSuaveState();
}

class _ListaSuaveState extends State<ListaSuave> {
  final _controlador = ControladorSuave();

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView(
        controller: _controlador,
        padding: widget.padding,
        children: widget.children,
      );
}
