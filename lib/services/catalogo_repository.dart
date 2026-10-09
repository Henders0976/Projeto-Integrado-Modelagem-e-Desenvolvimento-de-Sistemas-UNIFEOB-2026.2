import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show rootBundle;

import '../models/models.dart';
import 'api.dart';

/// Contrato público do catálogo. A implementação ([_CatalogoJson]) é
/// PRIVADA à biblioteca: ninguém de fora enxerga nem instancia a classe,
/// só obtém um [CatalogoRepository] por [carregar].
abstract class CatalogoRepository {
  List<Produto> todas();
  List<Produto> porCategoria(Categoria? categoria);
  Produto? buscarPorId(String id);

  /// Lê o catálogo da API (MySQL). Se a API estiver fora do ar, cai para
  /// assets/catalogo.json para o app continuar funcionando.
  static Future<CatalogoRepository> carregar() async {
    Map<String, dynamic> dados;
    try {
      dados = await Api.produtos();
    } catch (e) {
      debugPrint('API indisponível, usando catalogo.json: $e');
      final bruto = await rootBundle.loadString('assets/catalogo.json');
      dados = jsonDecode(bruto) as Map<String, dynamic>;
    }
    final lista = dados['pecas'] as List;
    return _CatalogoJson._([
      for (final p in lista) Produto.fromJson(p as Map<String, dynamic>)
    ]);
  }
}

class _CatalogoJson implements CatalogoRepository {
  _CatalogoJson._(this._produtos);
  final List<Produto> _produtos;

  @override
  List<Produto> todas() => List.unmodifiable(_produtos);

  @override
  List<Produto> porCategoria(Categoria? categoria) => categoria == null
      ? todas()
      : _produtos.where((p) => p.categoria == categoria).toList();

  @override
  Produto? buscarPorId(String id) {
    for (final p in _produtos) {
      if (p.id == id) return p;
    }
    return null;
  }
}
