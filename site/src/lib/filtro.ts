import type { Peca } from "./catalogo";

/** Faixas de preço do filtro (as mesmas do app: lib/core/filtro_vitrine.dart). Peça "a combinar" não entra em nenhuma. */
export const FAIXAS = {
  ate50: { rotulo: "Até R$ 50", de: 0, ate: 50 },
  "50a80": { rotulo: "R$ 50 a R$ 80", de: 50, ate: 80 },
  acima80: { rotulo: "Acima de R$ 80", de: 80, ate: Infinity },
} as const;
export type Faixa = keyof typeof FAIXAS;

export const ORDENS = { destaque: "Destaque", menor: "Menor preço", maior: "Maior preço" } as const;
export type Ordem = keyof typeof ORDENS;

export const naFaixa = (f: Faixa, preco: number | null): boolean =>
  preco != null && preco >= FAIXAS[f].de && preco < FAIXAS[f].ate;

export interface Filtros {
  tamanho?: string | null;
  cor?: string | null;
  faixa?: Faixa | null;
  ordem?: Ordem | null;
}

/** Só muda o que aparece na tela. Na ordem por preço, as peças a combinar vão para o fim; o sort do JS é estável. */
export function filtrarVitrine(pecas: Peca[], { tamanho, cor, faixa, ordem }: Filtros): Peca[] {
  const lista = pecas.filter(
    (p) =>
      (!tamanho || p.tamanhos.includes(tamanho)) &&
      (!cor || p.cores.some((c) => c.nome === cor)) &&
      (!faixa || naFaixa(faixa, p.preco)),
  );
  if (ordem !== "menor" && ordem !== "maior") return lista;
  const sinal = ordem === "menor" ? 1 : -1;
  return lista.sort((a, b) => {
    if (a.preco == null || b.preco == null) return (a.preco == null ? 1 : 0) - (b.preco == null ? 1 : 0);
    return sinal * (a.preco - b.preco);
  });
}
