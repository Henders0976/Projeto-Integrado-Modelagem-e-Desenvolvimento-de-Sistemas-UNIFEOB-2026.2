import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rvlabel_app/models/models.dart';
import 'package:rvlabel_app/ui/vitrine.dart';

Peca _peca(String id, double preco) => Peca(id: id, nome: 'Peça $id', categoria: Categoria.bodys, preco: preco);

Widget _app(Widget filho) => MaterialApp(
      builder: (c, child) => MediaQuery(data: MediaQuery.of(c).copyWith(disableAnimations: true), child: child!),
      home: Scaffold(body: SingleChildScrollView(child: Padding(padding: const EdgeInsets.all(24), child: filho))),
    );

void main() {
  testWidgets('Vitrine lista as peças, troca a ativa no mouse e abre a peça tocada', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final pecas = [_peca('a', 49.9), _peca('b', 74.9), _peca('c', 39.9)];
    Produto? aberta;
    await tester.pumpWidget(_app(Vitrine(
      pecas: pecas,
      aoAbrir: (p) => aberta = p,
      rolagem: ValueNotifier<double>(0),
    )));
    await tester.pumpAndSettle();

    expect(find.text('NOSSAS PEÇAS'), findsOneWidget);
    expect(find.text('R\$ 74,90'), findsOneWidget);
    // A primeira peça começa ativa: só ela leva o marcador.
    expect(find.text('Peça a ·'), findsOneWidget);
    expect(find.text('Peça b'), findsOneWidget);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(-50, -50));
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.text('Peça b')));
    await tester.pumpAndSettle();
    expect(find.text('Peça b ·'), findsOneWidget);
    expect(find.text('Peça a'), findsOneWidget);

    await tester.tap(find.text('Peça c'));
    expect(aberta?.id, 'c');
  });

  testWidgets('Vitrine vazia não desenha nada', (tester) async {
    await tester.pumpWidget(_app(Vitrine(pecas: const [], aoAbrir: (_) {}, rolagem: ValueNotifier<double>(0))));
    expect(find.text('NOSSAS PEÇAS'), findsNothing);
  });
}
