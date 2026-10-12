import 'dart:convert';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rvlabel_app/models/models.dart';
import 'package:rvlabel_app/services/catalogo_repository.dart';
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

  test('catálogo ignora peça com categoria desconhecida em vez de quebrar', () {
    final catalogo = CatalogoRepository.deJson({
      'pecas': [
        {'id': 'ok-1', 'nome': 'Blusa', 'categoria': 'blusas', 'preco': 10.0},
        {'id': 'demo-1', 'nome': 'Body Canelado', 'categoria': 'Body', 'preco': 79.9},
      ],
    });
    expect(catalogo.todas().map((p) => p.id), ['ok-1']);
  });

  test('peça com ativo=false fica fora da vitrine, mas a foto continua disponível', () {
    final catalogo = CatalogoRepository.deJson({
      'pecas': [
        {'id': 'a', 'nome': 'Blusa', 'categoria': 'blusas', 'preco': 10.0, 'fotos': ['assets/fotos/a.jpg']},
        {'id': 'b', 'nome': 'Top', 'categoria': 'tops', 'preco': 20.0, 'ativo': false, 'fotos': ['assets/fotos/b.jpg']},
      ],
    });
    expect(catalogo.todas().map((p) => p.id), ['a']); // sem "ativo" = ativa (é o formato da API)
    expect(catalogo.buscarPorId('b'), isNull);
    expect(catalogo.fotos(), ['assets/fotos/a.jpg', 'assets/fotos/b.jpg']);
  });

  test('o catálogo embutido vem todo desativado: quem decide o que aparece é a administradora', () {
    final bruto = jsonDecode(File('assets/catalogo.json').readAsStringSync()) as Map<String, dynamic>;
    final pecas = bruto['pecas'] as List;
    expect(pecas, isNotEmpty);
    expect(pecas.every((p) => p['ativo'] == false), isTrue);
    final catalogo = CatalogoRepository.deJson(bruto);
    expect(catalogo.todas(), isEmpty);
    expect(catalogo.fotos(), isNotEmpty); // o formulário de novo produto continua com fotos para escolher
  });

  test('toda categoria do catálogo cai em alguma coleção', () {
    final cobertas = colecoes.expand((c) => c.categorias).toSet();
    expect(cobertas, Categoria.values.toSet());
  });
}
