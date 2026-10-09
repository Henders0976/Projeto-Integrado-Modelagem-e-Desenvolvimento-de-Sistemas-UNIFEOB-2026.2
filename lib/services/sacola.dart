import 'package:flutter/foundation.dart';

import '../core/moeda.dart';
import '../models/models.dart';

/// Estado da sacola de compras (observável pela UI).
/// O mapa interno é privado: a UI só enxerga getters e métodos.
class Sacola extends ChangeNotifier {
  final Map<String, ItemSacola> _itens = {};

  List<ItemSacola> get itens => List.unmodifiable(_itens.values);
  int get quantidadeTotal =>
      _itens.values.fold(0, (soma, i) => soma + i.quantidade);
  bool get vazia => _itens.isEmpty;

  double get total =>
      _itens.values.fold(0.0, (soma, i) => soma + (i.subtotal ?? 0));
  bool get temPrecoPendente => _itens.values.any((i) => i.subtotal == null);

  void adicionar(Produto produto,
      {required String cor, required String tamanho, int quantidade = 1}) {
    final novo = ItemSacola(
        peca: produto, cor: cor, tamanho: tamanho, quantidade: quantidade);
    final existente = _itens[novo.chave];
    if (existente != null) {
      existente.quantidade += quantidade;
    } else {
      _itens[novo.chave] = novo;
    }
    notifyListeners();
  }

  void alterarQuantidade(ItemSacola item, int delta) {
    final nova = item.quantidade + delta;
    if (nova < 1) {
      _itens.remove(item.chave);
    } else {
      item.quantidade = nova; // passa pelo setter validado
    }
    notifyListeners();
  }

  void limpar() {
    _itens.clear();
    notifyListeners();
  }

  /// Texto enviado no "Fechar pedido pelo WhatsApp".
  String mensagemPedido({int? numeroPedido}) {
    final b = StringBuffer('Olá, RV Label! Quero fechar este pedido'
        '${numeroPedido == null ? '' : ' (nº $numeroPedido)'}:\n\n');
    for (final i in _itens.values) {
      b.writeln(i.linhaPedido);
    }
    b.writeln('\nTotal: ${formatarReais(total)}'
        '${temPrecoPendente ? ' + itens a combinar' : ''}');
    return b.toString();
  }
}
