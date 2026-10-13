import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rvlabel_app/ui/admin_page.dart';

/// Um "banco" em memória no lugar da API: a lista reflete o que foi alterado.
class _Falso {
  final produtos = <Map<String, dynamic>>[
    {'codigo': 'a', 'nome': 'Blusa A', 'preco': 50, 'ativo': false, 'variacoes': []},
    {'codigo': 'b', 'nome': 'Body B', 'preco': 60, 'ativo': true, 'variacoes': []},
    {'codigo': 'c', 'nome': 'Short C', 'preco': 40, 'ativo': false, 'variacoes': []},
  ];
  final alteracoes = <String>[];
  var copias = 0;

  Future<List<Map<String, dynamic>>> buscar() async => [for (final p in produtos) Map.of(p)];

  Future<void> alterar(String codigo, Map<String, dynamic> campos) async {
    alteracoes.add('$codigo ${campos['ativo']}');
    produtos.firstWhere((p) => p['codigo'] == codigo)['ativo'] = campos['ativo'];
  }

  Future<void> copiar() async => copias++;
}

Widget _app(_Falso f) => MaterialApp(
      builder: (c, child) => MediaQuery(data: MediaQuery.of(c).copyWith(disableAnimations: true), child: child!),
      home: Scaffold(
        body: ProdutosAdmin(buscarProdutos: f.buscar, alterarProduto: f.alterar, atualizarCopia: f.copiar),
      ),
    );

/// Avança o relógio aos poucos até o texto aparecer. O aviso (SnackBar) some sozinho em 4 s, então o
/// pumpAndSettle, que espera tudo acabar, passaria direto por ele.
Future<void> _ate(WidgetTester tester, Finder alvo) async {
  for (var i = 0; i < 30 && alvo.evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('Selecionar todos e ativar: só os desativados mudam, o aviso conta e a cópia local é guardada',
      (tester) async {
    tester.view.physicalSize = const Size(1000, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final f = _Falso();
    await tester.pumpWidget(_app(f));
    await tester.pumpAndSettle();

    // Fora do modo de seleção só há o botão que o abre.
    expect(find.text('Selecionar vários'), findsOneWidget);
    expect(find.text('Selecionar todos'), findsNothing);

    await tester.tap(find.text('Selecionar vários'));
    await tester.pumpAndSettle();
    expect(find.text('0 de 3'), findsOneWidget);

    await tester.tap(find.text('Selecionar todos'));
    await tester.pumpAndSettle();
    expect(find.text('3 de 3'), findsOneWidget);

    await tester.tap(find.text('Ativar'));
    await _ate(tester, find.text('2 ativados; 1 já estava assim.'));

    expect(f.alteracoes, ['a true', 'c true']); // "b" já estava ativo
    expect(f.produtos.every((p) => p['ativo'] == true), isTrue);
    expect(f.copias, 1);
    expect(find.text('2 ativados; 1 já estava assim.'), findsOneWidget);
    expect(find.text('Selecionar todos'), findsNothing); // saiu do modo de seleção
  });

  testWidgets('Marcar só alguns e desativar; sem nenhum marcado os botões ficam desligados', (tester) async {
    tester.view.physicalSize = const Size(1000, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final f = _Falso();
    await tester.pumpWidget(_app(f));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Selecionar vários'));
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);

    await tester.tap(find.text('Body B'));
    await tester.pumpAndSettle();
    expect(find.text('1 de 3'), findsOneWidget);

    await tester.tap(find.text('Desativar'));
    await _ate(tester, find.text('1 desativado.'));
    expect(f.alteracoes, ['b false']);
    expect(find.text('1 desativado.'), findsOneWidget);
  });

  testWidgets('Cancelar sai do modo de seleção sem alterar nada', (tester) async {
    tester.view.physicalSize = const Size(1000, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final f = _Falso();
    await tester.pumpWidget(_app(f));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Selecionar vários'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Selecionar todos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(find.text('Selecionar vários'), findsOneWidget);
    expect(f.alteracoes, isEmpty);
    expect(f.copias, 0);
  });
}
