import 'package:flutter_test/flutter_test.dart';
import 'package:rvlabel_app/core/resumo.dart';
import 'package:rvlabel_app/models/models.dart';

Peca _peca(String id, Categoria c,
        {double? preco = 50,
        List<String> tamanhos = const ['P', 'M', 'G'],
        List<VarianteCor> cores = const [VarianteCor(nome: 'Preto')]}) =>
    Peca(id: id, nome: id, categoria: c, preco: preco, tamanhos: tamanhos, cores: cores);

void main() {
  final catalogo = <Produto>[
    _peca('a', Categoria.bodys,
        preco: 49.9, cores: const [VarianteCor(nome: 'Preto'), VarianteCor(nome: 'Vinho')]),
    _peca('b', Categoria.bodys, preco: 74.9),
    _peca('c', Categoria.blusas, preco: 39.9, cores: const [VarianteCor(nome: 'Branco')]),
    _peca('d', Categoria.vestidos,
        preco: 109.9, tamanhos: const ['P', 'M', 'G', 'GG'], cores: const [VarianteCor(nome: 'Única')]),
    Acessorio(
        id: 'e',
        nome: 'e',
        categoria: Categoria.acessorios,
        preco: 29.9,
        cores: const [VarianteCor(nome: 'Prateado')]),
    _peca('f', Categoria.tops, preco: null),
  ];
  final r = resumirCatalogo(catalogo);

  test('conta, tira a faixa de preço e separa o que não tem preço', () {
    expect(r.total, 6);
    expect([r.menor, r.maior], [29.9, 109.9]);
    expect(r.aCombinar, 1);
  });

  test('ordena as categorias por quantidade e depois por nome, cada uma com o seu preço', () {
    expect(r.categorias.map((c) => c.categoria.rotulo),
        ['Bodys', 'Acessórios', 'Blusas', 'Tops', 'Vestidos']);
    expect(r.categorias.first.quantidade, 2);
    expect([r.categorias.first.menor, r.categorias.first.maior], [49.9, 74.9]);
    final tops = r.categorias.firstWhere((c) => c.categoria == Categoria.tops);
    expect([tops.quantidade, tops.menor, tops.maior], [1, null, null]);
  });

  test('tamanhos só das roupas, do P ao GG (o acessório "Único" fica de fora)', () {
    expect(r.tamanhos, ['P', 'M', 'G', 'GG']);
    expect(r.acessorios, 1);
  });

  test('cores: as mais frequentes primeiro, sem a "Única" do catálogo', () {
    expect(r.cores, ['Preto', 'Branco', 'Prateado', 'Vinho']);
  });

  test('catálogo vazio não quebra', () {
    final vazio = resumirCatalogo(const []);
    expect([vazio.total, vazio.menor, vazio.maior], [0, null, null]);
    expect([vazio.categorias, vazio.tamanhos, vazio.cores], [isEmpty, isEmpty, isEmpty]);
  });

  test('textos: frase com "e", singular/plural e faixa de preço', () {
    expect(emFrase([]), '');
    expect(emFrase(['P']), 'P');
    expect(emFrase(['P', 'M']), 'P e M');
    expect(emFrase(['P', 'M', 'G']), 'P, M e G');
    expect(contar(1, 'peça', 'peças'), '1 peça');
    expect(contar(6, 'peça', 'peças'), '6 peças');
    expect(faixaDePreco(49.9, 74.9), 'R\$ 49,90 a R\$ 74,90');
    expect(faixaDePreco(109.9, 109.9), 'R\$ 109,90');
    expect(faixaDePreco(null, null), isNull);
  });
}
