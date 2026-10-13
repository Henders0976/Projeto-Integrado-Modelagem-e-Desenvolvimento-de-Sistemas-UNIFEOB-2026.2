import '../models/models.dart';
import 'moeda.dart';

/// Quantas peças a categoria tem e quanto custam.
class ResumoCategoria {
  const ResumoCategoria(this.categoria, this.quantidade, this.menor, this.maior);

  final Categoria categoria;
  final int quantidade;
  final double? menor;
  final double? maior;
}

/// Tudo o que a home conta sobre a loja, calculado do catálogo: nunca fica diferente do que está à venda.
class ResumoLoja {
  const ResumoLoja({
    required this.total,
    required this.menor,
    required this.maior,
    required this.aCombinar,
    required this.categorias,
    required this.tamanhos,
    required this.acessorios,
    required this.cores,
  });

  final int total;
  final double? menor;
  final double? maior;

  /// Quantas peças não têm preço ("Preço a definir").
  final int aCombinar;

  /// Mais peças primeiro; empate pela ordem alfabética.
  final List<ResumoCategoria> categorias;

  /// Tamanhos das roupas, do P para o G (os acessórios são "Único" e ficam de fora).
  final List<String> tamanhos;
  final int acessorios;

  /// Nomes das cores; as que aparecem em mais peças vêm primeiro.
  final List<String> cores;
}

const _ordemTamanho = ['PP', 'P', 'M', 'G', 'GG', 'XG'];

int _posicao(String t) {
  final i = _ordemTamanho.indexOf(t);
  return i == -1 ? _ordemTamanho.length : i;
}

(double?, double?) _extremos(Iterable<Produto> lista) {
  final precos = [for (final p in lista) if (p.preco != null) p.preco!];
  if (precos.isEmpty) return (null, null);
  precos.sort();
  return (precos.first, precos.last);
}

ResumoLoja resumirCatalogo(List<Produto> pecas) {
  final porCategoria = <Categoria, List<Produto>>{};
  for (final p in pecas) {
    (porCategoria[p.categoria] ??= []).add(p);
  }
  final categorias = [
    for (final e in porCategoria.entries)
      ResumoCategoria(e.key, e.value.length, _extremos(e.value).$1, _extremos(e.value).$2),
  ]..sort((a, b) {
      final porQuantidade = b.quantidade.compareTo(a.quantidade);
      return porQuantidade != 0 ? porQuantidade : a.categoria.rotulo.compareTo(b.categoria.rotulo);
    });

  final tamanhos = {
    for (final p in pecas.where((p) => p is! Acessorio)) ...p.tamanhos,
  }.toList()
    ..sort((a, b) {
      final porPosicao = _posicao(a).compareTo(_posicao(b));
      return porPosicao != 0 ? porPosicao : a.compareTo(b);
    });

  // "Única" é o nome que o catálogo dá a uma peça sem cor informada: não é uma cor para listar.
  final contagem = <String, int>{};
  for (final p in pecas) {
    for (final c in p.cores) {
      if (c.nome != 'Única') contagem[c.nome] = (contagem[c.nome] ?? 0) + 1;
    }
  }
  final cores = contagem.entries.toList()
    ..sort((a, b) {
      final porFrequencia = b.value.compareTo(a.value);
      return porFrequencia != 0 ? porFrequencia : a.key.compareTo(b.key);
    });

  final (menor, maior) = _extremos(pecas);
  return ResumoLoja(
    total: pecas.length,
    menor: menor,
    maior: maior,
    aCombinar: pecas.where((p) => p.preco == null).length,
    categorias: categorias,
    tamanhos: tamanhos,
    acessorios: pecas.whereType<Acessorio>().length,
    cores: [for (final c in cores) c.key],
  );
}

/// ['P', 'M', 'G'] -> "P, M e G".
String emFrase(List<String> itens) {
  if (itens.length <= 1) return itens.join();
  return '${itens.sublist(0, itens.length - 1).join(', ')} e ${itens.last}';
}

/// "1 peça" / "6 peças".
String contar(int n, String singular, String plural) => '$n ${n == 1 ? singular : plural}';

/// "R$ 49,90 a R$ 74,90", "R$ 109,90" quando só há um preço, ou null quando nenhuma peça tem preço.
String? faixaDePreco(double? menor, double? maior) {
  if (menor == null || maior == null) return null;
  return menor == maior ? formatarReais(menor) : '${formatarReais(menor)} a ${formatarReais(maior)}';
}
