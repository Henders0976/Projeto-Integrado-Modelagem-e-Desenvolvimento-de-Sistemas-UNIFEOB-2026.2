import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rvlabel_app/services/loja_info.dart';
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

  testWidgets('Privacidade identifica o responsável (CNPJ) e o e-mail de contato', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PrivacidadePage()));
    expect(find.text('Quem é o responsável'), findsOneWidget);
    expect(find.textContaining(cnpjLoja), findsOneWidget);
    expect(find.textContaining(emailContato), findsWidgets);
  });

  test('o CNPJ da loja tem os dígitos verificadores certos', () {
    bool valido(String texto) {
      final d = texto.replaceAll(RegExp(r'\D'), '').split('').map(int.parse).toList();
      if (d.length != 14 || d.toSet().length == 1) return false;
      int dv(int n) {
        final pesos = n == 12
            ? [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]
            : [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
        var soma = 0;
        for (var i = 0; i < n; i++) {
          soma += d[i] * pesos[i];
        }
        final resto = soma % 11;
        return resto < 2 ? 0 : 11 - resto;
      }

      return dv(12) == d[12] && dv(13) == d[13];
    }

    expect(valido(cnpjLoja), isTrue);
    expect(valido('68.647.856/0001-98'), isFalse); // um dígito trocado
  });
}
