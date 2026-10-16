import 'package:flutter/material.dart';

import 'tema.dart';

/// Balão de mensagem do chat: cliente à direita (fundo elevado), assistente à esquerda (só borda).
class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.text, required this.isUser});
  final String text;
  final bool isUser;

  @override
  Widget build(BuildContext context) => Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: RvSpace.xs),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          constraints: const BoxConstraints(maxWidth: 520),
          decoration: BoxDecoration(
            color: isUser ? RvColors.surfaceRaised : RvColors.surface,
            border: isUser ? null : Border.all(color: RvColors.border),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(RvRadius.lg),
              topRight: const Radius.circular(RvRadius.lg),
              bottomLeft: Radius.circular(isUser ? RvRadius.lg : RvRadius.sm),
              bottomRight: Radius.circular(isUser ? RvRadius.sm : RvRadius.lg),
            ),
          ),
          child: Text(text, style: const TextStyle(color: RvColors.textPrimary)),
        ),
      );
}

/// "digitando…" com três pontos que pulsam, no lado da assistente.
class Digitando extends StatefulWidget {
  const Digitando({super.key});

  @override
  State<Digitando> createState() => _DigitandoState();
}

class _DigitandoState extends State<Digitando> with SingleTickerProviderStateMixin {
  late final _anim =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MediaQuery.disableAnimationsOf(context) ? _anim.stop() : _anim.repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
        liveRegion: true,
        label: 'Assistente digitando',
        excludeSemantics: true,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: RvSpace.xs),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: RvColors.surface,
              border: Border.all(color: RvColors.border),
              borderRadius: BorderRadius.circular(RvRadius.lg),
            ),
            child: AnimatedBuilder(
              animation: _anim,
              builder: (_, __) => Row(mainAxisSize: MainAxisSize.min, children: [
                for (var i = 0; i < 3; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Opacity(
                      // Cada ponto acende um terço de volta depois do anterior.
                      opacity: 0.3 + 0.7 * (1 - ((_anim.value * 3 - i) % 3).clamp(0.0, 1.0)),
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                            color: RvColors.textSecondary, shape: BoxShape.circle),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
        ),
      );
}
