import 'package:flutter_test/flutter_test.dart';
import 'package:rvlabel_app/core/indicadores_vendas.dart';

void main() {
  test('calcula soma, média, maior e menor', () {
    final i = IndicadoresVendas.calcular(
        [189.90, 249.00, 99.90, 320.50, 149.90, 59.90, 410.00, 129.90])!;
    expect(i.quantidade, 8);
    expect(i.soma, closeTo(1609.00, 0.001));
    expect(i.media, closeTo(201.125, 0.001));
    expect(i.maior, 410.00);
    expect(i.menor, 59.90);
  });

  test('lista vazia devolve null', () {
    expect(IndicadoresVendas.calcular([]), isNull);
  });
}
