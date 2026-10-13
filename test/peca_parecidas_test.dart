import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rvlabel_app/models/models.dart';
import 'package:rvlabel_app/services/sacola.dart';
import 'package:rvlabel_app/ui/peca_page.dart';

Peca _peca(String id) => Peca(id: id, nome: 'Peça $id', categoria: Categoria.bodys, preco: 50);

Widget _app(Widget pagina) => MaterialApp(
      builder: (c, child) => MediaQuery(data: MediaQuery.of(c).copyWith(disableAnimations: true), child: child!),
      home: pagina,
    );

/// Descarta a página e deixa os temporizadores dos efeitos de entrada correrem, para o teste não terminar com algum pendente.
Future<void> _encerrar(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 3));
}

void main() {
  testWidgets('Página da peça mostra "Você também pode gostar" com os cartões recebidos', (tester) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(PecaPage(
      peca: _peca('a'),
      sacola: Sacola(),
      parecidas: [_peca('b'), _peca('c')],
      cartao: (p) => Text('cartao ${p.id}'),
    )));
    await tester.pumpAndSettle();

    expect(find.text('Você também pode gostar'), findsOneWidget);
    expect(find.text('cartao b'), findsOneWidget);
    expect(find.text('cartao c'), findsOneWidget);
    await _encerrar(tester);
  });

  testWidgets('Sem peças parecidas a seção não aparece', (tester) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(PecaPage(peca: _peca('a'), sacola: Sacola())));
    await tester.pumpAndSettle();

    expect(find.text('Você também pode gostar'), findsNothing);
    await _encerrar(tester);
  });
}
