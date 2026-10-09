import 'package:flutter/material.dart';

import '../core/moeda.dart';
import '../services/api.dart';
import '../services/api_admin.dart';
import 'fundo_liquido.dart';

/// O cliente acompanha o pedido com número + telefone (sem conta).
class MeusPedidosPage extends StatefulWidget {
  const MeusPedidosPage({super.key});

  @override
  State<MeusPedidosPage> createState() => _MeusPedidosPageState();
}

class _MeusPedidosPageState extends State<MeusPedidosPage> {
  static const _etapas = ['Recebido', 'Em separação', 'Enviado'];
  final _numero = TextEditingController();
  final _telefone = TextEditingController();
  Map<String, dynamic>? _pedido;
  String? _erro;
  bool _carregando = false;

  @override
  void dispose() {
    _numero.dispose();
    _telefone.dispose();
    super.dispose();
  }

  Future<void> _buscar() async {
    final id = int.tryParse(_numero.text.trim());
    final tel = _telefone.text.replaceAll(RegExp(r'\D'), '');
    if (id == null || tel.length < 10) {
      setState(() => _erro = 'Informe o número do pedido e o telefone com DDD.');
      return;
    }
    setState(() {
      _carregando = true;
      _erro = null;
      _pedido = null;
    });
    try {
      final p = await ApiAdmin.consultarPedido(id, tel);
      if (mounted) setState(() => _pedido = p);
    } on ApiErro catch (e) {
      if (mounted) setState(() => _erro = e.mensagem);
    } catch (_) {
      if (mounted) setState(() => _erro = 'Sem conexão com o servidor. Tente de novo.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _pedido;
    return Scaffold(
      appBar: AppBar(title: const Text('Meus pedidos')),
      body: FundoLiquido(
        child: ListView(padding: const EdgeInsets.all(24), children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Use o número do pedido (enviado no WhatsApp) e o '
                    'telefone que você informou na compra.'),
                const SizedBox(height: 12),
                TextField(
                  controller: _numero,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Número do pedido'),
                ),
                TextField(
                  controller: _telefone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Telefone (com DDD)'),
                  onSubmitted: (_) => _buscar(),
                ),
                const SizedBox(height: 16),
                FilledButton(
                    onPressed: _carregando ? null : _buscar, child: const Text('Consultar')),
                if (_carregando) const Padding(
                    padding: EdgeInsets.only(top: 16), child: LinearProgressIndicator()),
                if (_erro != null) Padding(
                    padding: const EdgeInsets.only(top: 16), child: Text(_erro!)),
                if (p != null) ..._detalhe(context, p),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  List<Widget> _detalhe(BuildContext context, Map<String, dynamic> p) {
    final status = p['status'] as String;
    final cancelado = status == 'Cancelado';
    final atual = _etapas.indexOf(status);
    return [
      const SizedBox(height: 24),
      Text('Pedido nº ${p['id']}', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 12),
      if (cancelado)
        const Text('Este pedido foi cancelado.')
      else
        for (var i = 0; i < _etapas.length; i++)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(i <= atual ? Icons.check_circle : Icons.radio_button_unchecked),
            title: Text(_etapas[i],
                style: TextStyle(fontWeight: i == atual ? FontWeight.bold : FontWeight.normal)),
          ),
      const Divider(height: 32),
      for (final i in (p['itens'] as List).cast<Map<String, dynamic>>())
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text('${i['quantidade']}× ${i['nome']} · ${i['cor']} · ${i['tamanho']}'
              '${i['subtotal'] == null ? ' · a combinar' : ' · ${formatarReais((i['subtotal'] as num).toDouble())}'}'),
        ),
      const SizedBox(height: 8),
      Text('Total: ${formatarReais((p['total'] as num).toDouble())}'
          '${p['precoPendente'] == true ? ' + itens a combinar' : ''}',
          style: const TextStyle(fontWeight: FontWeight.bold)),
    ];
  }
}
