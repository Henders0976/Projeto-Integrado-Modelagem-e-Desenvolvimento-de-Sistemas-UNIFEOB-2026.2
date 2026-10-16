import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rvlabel_app/services/catalogo_repository.dart';
import 'package:rvlabel_app/services/sacola.dart';
import 'package:rvlabel_app/services/whatsapp_service.dart';
import 'package:rvlabel_app/ui/home_page.dart';
import 'package:rvlabel_app/ui/tema.dart';

CatalogoRepository _catalogo() => CatalogoRepository.deJson({
      'pecas': [
        for (var i = 0; i < 6; i++)
          {
            'id': 'p$i',
            'nome': 'Peça $i',
            'categoria': i.isEven ? 'blusas' : 'shorts',
            'preco': 40 + i * 10,
            'cores': [
              {'nome': 'Preto'}
            ],
          },
      ],
    });

Future<void> _abrir(WidgetTester tester, Size tela) async {
  tester.view.physicalSize = tela;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    theme: temaRvLabel(),
    builder: (c, child) =>
        MediaQuery(data: MediaQuery.of(c).copyWith(disableAnimations: true), child: child!),
    home: HomePage(
      catalogo: _catalogo(),
      sacola: Sacola(),
      whatsapp: const WhatsAppService(numero: '5500000000000'),
    ),
  ));
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  for (final (nome, tela) in const [('celular', Size(375, 812)), ('desktop', Size(1280, 800))]) {
    testWidgets('Início abre e rola até a coleção sem erro ($nome)', (tester) async {
      await _abrir(tester, tela);
      expect(tester.takeException(), isNull);
      expect(find.text('6 peças'), findsWidgets);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -1400));
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('filtro sem resultado mostra o estado vazio e "Limpar filtros" volta tudo', (tester) async {
    await _abrir(tester, const Size(1280, 800));
    // Rola até a barra de filtros ficar presa no topo e usa a cópia fixa (a última na árvore).
    for (var i = 0; i < 7; i++) {
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -200));
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pump(); // a barra fixa é decidida depois do layout do quadro anterior
    await tester.tap(find.text('Vestidos').last);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Nenhuma peça com esses filtros'), findsOneWidget);

    // Trocar o filtro pela barra fixa voltou a página para o começo da coleção: o botão está à vista.
    await tester.tap(find.text('Limpar filtros'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('6 peças'), findsWidgets);
  });
}
