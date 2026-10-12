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

  /// Fotos de todas as peças do catálogo, inclusive as desativadas: é entre elas que
  /// a administradora escolhe ao cadastrar um produto novo.
  List<String> fotos();

  /// Lê o catálogo da API (MySQL), que só devolve o que a administradora ativou. Se a API
  /// estiver fora do ar, cai para assets/catalogo.json, cujas peças vêm desativadas
  /// (`"ativo": false`): sem a API a vitrine fica vazia, e quem decide o que aparece é a administradora.
  static Future<CatalogoRepository> carregar() async {
    Map<String, dynamic> dados;
    try {
      dados = await Api.produtos();
    } catch (e) {
      debugPrint('API indisponível, usando catalogo.json: $e');
      final bruto = await rootBundle.loadString('assets/catalogo.json');
      dados = jsonDecode(bruto) as Map<String, dynamic>;
    }
    return deJson(dados);
  }

  /// Monta o catálogo a partir do JSON. Uma peça com dado inválido (por exemplo,
  /// categoria que o app não conhece) é ignorada em vez de derrubar o app inteiro.
  /// Peça com `"ativo": false` fica fora da vitrine, mas suas fotos continuam em [fotos].
  static CatalogoRepository deJson(Map<String, dynamic> dados) {
    final produtos = <Produto>[];
    final fotos = <String>{};
    for (final p in dados['pecas'] as List) {
      try {
        final peca = Produto.fromJson(p as Map<String, dynamic>);
        fotos.addAll(peca.fotos);
        if (p['ativo'] != false) produtos.add(peca);
      } catch (e) {
        debugPrint('Peça ignorada (${p is Map ? p['id'] : p}): $e');
      }
    }
    return _CatalogoJson._(produtos, fotos);
  }
}

class _CatalogoJson implements CatalogoRepository {
  _CatalogoJson._(this._produtos, this._fotos);
  final List<Produto> _produtos;
  final Set<String> _fotos;

  @override
  List<String> fotos() => _fotos.toList()..sort();

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
