import { CATEGORIAS, type Categoria, type Peca } from "./catalogo";

export interface ResumoCategoria {
  categoria: Categoria;
  rotulo: string;
  quantidade: number;
  menor: number | null;
  maior: number | null;
}

export interface ResumoLoja {
  total: number;
  menor: number | null;
  maior: number | null;
  /** Quantas peças não têm preço ("Preço a combinar"). */
  aCombinar: number;
  /** Mais peças primeiro; empate pela ordem alfabética. */
  categorias: ResumoCategoria[];
  /** Tamanhos das roupas, do P para o G (os acessórios são "Único" e ficam de fora). */
  tamanhos: string[];
  acessorios: number;
  /** Nomes das cores; as que aparecem em mais peças vêm primeiro. */
  cores: string[];
}

const ORDEM_TAMANHO = ["PP", "P", "M", "G", "GG", "XG"];
const posicao = (t: string): number => {
  const i = ORDEM_TAMANHO.indexOf(t);
  return i === -1 ? ORDEM_TAMANHO.length : i;
};

const extremos = (lista: Peca[]): { menor: number | null; maior: number | null } => {
  const precos = lista.map((p) => p.preco).filter((v): v is number => v != null);
  return precos.length ? { menor: Math.min(...precos), maior: Math.max(...precos) } : { menor: null, maior: null };
};

/** Tudo o que a landing page conta sobre a loja, calculado do catálogo: nunca fica diferente do que está à venda. */
export function resumirCatalogo(pecas: Peca[]): ResumoLoja {
  const porCategoria = new Map<Categoria, Peca[]>();
  for (const p of pecas) porCategoria.set(p.categoria, [...(porCategoria.get(p.categoria) ?? []), p]);

  const categorias = [...porCategoria.entries()]
    .map(([categoria, lista]) => ({ categoria, rotulo: CATEGORIAS[categoria], quantidade: lista.length, ...extremos(lista) }))
    .sort((a, b) => b.quantidade - a.quantidade || a.rotulo.localeCompare(b.rotulo, "pt-BR"));

  const tamanhos = [...new Set(pecas.filter((p) => p.tipo === "peca").flatMap((p) => p.tamanhos))].sort(
    (a, b) => posicao(a) - posicao(b) || a.localeCompare(b, "pt-BR"),
  );

  // "Única" é o nome que o catálogo dá a uma peça sem cor informada: não é uma cor para listar.
  const contagem = new Map<string, number>();
  for (const p of pecas) for (const c of p.cores) if (c.nome !== "Única") contagem.set(c.nome, (contagem.get(c.nome) ?? 0) + 1);
  const cores = [...contagem.entries()].sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0], "pt-BR")).map(([nome]) => nome);

  return {
    total: pecas.length,
    ...extremos(pecas),
    aCombinar: pecas.filter((p) => p.preco == null).length,
    categorias,
    tamanhos,
    acessorios: pecas.filter((p) => p.tipo === "acessorio").length,
    cores,
  };
}

/** ["P", "M", "G"] -> "P, M e G". */
export function emFrase(itens: string[]): string {
  if (itens.length <= 1) return itens.join("");
  return `${itens.slice(0, -1).join(", ")} e ${itens[itens.length - 1]}`;
}

/** Mantém "R$ 109,90" numa peça só: o espaço entre o R$ e o valor não pode quebrar a linha. */
export const semQuebra = (texto: string): string => texto.replace(/R\$ /g, "R$ ");

/** "1 peça" / "6 peças". */
export const contar = (n: number, singular: string, plural: string): string => `${n} ${n === 1 ? singular : plural}`;

/** "R$ 49,90 a R$ 74,90", "R$ 109,90" quando só há um preço, ou null quando nenhuma peça tem preço. */
export function faixaDePreco(menor: number | null, maior: number | null, formatar: (v: number) => string): string | null {
  if (menor == null || maior == null) return null;
  return menor === maior ? formatar(menor) : `${formatar(menor)} a ${formatar(maior)}`;
}
