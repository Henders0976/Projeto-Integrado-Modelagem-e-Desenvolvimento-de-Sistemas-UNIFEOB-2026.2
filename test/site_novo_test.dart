import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rvlabel_app/models/models.dart';
import 'package:rvlabel_app/ui/colecao_page.dart';
import 'package:rvlabel_app/ui/contato_page.dart';
import 'package:rvlabel_app/ui/efeitos.dart';
import 'package:rvlabel_app/ui/novidades.dart';
import 'package:rvlabel_app/ui/rolagem_suave.dart';

void main() {
  test('emailPlausivel aceita e-mail comum e barra erro de digitação', () {
    expect(emailPlausivel(' ana@rv.com '), isTrue);
    expect(emailPlausivel('ana@rv'), isFalse);
    expect(emailPlausivel('ana rv@rv.com'), isFalse);
    expect(emailPlausivel(''), isFalse);
  });

  test('mensagens para o WhatsApp levam os dados da cliente', () {
    expect(mensagemNovidades('ana@rv.com'), contains('ana@rv.com'));
    final m = mensagemContato(
        nome: 'Ana', email: 'ana@rv.com', assunto: 'Tamanho', mensagem: 'Serve M?');
    expect(m, allOf(contains('Ana'), contains('Tamanho'), contains('Serve M?')));
  });

  testWidgets('AoRolar acompanha a rolagem nos dois sentidos', (tester) async {
    final rolagem = ScrollController();
    await tester.pumpWidget(MaterialApp(
      home: ListView(controller: rolagem, children: const [
        SizedBox(height: 700), // alvo começa logo abaixo da tela de 600 px
        AoRolar(child: SizedBox(height: 100, child: Text('alvo'))),
        SizedBox(height: 1500),
      ]),
    ));
    double opacidade() => tester
        .widget<Opacity>(find.descendant(
            of: find.byType(AoRolar, skipOffstage: false),
            matching: find.byType(Opacity, skipOffstage: false)))
        .opacity;
    await tester.pump();
    expect(opacidade(), 0); // ainda fora da tela

    rolagem.jumpTo(400); // alvo subiu até a metade de cima da tela
    await tester.pump();
    await tester.pump();
    expect(opacidade(), 1);

    rolagem.jumpTo(0); // voltou: o efeito desfaz
    await tester.pump();
    await tester.pump();
    expect(opacidade(), 0);
  });

  testWidgets('roda do mouse desliza até o destino em vez de pular', (tester) async {
    final c = ControladorSuave();
    await tester.pumpWidget(MaterialApp(
      home: ListView(controller: c, children: const [SizedBox(height: 3000)]),
    ));
    final mouse = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(mouse.hover(const Offset(100, 100)));
    await tester.sendEventToBinding(mouse.scroll(const Offset(0, 100)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(c.offset, allOf(greaterThan(0), lessThan(100))); // a meio caminho

    await tester.sendEventToBinding(mouse.scroll(const Offset(0, 100)));
    await tester.pumpAndSettle();
    expect(c.offset, 200); // os dois cliques se somaram
  });

  test('toda categoria do catálogo cai em alguma coleção', () {
    final cobertas = colecoes.expand((c) => c.categorias).toSet();
    expect(cobertas, Categoria.values.toSet());
  });
}
