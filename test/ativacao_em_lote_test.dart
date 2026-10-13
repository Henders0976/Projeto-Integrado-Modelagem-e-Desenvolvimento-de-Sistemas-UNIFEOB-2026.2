import 'package:flutter_test/flutter_test.dart';
import 'package:rvlabel_app/core/ativacao_em_lote.dart';

List<Map<String, dynamic>> _produtos() => [
      {'codigo': 'a', 'ativo': false},
      {'codigo': 'b', 'ativo': true},
      {'codigo': 'c', 'ativo': false},
      {'codigo': 'd', 'ativo': false},
    ];

void main() {
  test('ativa só os marcados que estavam desativados e pula quem já estava ativo', () async {
    final chamadas = <String>[];
    final r = await aplicarAtivo(
      produtos: _produtos(),
      codigos: {'a', 'b', 'c'},
      ativo: true,
      alterar: (codigo, ativo) async => chamadas.add('$codigo=$ativo'),
    );
    expect(chamadas, ['a=true', 'c=true']); // "d" não estava marcado, "b" já estava ativo
    expect([r.alterados, r.jaEstavam, r.falhas], [2, 1, isEmpty]);
  });

  test('desativa os marcados que estavam ativos', () async {
    final chamadas = <String>[];
    final r = await aplicarAtivo(
      produtos: _produtos(),
      codigos: {'a', 'b'},
      ativo: false,
      alterar: (codigo, ativo) async => chamadas.add('$codigo=$ativo'),
    );
    expect(chamadas, ['b=false']);
    expect([r.alterados, r.jaEstavam], [1, 1]);
  });

  test('um erro num produto não impede os outros, e vem listado', () async {
    final r = await aplicarAtivo(
      produtos: _produtos(),
      codigos: {'a', 'c', 'd'},
      ativo: true,
      alterar: (codigo, ativo) async {
        if (codigo == 'c') throw Exception('sem conexão');
      },
    );
    expect([r.alterados, r.falhas], [2, ['c']]);
  });

  test('nenhum marcado: nada é chamado', () async {
    final r = await aplicarAtivo(
      produtos: _produtos(),
      codigos: {},
      ativo: true,
      alterar: (_, __) async => fail('não devia chamar'),
    );
    expect([r.alterados, r.jaEstavam, r.falhas], [0, 0, isEmpty]);
  });

  test('frase do aviso', () {
    const cheio = ResultadoLote(alterados: 3, jaEstavam: 1, falhas: ['x']);
    expect(resumoDoLote(cheio, ativo: true), '3 ativados; 1 já estava assim; 1 com erro (x).');
    expect(resumoDoLote(const ResultadoLote(alterados: 1, jaEstavam: 0, falhas: []), ativo: false), '1 desativado.');
    expect(resumoDoLote(const ResultadoLote(alterados: 0, jaEstavam: 2, falhas: []), ativo: true), '2 já estavam assim.');
    expect(resumoDoLote(const ResultadoLote(alterados: 0, jaEstavam: 0, falhas: []), ativo: true), 'Nada foi alterado.');
  });
}
