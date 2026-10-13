import 'package:flutter_test/flutter_test.dart';
import 'package:rvlabel_app/services/catalogo_local.dart';
import 'package:rvlabel_app/services/catalogo_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> _catalogo(String id) => {
      'pecas': [
        {'id': id, 'nome': 'Peça $id', 'categoria': 'Bodys', 'tipo': 'peca', 'preco': 50}
      ]
    };

void main() {
  group('de onde vem o catálogo', () {
    test('API no ar: usa o da API e guarda uma cópia', () async {
      Map<String, dynamic>? guardado;
      final r = await CatalogoRepository.obterDados(
        api: () async => _catalogo('api'),
        cache: () async => _catalogo('cache'),
        guardar: (d) async => guardado = d,
        embutido: () async => _catalogo('embutido'),
      );
      expect(r, _catalogo('api'));
      expect(guardado, _catalogo('api'));
    });

    test('API fora do ar: usa a cópia guardada, para o que ela ativou continuar aparecendo', () async {
      final r = await CatalogoRepository.obterDados(
        api: () async => throw Exception('sem rede'),
        cache: () async => _catalogo('cache'),
        guardar: (_) async {},
        embutido: () async => _catalogo('embutido'),
      );
      expect(r, _catalogo('cache'));
    });

    test('API fora do ar e nunca houve cópia: cai para o catálogo embutido', () async {
      final r = await CatalogoRepository.obterDados(
        api: () async => throw Exception('sem rede'),
        cache: () async => null,
        guardar: (_) async {},
        embutido: () async => _catalogo('embutido'),
      );
      expect(r, _catalogo('embutido'));
    });

    test('falha ao guardar a cópia não esconde o catálogo que a API devolveu', () async {
      final r = await CatalogoRepository.obterDados(
        api: () async => _catalogo('api'),
        cache: () async => null,
        guardar: (_) async => throw Exception('disco cheio'),
        embutido: () async => _catalogo('embutido'),
      );
      expect(r, _catalogo('api'));
    });
  });

  group('cópia local', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('guarda e devolve o mesmo catálogo', () async {
      expect(await CatalogoLocal.ler(), isNull);
      await CatalogoLocal.salvar(_catalogo('a'));
      expect(await CatalogoLocal.ler(), _catalogo('a'));
    });

    test('uma cópia nova substitui a anterior (peça desativada some)', () async {
      await CatalogoLocal.salvar(_catalogo('a'));
      await CatalogoLocal.salvar({'pecas': []});
      expect(await CatalogoLocal.ler(), {'pecas': []});
    });

    test('texto guardado que não é um catálogo é ignorado', () async {
      SharedPreferences.setMockInitialValues({'catalogo_ativado_v1': '{"nada": 1}'});
      expect(await CatalogoLocal.ler(), isNull);
      SharedPreferences.setMockInitialValues({'catalogo_ativado_v1': 'isto nem é json'});
      expect(await CatalogoLocal.ler(), isNull);
    });
  });
}
