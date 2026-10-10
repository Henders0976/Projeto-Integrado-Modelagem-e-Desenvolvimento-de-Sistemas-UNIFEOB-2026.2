import 'package:flutter/material.dart';

import '../services/whatsapp_service.dart';
import 'efeitos.dart';
import 'tema.dart';

/// Mensagem enviada ao WhatsApp da marca quando a cliente pede as novidades.
String mensagemNovidades(String email) =>
    'Olá, RV Label! Quero receber as novidades da coleção. Meu e-mail: $email';

/// E-mail com "algo@algo.algo": só barra erro de digitação, não valida de verdade.
bool emailPlausivel(String v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());

/// Faixa "Novidades RV" com foto de fundo e campo de e-mail. Não há servidor de
/// e-mail: o pedido segue pelo WhatsApp da marca (shortcut: trocar por lista de
/// e-mails quando a API tiver um endpoint de inscrição).
class Novidades extends StatefulWidget {
  const Novidades({super.key, required this.whatsapp, this.foto});

  final WhatsAppService whatsapp;
  final String? foto;

  @override
  State<Novidades> createState() => _NovidadesState();
}

class _NovidadesState extends State<Novidades> {
  final _email = TextEditingController();
  final _form = GlobalKey<FormState>();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_form.currentState!.validate()) return;
    final aberto = await widget.whatsapp.enviar(mensagemNovidades(_email.text.trim()));
    if (!mounted) return;
    if (aberto) {
      _email.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não consegui abrir o WhatsApp. Tente de novo.')));
    }
  }

  @override
  Widget build(BuildContext context) => Stack(children: [
        Positioned.fill(
          child: widget.foto == null
              ? const ColoredBox(color: corPainel)
              : ParallaxFoto(
                  intensidade: 50,
                  escala: 1.3,
                  child: Image.asset(widget.foto!,
                      fit: BoxFit.cover,
                      alignment: const Alignment(0, -0.3),
                      errorBuilder: (_, __, ___) => const ColoredBox(color: corPainel)),
                ),
        ),
        const Positioned.fill(child: ColoredBox(color: Color(0x99000000))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 96),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _form,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('Novidades RV',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  const Text('Receba lançamentos e peças novas direto no WhatsApp.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: corTextoSuave, fontSize: 16)),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(labelText: 'Seu e-mail'),
                    validator: (v) =>
                        emailPlausivel(v ?? '') ? null : 'Informe um e-mail válido',
                    onFieldSubmitted: (_) => _enviar(),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(onPressed: _enviar, child: const Text('Quero receber')),
                ]),
              ),
            ),
          ),
        ),
      ]);
}
