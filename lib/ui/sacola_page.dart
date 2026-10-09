import 'package:flutter/material.dart';

import '../core/moeda.dart';
import '../models/models.dart';
import '../services/api.dart';
import '../services/sacola.dart';
import 'componentes.dart';
import 'fundo_liquido.dart';
import 'privacidade_page.dart';
import 'tema.dart';
import '../services/whatsapp_service.dart';

typedef _Comprador = ({String nome, String telefone, String? cpf});

class _DadosCompradorDialog extends StatefulWidget {
  const _DadosCompradorDialog();

  @override
  State<_DadosCompradorDialog> createState() => _DadosCompradorDialogState();
}

class _DadosCompradorDialogState extends State<_DadosCompradorDialog> {
  final _form = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _telefone = TextEditingController();
  final _cpf = TextEditingController();
  bool _aceito = false; // consentimento (LGPD) antes de gravar nome/telefone/CPF

  @override
  void dispose() {
    _nome.dispose();
    _telefone.dispose();
    _cpf.dispose();
    super.dispose();
  }

  static String _digitos(String s) => s.replaceAll(RegExp(r'\D'), '');

  @override
  Widget build(BuildContext context) => AlertDialog(
        scrollable: true,
        title: const Text('Seus dados'),
        content: Form(
          key: _form,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              controller: _nome,
              decoration: const InputDecoration(labelText: 'Nome'),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'Informe o nome' : null,
            ),
            TextFormField(
              controller: _telefone,
              keyboardType: TextInputType.phone,
              decoration:
                  const InputDecoration(labelText: 'Telefone (com DDD)'),
              validator: (v) {
                final n = _digitos(v ?? '').length;
                return n < 10 || n > 13 ? 'Telefone inválido' : null;
              },
            ),
            TextFormField(
              controller: _cpf,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'CPF (opcional)'),
              validator: (v) {
                final n = _digitos(v ?? '').length;
                return n != 0 && n != 11 ? 'CPF deve ter 11 dígitos' : null;
              },
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _aceito,
              onChanged: (v) => setState(() => _aceito = v ?? false),
              title: const Text('Concordo em usar meus dados só para este pedido.',
                  style: TextStyle(fontSize: 14)),
              subtitle: GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const PrivacidadePage())),
                child: const Text('Ler privacidade e termos',
                    style: TextStyle(decoration: TextDecoration.underline)),
              ),
            ),
          ]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: !_aceito ? null : () {
              if (!_form.currentState!.validate()) return;
              final cpf = _digitos(_cpf.text);
              Navigator.pop<_Comprador>(context, (
                nome: _nome.text.trim(),
                telefone: _digitos(_telefone.text),
                cpf: cpf.isEmpty ? null : cpf,
              ));
            },
            child: const Text('Continuar'),
          ),
        ],
      );
}

class SacolaPage extends StatelessWidget {
  const SacolaPage({super.key, required this.sacola, required this.whatsapp});
  final Sacola sacola;
  final WhatsAppService whatsapp;

  /// Pede os dados do comprador, grava o pedido no MySQL (via API) e abre o
  /// WhatsApp. Erro de regra (ex.: sem estoque) para aqui; falta de conexão
  /// só avisa e segue pelo WhatsApp, como o app já funcionava antes.
  Future<void> _fechar(BuildContext context) async {
    final dados = await showDialog<_Comprador>(
        context: context, builder: (_) => const _DadosCompradorDialog());
    if (dados == null || !context.mounted) return;

    final msg = ScaffoldMessenger.of(context);
    int? numero;
    try {
      numero = await Api.enviarPedido(sacola,
          nome: dados.nome, telefone: dados.telefone, cpf: dados.cpf);
    } on ApiErro catch (e) {
      msg.showSnackBar(SnackBar(content: Text(e.mensagem)));
      return;
    } catch (_) {
      msg.showSnackBar(const SnackBar(
          content: Text('Pedido não foi salvo (sem conexão). '
              'Enviando só pelo WhatsApp.')));
    }
    await whatsapp.enviar(sacola.mensagemPedido(numeroPedido: numero));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Sacola')),
        body: FundoLiquido(child: ListenableBuilder(
          listenable: sacola,
          builder: (context, _) {
            if (sacola.vazia) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.shopping_bag_outlined,
                        size: 48, color: corTextoSuave),
                    const SizedBox(height: 16),
                    Text('Sua sacola tá vazia.',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    const Text('Bora escolher uma peça?',
                        style: TextStyle(color: corTextoSuave)),
                    const SizedBox(height: 24),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: const Text('Ver peças'),
                    ),
                  ]),
                ),
              );
            }
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: sacola.itens.length,
                      separatorBuilder: (_, __) => const Divider(height: 32),
                      itemBuilder: (_, k) => _LinhaItem(
                          item: sacola.itens[k], sacola: sacola),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    decoration: const BoxDecoration(
                      color: corPainel,
                      border:
                          Border(top: BorderSide(color: corLinha, width: 0.5)),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total'),
                            Text(
                              '${formatarReais(sacola.total)}'
                              '${sacola.temPrecoPendente ? ' + a combinar' : ''}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontFeatures: const [
                                FontFeature.tabularFigures()
                              ]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            icon: const Icon(Icons.chat_outlined),
                            label: const Text('Fechar pedido pelo WhatsApp'),
                            onPressed: () => _fechar(context),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ]),
              ),
            );
          },
        )),
      );
}

class _LinhaItem extends StatelessWidget {
  const _LinhaItem({required this.item, required this.sacola});
  final ItemSacola item;
  final Sacola sacola;

  @override
  Widget build(BuildContext context) {
    final p = item.peca;
    final variante = p.cores.where((c) => c.nome == item.cor).firstOrNull;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        width: 72,
        height: 96,
        child: fotoOuPlaceholder(p.fotos.firstOrNull, variante: variante),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p.nome, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 2),
          Text('${item.cor} · ${item.tamanho}',
              style: const TextStyle(color: corTextoSuave)),
          const SizedBox(height: 2),
          Text(p.precoFormatado,
              style: const TextStyle(
                  fontFeatures: [FontFeature.tabularFigures()])),
          const SizedBox(height: 10),
          SeletorQuantidade(
            quantidade: item.quantidade,
            minimo: 0,
            aoMudar: (v) => sacola.alterarQuantidade(item, v - item.quantidade),
          ),
        ]),
      ),
    ]);
  }
}
