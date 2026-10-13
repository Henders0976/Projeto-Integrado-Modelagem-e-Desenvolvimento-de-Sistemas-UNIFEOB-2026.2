import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show rootBundle;

import '../models/models.dart';
import 'api.dart';
import 'catalogo_local.dart';

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

  /// Lê o catálogo da API (MySQL), que só devolve o que a administradora ativou, e guarda uma cópia no aparelho.
  /// Se a API estiver fora do ar, usa a última cópia guardada: o que ela ativou continua aparecendo até ser
  /// desativado, mesmo depois de fechar e abrir o app. Só se nunca houve cópia cai para assets/catalogo.json,
  /// cujas peças vêm desativadas (`"ativo": false`): aí a vitrine fica vazia, e quem decide o que aparece é ela.
  static Future<CatalogoRepository> carregar() async => deJson(await obterDados(
        api: Api.produtos,
        cache: CatalogoLocal.ler,
        guardar: CatalogoLocal.salvar,
        embutido: () async =>
            jsonDecode(await rootBundle.loadString('assets/catalogo.json')) as Map<String, dynamic>,
      ));

  /// A escolha da fonte do catálogo, separada para poder ser testada: API, senão cópia guardada, senão embutido.
  static Future<Map<String, dynamic>> obterDados({
    required Future<Map<String, dynamic>> Function() api,
    required Future<Map<String, dynamic>?> Function() cache,
    required Future<void> Function(Map<String, dynamic>) guardar,
    required Future<Map<String, dynamic>> Function() embutido,
  }) async {
    try {
      final dados = await api();
      try {
        await guardar(dados);
      } catch (e) {
        debugPrint('Não consegui guardar a cópia do catálogo: $e');
      }
      return dados;
    } catch (e) {
      debugPrint('API indisponível: $e');
      return await cache() ?? await embutido();
    }
  }

  /// Atualiza a cópia guardada com o que a API tem agora. A área administrativa chama depois de ativar ou
  /// desativar peças, para a mudança valer mesmo se o app for reaberto sem a API.
  static Future<void> atualizarCopiaLocal() async {
    try {
      await CatalogoLocal.salvar(await Api.produtos());
    } catch (e) {
      debugPrint('Não consegui atualizar a cópia local do catálogo: $e');
    }
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
