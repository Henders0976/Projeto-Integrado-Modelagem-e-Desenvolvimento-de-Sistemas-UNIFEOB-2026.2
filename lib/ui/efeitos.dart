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

/// Animação ligada à rolagem (scroll-linked): o progresso acompanha a posição do
/// filho na tela, nos dois sentidos, em vez de disparar uma vez como o [Revelar].
/// O [builder] recebe [entrada] (0 = entrando por baixo, 1 = já na metade de cima)
/// e [centro] (-1 = acima do meio da tela, 0 = no meio, 1 = abaixo).
class ScrollLigado extends StatefulWidget {
  const ScrollLigado({super.key, required this.builder, this.child});

  final Widget Function(BuildContext context, double entrada, double centro, Widget? child)
      builder;
  final Widget? child;

  @override
  State<ScrollLigado> createState() => _ScrollLigadoState();
}

class _ScrollLigadoState extends State<ScrollLigado> {
  ScrollPosition? _posicao;
  double _entrada = 0;
  double _centro = 1;
  bool _reduzir = false;
  // Última medida real (após o layout): topo e altura do filho e a rolagem naquele momento.
  double? _refTopo;
  double _refAltura = 0;
  double _refPixels = 0;
  bool _agendado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduzir = MediaQuery.disableAnimationsOf(context);
    final nova = Scrollable.maybeOf(context, axis: Axis.vertical)?.position;
    if (nova != _posicao) {
      _posicao?.removeListener(_aoRolar);
      _posicao = nova?..addListener(_aoRolar);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _medir());
  }

  /// Ao rolar, o layout ainda não andou: a posição nova sai da medida anterior
  /// menos o quanto a rolagem mudou (sem atraso de um frame). Depois do frame,
  /// mede de novo para corrigir qualquer desvio.
  void _aoRolar() {
    final topo = _refTopo;
    if (topo != null && _posicao != null) {
      _aplicar(topo - (_posicao!.pixels - _refPixels));
    }
    if (_agendado) return;
    _agendado = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _agendado = false;
      _medir();
    });
  }

  void _medir() {
    if (!mounted) return;
    final caixa = context.findRenderObject();
    if (caixa is! RenderBox || !caixa.attached || !caixa.hasSize) return;
    _refTopo = caixa.localToGlobal(Offset.zero).dy;
    _refAltura = caixa.size.height;
    _refPixels = _posicao?.pixels ?? 0;
    _aplicar(_refTopo!);
  }

  void _aplicar(double topo) {
    final h = MediaQuery.sizeOf(context).height;
    final entrada = ((h * 0.95 - topo) / (h * 0.45)).clamp(0.0, 1.0);
    final centro = ((topo + _refAltura / 2 - h / 2) / h).clamp(-1.0, 1.0);
    if (entrada == _entrada && centro == _centro) return;
    setState(() {
      _entrada = entrada;
      _centro = centro;
    });
  }

  @override
  void dispose() {
    _posicao?.removeListener(_aoRolar);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _reduzir
      ? widget.builder(context, 1, 0, widget.child)
      : widget.builder(context, _entrada, _centro, widget.child);
}

/// O filho vem de [deslocamento] (padrão: de baixo), aparece e cresce conforme
/// entra na tela, e desfaz o movimento se a pessoa rolar de volta (versão ligada
/// à rolagem do [Revelar]). [escalonar] (0 a 0.5) atrasa a entrada deste item em
/// relação aos vizinhos, para uma fileira entrar em sequência.
class AoRolar extends StatelessWidget {
  const AoRolar({
    super.key,
    required this.child,
    this.deslocamento = const Offset(0, 64),
    this.escalonar = 0,
  });

  final Widget child;
  final Offset deslocamento;
  final double escalonar;

  @override
  Widget build(BuildContext context) => ScrollLigado(
        child: child,
        builder: (_, entrada, __, filho) {
          final t = Curves.easeOutCubic
              .transform(((entrada - escalonar) / (1 - escalonar)).clamp(0.0, 1.0));
          return Opacity(
            opacity: t,
            child: Transform.translate(
              offset: deslocamento * (1 - t),
              child: Transform.scale(scale: 0.9 + 0.1 * t, child: filho),
            ),
          );
        },
      );
}

/// Foto com parallax ligado à rolagem: anda mais devagar que o resto da página.
/// O pai precisa recortar (ClipRRect/ClipRect ou o próprio Stack) porque a foto
/// é ampliada em [escala] e desliza até [intensidade] pixels para cada lado.
class ParallaxFoto extends StatelessWidget {
  const ParallaxFoto({
    super.key,
    required this.child,
    this.intensidade = 20,
    this.escala = 1.15,
  });

  final Widget child;
  final double intensidade;
  final double escala;

  @override
  Widget build(BuildContext context) => ScrollLigado(
        child: child,
        builder: (_, __, centro, filho) => Transform.translate(
          offset: Offset(0, centro * -intensidade),
          child: Transform.scale(scale: escala, child: filho),
        ),
      );
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
