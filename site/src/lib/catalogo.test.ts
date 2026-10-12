import { describe, expect, it, vi } from "vitest";
import { normalizarCatalogo, urlFoto } from "./catalogo";
import { COLECOES, pecasDaColecao, primeiraFoto } from "./colecoes";

const peca = (extra: Record<string, unknown> = {}) => ({
  id: "essence-005",
  nome: "Blusa",
  categoria: "blusas",
  preco: 72.9,
  fotos: ["assets/fotos/blusa.jpg"],
  cores: [{ nome: "Preto" }, { nome: "Vinho", tom: "#7A1020" }],
  ...extra,
});

describe("catálogo", () => {
  it("troca o caminho de foto do app pela URL do site", () => {
    expect(urlFoto("assets/fotos/x.jpg")).toBe("/fotos/x.jpg");
    expect(urlFoto("https://exemplo.com/x.jpg")).toBe("https://exemplo.com/x.jpg");
  });

  it("normaliza peça, cores e tamanhos padrão", () => {
    const [p] = normalizarCatalogo({ pecas: [peca()] });
    expect(p.fotos).toEqual(["/fotos/blusa.jpg"]);
    expect(p.cores[1]).toEqual({ nome: "Vinho", hue: 0, tom: "#7A1020" });
    expect(p.tamanhos).toEqual(["P", "M", "G"]);
    expect(p.preco).toBe(72.9);
  });

  it("acessório tem tamanho único e preço ausente vira 'a combinar'", () => {
    const [p] = normalizarCatalogo({ pecas: [peca({ tipo: "acessorio", tamanhos: ["P"], preco: null, cores: [] })] });
    expect(p.tamanhos).toEqual(["Único"]);
    expect(p.preco).toBeNull();
    expect(p.cores).toEqual([{ nome: "Única", hue: 0 }]);
  });

  it("ignora peça com categoria desconhecida em vez de quebrar (caso real: 'Body')", () => {
    const aviso = vi.spyOn(console, "warn").mockImplementation(() => {});
    const pecas = normalizarCatalogo({ pecas: [peca(), peca({ id: "demo-1", categoria: "Body" })] });
    expect(pecas.map((p) => p.id)).toEqual(["essence-005"]);
    aviso.mockRestore();
  });

  it("rejeita JSON sem a lista de peças", () => {
    expect(() => normalizarCatalogo({})).toThrow();
    expect(() => normalizarCatalogo(null)).toThrow();
  });
});

describe("coleções", () => {
  it("toda categoria cai em alguma coleção", () => {
    const cobertas = new Set(COLECOES.flatMap((c) => c.categorias));
    expect([...cobertas].sort()).toEqual(["acessorios", "blusas", "bodys", "shorts", "tops", "vestidos"]);
  });

  it("filtra as peças da coleção e acha a primeira foto", () => {
    const pecas = normalizarCatalogo({
      pecas: [peca({ id: "a", fotos: [] }), peca({ id: "b", categoria: "vestidos" }), peca({ id: "c", categoria: "tops" })],
    });
    const cima = pecasDaColecao(COLECOES[0], pecas);
    expect(cima.map((p) => p.id)).toEqual(["a", "c"]);
    expect(primeiraFoto(cima)).toBe("/fotos/blusa.jpg");
    expect(primeiraFoto([])).toBeUndefined();
  });
});
