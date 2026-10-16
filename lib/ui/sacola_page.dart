import 'package:flutter/material.dart';

import '../core/mascaras.dart';
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
            RvTextField(
              label: 'Nome',
              controller: _nome,
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'Informe o nome' : null,
            ),
            RvTextField(
              label: 'Telefone (com DDD)',
              controller: _telefone,
              hint: '(11) 99999-9999',
              keyboardType: TextInputType.phone,
              inputFormatters: const [Mascara(formatarTelefone)],
              validator: (v) {
                final n = _digitos(v ?? '').length;
                return n < 10 || n > 13 ? 'Telefone inválido' : null;
              },
            ),
            RvTextField(
              label: 'CPF (opcional)',
              controller: _cpf,
              hint: '000.000.000-00',
              keyboardType: TextInputType.number,
              inputFormatters: const [Mascara(formatarCpf)],
              validator: (v) {
                final n = _digitos(v ?? '').length;
                return n != 0 && n != 11 ? 'CPF deve ter 11 dígitos' : null;
              },
            ),
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
    // Com o pedido gravado, mostra o número antes de sair do app para o WhatsApp.
    if (numero != null && context.mounted) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _PedidoRegistrado(numero: numero!, sacola: sacola),
      );
    }
    await whatsapp.enviar(sacola.mensagemPedido(numeroPedido: numero));
  }

  Widget _resumo(BuildContext context, {required bool comTitulo}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        if (comTitulo) ...[
          Text('Resumo', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: RvSpace.lg),
        ],
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Itens', style: TextStyle(color: RvColors.textSecondary)),
          Text('${sacola.quantidadeTotal}',
              style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()])),
        ]),
        const SizedBox(height: RvSpace.sm),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Total'),
          Flexible(
            child: Text(
              '${formatarReais(sacola.total)}'
              '${sacola.temPrecoPendente ? ' + a combinar' : ''}',
              textAlign: TextAlign.end,
              style: RvText.price,
            ),
          ),
        ]),
        const SizedBox(height: RvSpace.xs),
        const Text('Entrega e pagamento você combina no WhatsApp.', style: RvText.caption),
        const SizedBox(height: RvSpace.lg),
        RvButton(
          label: 'Fechar pedido pelo WhatsApp',
          icon: Icons.chat_outlined,
          onPressed: () => _fechar(context),
        ),
      ]);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Sacola')),
        body: FundoLiquido(child: ListenableBuilder(
          listenable: sacola,
          builder: (context, _) {
            if (sacola.vazia) {
              return Center(
                child: SingleChildScrollView(
                  child: RvEmptyState(
                    icone: Icons.shopping_bag_outlined,
                    titulo: 'Sua sacola tá vazia.',
                    texto: 'Bora escolher uma peça?',
                    rotuloAcao: 'Explorar coleção',
                    aoAcionar: () => Navigator.of(context).maybePop(),
                  ),
                ),
              );
            }
            final lista = ListView.separated(
              padding: const EdgeInsets.all(RvSpace.xl),
              itemCount: sacola.itens.length,
              separatorBuilder: (_, __) => const Divider(height: RvSpace.x2),
              itemBuilder: (_, k) => _LinhaItem(item: sacola.itens[k], sacola: sacola),
            );
            // Desktop: resumo fixo à direita. Celular/tablet: preso no rodapé.
            return LayoutBuilder(builder: (context, caixa) {
              if (caixa.maxWidth >= 1024) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1280),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(child: lista),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, RvSpace.xl, RvSpace.xl, RvSpace.xl),
                        child: SizedBox(
                          width: 360,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(RvSpace.xl),
                              child: _resumo(context, comTitulo: true),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                );
              }
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(children: [
                    Expanded(child: lista),
                    Container(
                      padding: const EdgeInsets.fromLTRB(
                          RvSpace.xl, RvSpace.lg, RvSpace.xl, RvSpace.lg),
                      decoration: const BoxDecoration(
                        color: RvColors.surface,
                        border: Border(top: BorderSide(color: RvColors.border)),
                      ),
                      child: SafeArea(top: false, child: _resumo(context, comTitulo: false)),
                    ),
                  ]),
                ),
              );
            });
          },
        )),
      );
}

/// Confirmação depois de gravar o pedido: mostra o número (para "Meus pedidos") e só então abre o WhatsApp.
class _PedidoRegistrado extends StatelessWidget {
  const _PedidoRegistrado({required this.numero, required this.sacola});
  final int numero;
  final Sacola sacola;

  @override
  Widget build(BuildContext context) => AlertDialog(
        icon: const Icon(Icons.check_circle_outline, color: RvColors.success, size: 40),
        title: Text('Pedido nº $numero registrado', textAlign: TextAlign.center),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(
            '${sacola.quantidadeTotal} ${sacola.quantidadeTotal == 1 ? 'item' : 'itens'} · '
            '${formatarReais(sacola.total)}${sacola.temPrecoPendente ? ' + a combinar' : ''}',
            style: RvText.price.copyWith(fontSize: 16),
          ),
          const SizedBox(height: RvSpace.md),
          const Text(
            'Guarde esse número para acompanhar em "Meus pedidos". Agora envie a mensagem '
            'no WhatsApp para combinar entrega e pagamento.',
            textAlign: TextAlign.center,
            style: TextStyle(color: RvColors.textSecondary),
          ),
        ]),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          RvButton(
            label: 'Abrir WhatsApp',
            icon: Icons.chat_outlined,
            onPressed: () => Navigator.pop(context),
          ),
        ],
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
          Text(p.precoFormatado, style: RvText.price.copyWith(fontSize: 15)),
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
