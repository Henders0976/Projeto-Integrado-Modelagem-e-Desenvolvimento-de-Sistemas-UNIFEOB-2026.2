/// Indicadores de uma lista de vendas: soma, média, maior e menor valor.
class IndicadoresVendas {
  const IndicadoresVendas({
    required this.quantidade,
    required this.soma,
    required this.media,
    required this.maior,
    required this.menor,
  });

  final int quantidade;
  final double soma, media, maior, menor;

  /// Percorre a lista com `for` (soma) e `while` (maior e menor).
  /// Devolve null se não houver vendas, pois média/maior/menor não existem.
  static IndicadoresVendas? calcular(List<double> vendas) {
    if (vendas.isEmpty) return null;

    double soma = 0;
    for (final v in vendas) {
      soma += v;
    }

    double maior = vendas[0];
    double menor = vendas[0];
    int i = 1;
    while (i < vendas.length) {
      if (vendas[i] > maior) maior = vendas[i];
      if (vendas[i] < menor) menor = vendas[i];
      i++;
    }

    return IndicadoresVendas(
      quantidade: vendas.length,
      soma: soma,
      media: soma / vendas.length,
      maior: maior,
      menor: menor,
    );
  }
}
