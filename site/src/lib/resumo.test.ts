import { describe, expect, it } from "vitest";
import type { Peca } from "./catalogo";
import { contar, emFrase, faixaDePreco, resumirCatalogo, semQuebra } from "./resumo";

const reais = (v: number) => `R$ ${v.toFixed(2).replace(".", ",")}`;

const peca = (extra: Partial<Peca> & { id: string }): Peca => ({
  nome: extra.id,
  categoria: "blusas",
  tipo: "peca",
  descricao: "",
  preco: 50,
  fotos: [],
  cores: [{ nome: "Preto", hue: 0 }],
  tamanhos: ["P", "M", "G"],
  ...extra,
});

describe("resumo do catálogo", () => {
  const catalogo = [
    peca({ id: "a", categoria: "bodys", preco: 49.9, cores: [{ nome: "Preto", hue: 0 }, { nome: "Vinho", hue: 0 }] }),
    peca({ id: "b", categoria: "bodys", preco: 74.9, cores: [{ nome: "Preto", hue: 0 }] }),
    peca({ id: "c", categoria: "blusas", preco: 39.9, cores: [{ nome: "Branco", hue: 0 }] }),
    peca({ id: "d", categoria: "vestidos", preco: 109.9, tamanhos: ["P", "M", "G", "GG"], cores: [{ nome: "Única", hue: 0 }] }),
    peca({ id: "e", categoria: "acessorios", tipo: "acessorio", preco: 29.9, tamanhos: ["Único"], cores: [{ nome: "Prateado", hue: 0 }] }),
    peca({ id: "f", categoria: "tops", preco: null }),
  ];
  const r = resumirCatalogo(catalogo);

  it("conta, tira a faixa de preço e separa o que não tem preço", () => {
    expect(r.total).toBe(6);
    expect([r.menor, r.maior]).toEqual([29.9, 109.9]);
    expect(r.aCombinar).toBe(1);
  });

  it("ordena as categorias por quantidade e depois por nome, cada uma com o seu preço", () => {
    expect(r.categorias.map((c) => c.rotulo)).toEqual(["Bodys", "Acessórios", "Blusas", "Tops", "Vestidos"]);
    expect(r.categorias[0]).toMatchObject({ categoria: "bodys", quantidade: 2, menor: 49.9, maior: 74.9 });
    expect(r.categorias.find((c) => c.categoria === "tops")).toMatchObject({ quantidade: 1, menor: null, maior: null });
  });

  it("tamanhos só das roupas, do P ao G (o acessório 'Único' fica de fora)", () => {
    expect(r.tamanhos).toEqual(["P", "M", "G", "GG"]);
    expect(r.acessorios).toBe(1);
  });

  it("cores: as mais frequentes primeiro, sem a 'Única' do catálogo", () => {
    expect(r.cores).toEqual(["Preto", "Branco", "Prateado", "Vinho"]);
  });

  it("catálogo vazio não quebra", () => {
    expect(resumirCatalogo([])).toMatchObject({ total: 0, menor: null, maior: null, categorias: [], tamanhos: [], cores: [] });
  });
});

describe("textos do resumo", () => {
  it("monta frases com 'e' no fim", () => {
    expect(emFrase([])).toBe("");
    expect(emFrase(["P"])).toBe("P");
    expect(emFrase(["P", "M"])).toBe("P e M");
    expect(emFrase(["P", "M", "G"])).toBe("P, M e G");
  });

  it("singular e plural", () => {
    expect(contar(1, "peça", "peças")).toBe("1 peça");
    expect(contar(6, "peça", "peças")).toBe("6 peças");
    expect(contar(0, "peça", "peças")).toBe("0 peças");
  });

  it("o preço não quebra entre o R$ e o valor, mas pode quebrar entre os dois preços", () => {
    expect(semQuebra("de R$ 29,90 a R$ 109,90")).toBe("de R$ 29,90 a R$ 109,90");
    expect(semQuebra("sem preço")).toBe("sem preço");
  });

  it("faixa de preço: intervalo, preço único ou nada", () => {
    expect(faixaDePreco(49.9, 74.9, reais)).toBe("R$ 49,90 a R$ 74,90");
    expect(faixaDePreco(109.9, 109.9, reais)).toBe("R$ 109,90");
    expect(faixaDePreco(null, null, reais)).toBeNull();
  });
});
