import '../core/moeda.dart';
import 'produto.dart';

/// Produto + escolhas do cliente (cor, tamanho, quantidade).
class ItemSacola {
  ItemSacola({
    required this.peca,
    required this.cor,
    required this.tamanho,
    int quantidade = 1,
  }) : _quantidade = _validarQuantidade(quantidade);

  final Produto peca;
  final String cor;
  final String tamanho;
  int _quantidade;

  int get quantidade => _quantidade;
  set quantidade(int valor) => _quantidade = _validarQuantidade(valor);

  static int _validarQuantidade(int valor) {
    if (valor < 1) throw ArgumentError('A quantidade mínima é 1.');
    return valor;
  }

  /// Mesma peça/cor/tamanho = mesmo item (soma quantidade).
  String get chave => '${peca.id}|$cor|$tamanho';

  double? get subtotal => peca.preco == null ? null : peca.preco! * _quantidade;

  String get linhaPedido =>
      '• ${_quantidade}x ${peca.nome} ($cor, $tamanho) - '
      '${subtotal == null ? 'preço a combinar' : formatarReais(subtotal!)}';
}
