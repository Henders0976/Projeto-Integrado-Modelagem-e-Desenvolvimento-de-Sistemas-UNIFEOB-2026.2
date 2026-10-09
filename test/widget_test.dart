import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rvlabel_app/ui/meus_pedidos_page.dart';
import 'package:rvlabel_app/ui/privacidade_page.dart';

void main() {
  testWidgets('Meus pedidos pede número e telefone antes de consultar', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MeusPedidosPage()));
    await tester.tap(find.text('Consultar'));
    await tester.pump();
    expect(find.textContaining('Informe o número do pedido'), findsOneWidget);
  });

  testWidgets('Privacidade mostra os direitos do titular (LGPD)', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PrivacidadePage()));
    expect(find.text('Seus direitos (LGPD)'), findsOneWidget);
  });
}
