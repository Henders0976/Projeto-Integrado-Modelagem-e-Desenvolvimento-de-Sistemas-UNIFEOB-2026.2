import { describe, expect, it } from "vitest";
import type { Peca } from "./catalogo";
import { filtrarVitrine, naFaixa } from "./filtro";

const peca = (id: string, preco: number | null, tamanhos = ["P", "M"], cor = "Preto"): Peca => ({
  id,
  nome: `Peça ${id}`,
  categoria: "blusas",
  tipo: "peca",
  descricao: "",
  preco,
  fotos: [],
  cores: [{ nome: cor, hue: 0 }],
  tamanhos,
});

const a = peca("a", 39.9, undefined, "Vinho");
const b = peca("b", 74.9, ["G"]);
const c = peca("c", null);
const d = peca("d", 109.9, undefined, "Vinho");
const e = peca("e", 74.9);
const todas = [a, b, c, d, e];
const ids = (l: Peca[]) => l.map((p) => p.id);

describe("filtro da vitrine (o mesmo do app)", () => {
  it("sem filtro devolve tudo na ordem original", () => {
    expect(ids(filtrarVitrine(todas, {}))).toEqual(["a", "b", "c", "d", "e"]);
  });

  it("tamanho, cor e faixa combinam", () => {
    expect(ids(filtrarVitrine(todas, { tamanho: "G" }))).toEqual(["b"]);
    expect(ids(filtrarVitrine(todas, { cor: "Vinho" }))).toEqual(["a", "d"]);
    expect(ids(filtrarVitrine(todas, { faixa: "50a80" }))).toEqual(["b", "e"]);
    expect(ids(filtrarVitrine(todas, { cor: "Vinho", faixa: "acima80" }))).toEqual(["d"]);
  });

  it("preço a combinar não entra em faixa e vai para o fim na ordem por preço", () => {
    expect(ids(filtrarVitrine(todas, { faixa: "ate50" }))).toEqual(["a"]);
    expect(ids(filtrarVitrine(todas, { ordem: "menor" }))).toEqual(["a", "b", "e", "d", "c"]);
    expect(ids(filtrarVitrine(todas, { ordem: "maior" }))).toEqual(["d", "b", "e", "a", "c"]);
  });

  it("não reordena a lista recebida", () => {
    filtrarVitrine(todas, { ordem: "maior" });
    expect(ids(todas)).toEqual(["a", "b", "c", "d", "e"]);
  });

  it("limites da faixa: 50 já é da segunda, 80 já é da terceira", () => {
    expect(naFaixa("ate50", 50)).toBe(false);
    expect(naFaixa("50a80", 50)).toBe(true);
    expect(naFaixa("acima80", 80)).toBe(true);
  });
});
