import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rvlabel_app/core/resumo.dart';
import 'package:rvlabel_app/models/models.dart';
import 'package:rvlabel_app/ui/resumo_loja.dart';

final _resumo = resumirCatalogo([
  Peca(id: 'a', nome: 'a', categoria: Categoria.bodys, preco: 49.9, cores: const [VarianteCor(nome: 'Preto')]),
  Peca(id: 'b', nome: 'b', categoria: Categoria.bodys, preco: 74.9, tamanhos: const ['P', 'M', 'G', 'GG']),
  Peca(id: 'c', nome: 'c', categoria: Categoria.blusas, preco: null, cores: const [VarianteCor(nome: 'Vinho')]),
]);

// disableAnimations: as seções entram na tela já inteiras (sem esperar a rolagem), como para quem pede menos movimento.
Widget _app(Widget filho) => MaterialApp(
      builder: (c, child) => MediaQuery(data: MediaQuery.of(c).copyWith(disableAnimations: true), child: child!),
      home: Scaffold(body: SingleChildScrollView(child: Padding(padding: const EdgeInsets.all(24), child: filho))),
    );

void main() {
  testWidgets('Índice lista as categorias com quantidade e preço, e tocar numa leva a ela', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    Categoria? escolhida;
    await tester.pumpWidget(_app(IndiceCategorias(resumo: _resumo, aoEscolher: (c) => escolhida = c)));
    await tester.pumpAndSettle();

    expect(find.text('Tudo o que a Essence tem hoje'), findsOneWidget);
    expect(find.textContaining('3 peças em 2 categorias'), findsOneWidget);
    expect(find.text('Bodys'), findsOneWidget);
    expect(find.text('2 peças'), findsOneWidget);
    expect(find.text('R\$ 49,90 a R\$ 74,90'), findsOneWidget);
    expect(find.text('Preço a definir'), findsOneWidget); // Blusas, sem preço

    await tester.tap(find.text('Blusas'));
    expect(escolhida, Categoria.blusas);
  });

  testWidgets('Guia mostra tamanhos, cores, preços e leva ao WhatsApp', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    var falou = false;
    await tester.pumpWidget(_app(GuiaDaLoja(resumo: _resumo, aoFalar: () => falou = true)));
    await tester.pumpAndSettle();

    expect(find.text('Antes de escolher'), findsOneWidget);
    expect(find.textContaining('P, M, G e GG nas roupas.'), findsOneWidget);
    expect(find.textContaining('Preto e Vinho.'), findsOneWidget);
    expect(find.textContaining('1 peça está com preço a definir.'), findsOneWidget);

    await tester.tap(find.text('Falar com a marca'));
    expect(falou, isTrue);
  });
}
