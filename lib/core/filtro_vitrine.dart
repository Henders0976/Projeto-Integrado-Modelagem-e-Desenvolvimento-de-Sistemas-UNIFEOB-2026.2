import '../models/models.dart';

/// Faixas de preço do filtro da coleção. Peça com "preço a definir" não entra em faixa nenhuma.
enum FaixaPreco {
  ate50('Até R\$ 50', 0, 50),
  de50a80('R\$ 50 a R\$ 80', 50, 80),
  acima80('Acima de R\$ 80', 80, double.infinity);

  const FaixaPreco(this.rotulo, this.de, this.ate);
  final String rotulo;
  final double de;
  final double ate;

  bool contem(double? preco) => preco != null && preco >= de && preco < ate;
}

enum OrdemVitrine {
  destaque('Destaque'),
  menorPreco('Menor preço'),
  maiorPreco('Maior preço');

  const OrdemVitrine(this.rotulo);
  final String rotulo;
}

/// Aplica os filtros da barra da coleção. Só muda o que aparece na tela: o catálogo não muda.
/// Na ordem por preço, as peças com preço a definir vão para o fim.
List<Produto> filtrarVitrine(
  List<Produto> pecas, {
  String? tamanho,
  String? cor,
  FaixaPreco? faixa,
  OrdemVitrine ordem = OrdemVitrine.destaque,
}) {
  final lista = [
    for (final p in pecas)
      if ((tamanho == null || p.tamanhos.contains(tamanho)) &&
          (cor == null || p.cores.any((c) => c.nome == cor)) &&
          (faixa == null || faixa.contem(p.preco)))
        p,
  ];
  if (ordem == OrdemVitrine.destaque) return lista;
  final sinal = ordem == OrdemVitrine.menorPreco ? 1 : -1;
  // sort não é estável: o índice original desempata, para peças de mesmo preço não trocarem de lugar.
  final indice = {for (final (i, p) in lista.indexed) p: i};
  lista.sort((a, b) {
    final pa = a.preco, pb = b.preco;
    if (pa == null || pb == null) {
      if (pa == pb) return indice[a]!.compareTo(indice[b]!);
      return pa == null ? 1 : -1;
    }
    final c = sinal * pa.compareTo(pb);
    return c != 0 ? c : indice[a]!.compareTo(indice[b]!);
  });
  return lista;
}
