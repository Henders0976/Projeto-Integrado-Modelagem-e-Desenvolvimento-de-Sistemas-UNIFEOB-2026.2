import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'tema.dart';

/// Fundo com ondas de líquido que reagem ao mouse/toque.
/// Degradê vermelho -> preto com ondas de luz e sombra por cima.
/// Se o shader não carregar, mostra a cor lisa (o app segue normal).
class FundoLiquido extends StatefulWidget {
  const FundoLiquido({
    super.key,
    required this.child,
    this.corBase = corVermelho,
    this.corSombra = corPreto,
  });

  final Widget child;
  final Color corBase;
  final Color corSombra;

  @override
  State<FundoLiquido> createState() => _FundoLiquidoState();
}

/// Uma "gota" (origem de onda). Classe privada e mutável, reaproveitada.
class _Gota {
  double x = 0, y = 0, nascimento = 0, forca = 0;
}

class _FundoLiquidoState extends State<FundoLiquido>
    with SingleTickerProviderStateMixin {
  static const _maxGotas = 12;
  static const _duracaoOnda = 4.6; // s, depois disso o ticker para

  final _gotas = List.generate(_maxGotas, (_) => _Gota());
  final _relogio = Stopwatch()..start();
  final _tempo = ValueNotifier<double>(0);
  late final Ticker _ticker;
  ui.FragmentProgram? _programa;
  Offset? _ultimaPosicao;
  double _ultimoEvento = 0;
  int _proxima = 0;

  double get _segundos => _relogio.elapsedMicroseconds / 1e6;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      _tempo.value = _segundos;
      if (_segundos - _ultimoEvento > _duracaoOnda) _ticker.stop(); // economiza bateria
    });
    ui.FragmentProgram.fromAsset('shaders/liquido.frag').then((p) {
      if (mounted) setState(() => _programa = p);
    }).catchError((Object e) {
      debugPrint('Shader do fundo indisponível: $e');
    });
  }

  void _marcar(Offset pos, double forca) {
    final anterior = _ultimaPosicao;
    if (anterior != null && forca < 1.5 && (pos - anterior).distance < 14) return;
    _ultimaPosicao = pos;
    final g = _gotas[_proxima];
    _proxima = (_proxima + 1) % _maxGotas;
    g
      ..x = pos.dx
      ..y = pos.dy
      ..nascimento = _segundos
      ..forca = forca;
    _ultimoEvento = _segundos;
    if (!_ticker.isActive) _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _tempo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Listener(
        behavior: HitTestBehavior.translucent, // não atrapalha rolagem nem cliques
        onPointerHover: (e) => _marcar(e.localPosition, 1),
        onPointerMove: (e) => _marcar(e.localPosition, 1),
        onPointerDown: (e) => _marcar(e.localPosition, 1.6),
        child: Stack(
          fit: StackFit.expand,
          children: [
            RepaintBoundary(
              child: CustomPaint(
                painter: _PintorLiquido(
                  programa: _programa,
                  tempo: _tempo,
                  gotas: _gotas,
                  base: widget.corBase,
                  sombra: widget.corSombra,
                ),
              ),
            ),
            widget.child,
          ],
        ),
      );
}

class _PintorLiquido extends CustomPainter {
  _PintorLiquido({
    required this.programa,
    required this.tempo,
    required this.gotas,
    required this.base,
    required this.sombra,
  }) : super(repaint: tempo);

  final ui.FragmentProgram? programa;
  final ValueNotifier<double> tempo;
  final List<_Gota> gotas;
  final Color base;
  final Color sombra;

  @override
  void paint(Canvas canvas, Size size) {
    final area = Offset.zero & size;
    final p = programa;
    if (p == null) {
      canvas.drawRect(
          area,
          Paint()
            ..shader = ui.Gradient.linear(area.topCenter, area.bottomCenter,
                [base, Color.lerp(base, sombra, 0.9)!], [0.25, 1.0]));
      return;
    }
    final s = p.fragmentShader();
    var i = 0;
    s
      ..setFloat(i++, size.width)
      ..setFloat(i++, size.height)
      ..setFloat(i++, tempo.value)
      ..setFloat(i++, base.r)
      ..setFloat(i++, base.g)
      ..setFloat(i++, base.b)
      ..setFloat(i++, sombra.r)
      ..setFloat(i++, sombra.g)
      ..setFloat(i++, sombra.b);
    for (final g in gotas) {
      s
        ..setFloat(i++, g.x)
        ..setFloat(i++, g.y)
        ..setFloat(i++, g.nascimento)
        ..setFloat(i++, g.forca);
    }
    canvas.drawRect(area, Paint()..shader = s);
  }

  @override
  bool shouldRepaint(_PintorLiquido old) =>
      old.programa != programa || old.base != base || old.sombra != sombra;
}
