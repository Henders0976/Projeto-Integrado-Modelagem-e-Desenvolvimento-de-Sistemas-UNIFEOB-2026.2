import 'package:flutter/material.dart';

/// Balão de mensagem do chat (usuário à direita, agente à esquerda).
class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.text, required this.isUser});
  final String text;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 520),
        decoration: BoxDecoration(
          color: isUser ? cores.primary : cores.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(text,
            style: TextStyle(
                color: isUser ? cores.onPrimary : cores.onSurfaceVariant)),
      ),
    );
  }
}
