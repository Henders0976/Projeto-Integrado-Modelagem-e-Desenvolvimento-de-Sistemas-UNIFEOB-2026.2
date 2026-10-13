import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rvlabel_app/ui/linha_tinta.dart';

Widget _item(String chave) => ItemTinta(
      recuo: 0,
      child: SizedBox(key: Key(chave), width: 100, height: 40, child: Center(child: Text(chave))),
    );

double _opacidadeDaLinha(WidgetTester tester) => tester
    .widget<AnimatedOpacity>(find.ancestor(of: find.byKey(const Key('linha-tinta')), matching: find.byType(AnimatedOpacity)))
    .opacity;

void main() {
  testWidgets('A linha aparece sob a opção com o mouse, desliza para a outra e some ao sair', (tester) async {
    await tester.pumpWidget(MaterialApp(
      // Sem movimento: a linha chega no lugar na hora e o teste lê a posição final.
      builder: (c, child) => MediaQuery(data: MediaQuery.of(c).copyWith(disableAnimations: true), child: child!),
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: TintaNav(child: Row(mainAxisSize: MainAxisSize.min, children: [_item('a'), _item('b')])),
        ),
      ),
    ));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(-50, -50));
    addTearDown(mouse.removePointer);
    final linha = find.byKey(const Key('linha-tinta'));

    expect(_opacidadeDaLinha(tester), 0);

    await mouse.moveTo(tester.getCenter(find.byKey(const Key('a'))));
    await tester.pumpAndSettle();
    expect(_opacidadeDaLinha(tester), 1);
    expect(tester.getTopLeft(linha).dx, tester.getTopLeft(find.byKey(const Key('a'))).dx);
    expect(tester.getSize(linha).width, 100);

    await mouse.moveTo(tester.getCenter(find.byKey(const Key('b'))));
    await tester.pumpAndSettle();
    expect(_opacidadeDaLinha(tester), 1);
    expect(tester.getTopLeft(linha).dx, tester.getTopLeft(find.byKey(const Key('b'))).dx);

    await mouse.moveTo(const Offset(-50, -50));
    await tester.pumpAndSettle();
    expect(_opacidadeDaLinha(tester), 0);
  });
}
