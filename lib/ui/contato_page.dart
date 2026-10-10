import 'package:flutter/material.dart';

import '../services/whatsapp_service.dart';
import 'efeitos.dart';
import 'fundo_liquido.dart';
import 'novidades.dart';
import 'rolagem_suave.dart';
import 'tema.dart';

/// Texto que vai para o WhatsApp da marca a partir do formulário de contato.
String mensagemContato(
        {required String nome,
        required String email,
        required String assunto,
        required String mensagem}) =>
    'Olá, RV Label! Aqui é $nome ($email).\nAssunto: $assunto\n\n$mensagem';

/// Página "Contato": texto de boas-vindas e formulário que segue pelo WhatsApp.
class ContatoPage extends StatefulWidget {
  const ContatoPage({super.key, required this.whatsapp, this.fotoNovidades});

  final WhatsAppService whatsapp;
  final String? fotoNovidades;

  @override
  State<ContatoPage> createState() => _ContatoPageState();
}

class _ContatoPageState extends State<ContatoPage> {
  final _form = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _assunto = TextEditingController();
  final _mensagem = TextEditingController();

  List<TextEditingController> get _campos => [_nome, _email, _assunto, _mensagem];

  @override
  void dispose() {
    for (final c in _campos) {
      c.dispose();
    }
    super.dispose();
  }

  String? _obrigatorio(String? v) =>
      (v ?? '').trim().isEmpty ? 'Campo obrigatório' : null;

  Future<void> _enviar() async {
    if (!_form.currentState!.validate()) return;
    final aberto = await widget.whatsapp.enviar(mensagemContato(
      nome: _nome.text.trim(),
      email: _email.text.trim(),
      assunto: _assunto.text.trim(),
      mensagem: _mensagem.text.trim(),
    ));
    if (!mounted) return;
    if (aberto) {
      for (final c in _campos) {
        c.clear();
      }
      _form.currentState!.reset();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não consegui abrir o WhatsApp. Tente de novo.')));
    }
  }

  Widget _campo(String rotulo, TextEditingController c,
          {String? Function(String?)? validar,
          TextInputType? teclado,
          int linhas = 1}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: c,
          keyboardType: linhas > 1 ? TextInputType.multiline : teclado,
          minLines: linhas,
          maxLines: linhas,
          decoration: InputDecoration(labelText: rotulo),
          validator: validar ?? _obrigatorio,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final info = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Fale com a gente.', style: Theme.of(context).textTheme.displaySmall),
      const SizedBox(height: 24),
      const Text(
        'Tem dúvida sobre uma peça, tamanho ou pedido? Escreva aqui e a mensagem '
        'segue direto pro WhatsApp da RV Label — sem intermediário, sem pressa.',
        style: TextStyle(color: corTextoSuave, fontSize: 17, height: 1.6),
      ),
      const SizedBox(height: 28),
      OutlinedButton.icon(
        onPressed: () =>
            widget.whatsapp.enviar('Olá, RV Label! Gostaria de tirar uma dúvida.'),
        icon: const Icon(Icons.chat_outlined),
        label: const Text('Chamar no WhatsApp'),
      ),
    ]);
    final formulario = Form(
      key: _form,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _campo('Nome', _nome),
        _campo('E-mail', _email,
            teclado: TextInputType.emailAddress,
            validar: (v) => emailPlausivel(v ?? '') ? null : 'Informe um e-mail válido'),
        _campo('Assunto', _assunto),
        _campo('Mensagem', _mensagem, linhas: 4),
        const SizedBox(height: 12),
        FilledButton(onPressed: _enviar, child: const Text('Enviar pelo WhatsApp')),
      ]),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Contato')),
      body: FundoLiquido(
        child: ListaSuave(children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 56, 24, 96),
                child: LayoutBuilder(builder: (context, caixa) {
                  final largo = caixa.maxWidth >= 760;
                  return AoRolar(
                    child: largo
                        ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Expanded(flex: 5, child: info),
                            const SizedBox(width: 64),
                            Expanded(flex: 6, child: formulario),
                          ])
                        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            info,
                            const SizedBox(height: 40),
                            formulario,
                          ]),
                  );
                }),
              ),
            ),
          ),
          Novidades(whatsapp: widget.whatsapp, foto: widget.fotoNovidades),
        ]),
      ),
    );
  }
}
