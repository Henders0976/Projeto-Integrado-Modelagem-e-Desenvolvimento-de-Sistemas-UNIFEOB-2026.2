import 'package:flutter_test/flutter_test.dart';
import 'package:rvlabel_app/core/filtro_vitrine.dart';
import 'package:rvlabel_app/models/models.dart';

Peca _peca(String id, double? preco, {List<String> tamanhos = const ['P', 'M'], String cor = 'Preto'}) =>
    Peca(
      id: id,
      nome: 'Peça $id',
      categoria: Categoria.blusas,
      preco: preco,
      tamanhos: tamanhos,
      cores: [VarianteCor(nome: cor)],
    );

void main() {
  final a = _peca('a', 39.9, cor: 'Vinho');
  final b = _peca('b', 74.9, tamanhos: ['G']);
  final c = _peca('c', null);
  final d = _peca('d', 109.9, cor: 'Vinho');
  final e = _peca('e', 74.9);
  final todas = [a, b, c, d, e];

  List<String> ids(List<Produto> l) => [for (final p in l) p.id];

  test('sem filtro devolve tudo na ordem original', () {
    expect(ids(filtrarVitrine(todas)), ['a', 'b', 'c', 'd', 'e']);
  });

  test('tamanho, cor e faixa combinam', () {
    expect(ids(filtrarVitrine(todas, tamanho: 'G')), ['b']);
    expect(ids(filtrarVitrine(todas, cor: 'Vinho')), ['a', 'd']);
    expect(ids(filtrarVitrine(todas, faixa: FaixaPreco.de50a80)), ['b', 'e']);
    expect(ids(filtrarVitrine(todas, cor: 'Vinho', faixa: FaixaPreco.acima80)), ['d']);
  });

  test('preço a definir não entra em faixa e vai para o fim na ordem por preço', () {
    expect(filtrarVitrine(todas, faixa: FaixaPreco.ate50), [a]);
    expect(ids(filtrarVitrine(todas, ordem: OrdemVitrine.menorPreco)), ['a', 'b', 'e', 'd', 'c']);
    expect(ids(filtrarVitrine(todas, ordem: OrdemVitrine.maiorPreco)), ['d', 'b', 'e', 'a', 'c']);
  });

  test('limites da faixa: 50 já é da segunda, 80 já é da terceira', () {
    expect(FaixaPreco.ate50.contem(50), isFalse);
    expect(FaixaPreco.de50a80.contem(50), isTrue);
    expect(FaixaPreco.acima80.contem(80), isTrue);
  });
}
