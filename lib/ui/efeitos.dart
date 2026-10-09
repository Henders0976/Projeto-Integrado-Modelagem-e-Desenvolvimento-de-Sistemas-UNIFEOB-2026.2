import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'tema.dart';

/// Efeitos de movimento reutilizáveis. Todos respeitam "reduzir animações"
/// do sistema: nesse caso o conteúdo aparece direto, sem movimento.

/// Faz o filho subir e aparecer quando ele entra na tela (ao rolar ou ao abrir).
/// [atraso] escalona vários itens vizinhos.
class Revelar extends StatefulWidget {
  const Revelar({
    super.key,
    required this.child,
    this.atraso = Duration.zero,
    this.deslocamento = 32,
  });

  final Widget child;
  final Duration atraso;
  final double deslocamento;

  @override
  State<Revelar> createState() => _RevelarState();
}

class _RevelarState extends State<Revelar> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
  late final Animation<double> _curva =
      CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
  ScrollPosition? _posicao;
  bool _disparou = false;
  bool _reduzir = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduzir = MediaQuery.disableAnimationsOf(context);
    final nova = Scrollable.maybeOf(context, axis: Axis.vertical)?.position;
    if (nova != _posicao) {
      _posicao?.removeListener(_checar);
      _posicao = nova?..addListener(_checar);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _checar());
  }

  void _checar() {
    if (_disparou || !mounted) return;
    final caixa = context.findRenderObject();
    if (caixa is! RenderBox || !caixa.attached || !caixa.hasSize) return;
    final topo = caixa.localToGlobal(Offset.zero).dy;
    if (topo < MediaQuery.sizeOf(context).height * 0.93) {
      _disparou = true;
      _posicao?.removeListener(_checar);
      Future.delayed(widget.atraso, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _posicao?.removeListener(_checar);
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_reduzir) return widget.child;
    return AnimatedBuilder(
      animation: _curva,
      child: widget.child,
      builder: (_, filho) => Opacity(
        opacity: _curva.value,
        child: Transform.translate(
          offset: Offset(0, widget.deslocamento * (1 - _curva.value)),
          child: filho,
        ),
      ),
    );
  }
}

/// Faixa de texto que corre sem parar (estilo vitrine de grife).
class FaixaRolante extends StatefulWidget {
  const FaixaRolante({super.key, required this.textos, this.velocidade = 38});
  final List<String> textos;
  final double velocidade; // pixels por segundo

  @override
  State<FaixaRolante> createState() => _FaixaRolanteState();
}

class _FaixaRolanteState extends State<FaixaRolante> {
  final _rolagem = ScrollController();
  Ticker? _relogio;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _relogio?.dispose();
    _relogio = null;
    if (MediaQuery.disableAnimationsOf(context)) return;
    _relogio = Ticker((t) {
      if (_rolagem.hasClients) {
        _rolagem.jumpTo(t.inMicroseconds / 1e6 * widget.velocidade);
      }
    })..start();
  }

  @override
  void dispose() {
    _relogio?.dispose();
    _rolagem.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: Container(
          height: 64,
          decoration: const BoxDecoration(
            border: Border.symmetric(horizontal: BorderSide(color: corLinha)),
          ),
          child: ListView.builder(
            controller: _rolagem,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (_, i) => Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Row(children: [
                  Text(widget.textos[i % widget.textos.length].toUpperCase(),
                      style: const TextStyle(
                          fontFamily: fonteTitulo, fontSize: 22, letterSpacing: 3)),
                  const SizedBox(width: 56),
                  const Icon(Icons.diamond_outlined, size: 12, color: corTextoSuave),
                ]),
              ),
            ),
          ),
        ),
      );
}

/// "Pulinho" ao mudar o valor (ex.: contador da sacola).
class PulsoAoMudar extends StatelessWidget {
  const PulsoAoMudar({super.key, required this.valor, required this.child});
  final Object valor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      key: ValueKey(valor),
      tween: Tween(begin: 1.45, end: 1),
      duration: const Duration(milliseconds: 520),
      curve: Curves.elasticOut,
      child: child,
      builder: (_, v, filho) => Transform.scale(scale: v, child: filho),
    );
  }
}
