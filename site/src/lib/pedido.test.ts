import { describe, expect, it } from "vitest";
import { emailPlausivel, formatarReais, mensagemContato, mensagemNovidades, soDigitos, urlWhatsApp } from "./formato";
import { chaveItem, linhaPedido, mensagemPedido, totais, type ItemSacola } from "./pedido";

const item = (parcial: Partial<ItemSacola> = {}): ItemSacola => ({
  chave: chaveItem("essence-005", "Preto", "M"),
  id: "essence-005",
  nome: "Blusa Um Ombro Com Laço",
  preco: 72.9,
  cor: "Preto",
  tamanho: "M",
  quantidade: 2,
  ...parcial,
});

describe("formato", () => {
  it("formata reais com vírgula", () => {
    expect(formatarReais(89.9)).toBe("R$ 89,90");
    expect(formatarReais(72.9 * 3)).toBe("R$ 218,70"); // 218.70000000000002 no ponto flutuante
  });

  it("deixa só dígitos e barra e-mail com erro de digitação", () => {
    expect(soDigitos("(35) 99999-0000")).toBe("35999990000");
    expect(emailPlausivel(" ana@rv.com ")).toBe(true);
    expect(emailPlausivel("ana@rv")).toBe(false);
    expect(emailPlausivel("")).toBe(false);
  });

  it("monta as mensagens do WhatsApp com os dados da cliente", () => {
    expect(mensagemNovidades("ana@rv.com")).toContain("ana@rv.com");
    const m = mensagemContato({ nome: "Ana", email: "ana@rv.com", assunto: "Tamanho", mensagem: "Serve M?" });
    expect(m).toContain("Ana");
    expect(m).toContain("Serve M?");
    expect(urlWhatsApp("oi á", "5535999990000")).toBe("https://wa.me/5535999990000?text=oi%20%C3%A1");
  });
});

describe("pedido", () => {
  it("mesma peça, cor e tamanho têm a mesma chave", () => {
    expect(chaveItem("a", "Preto", "M")).toBe(chaveItem("a", "Preto", "M"));
    expect(chaveItem("a", "Preto", "M")).not.toBe(chaveItem("a", "Preto", "G"));
  });

  it("soma o total e marca itens a combinar", () => {
    const t = totais([item(), item({ id: "x", preco: null, quantidade: 1 })]);
    expect(t.quantidade).toBe(3);
    expect(t.total).toBeCloseTo(145.8);
    expect(t.pendente).toBe(true);
    expect(totais([item()]).pendente).toBe(false);
  });

  it("linha do pedido mostra o subtotal ou 'preço a combinar'", () => {
    expect(linhaPedido(item())).toBe("• 2x Blusa Um Ombro Com Laço (Preto, M) - R$ 145,80");
    expect(linhaPedido(item({ preco: null }))).toContain("preço a combinar");
  });

  it("mensagem do pedido leva número, linhas e total", () => {
    const m = mensagemPedido([item(), item({ nome: "Cinto", preco: null, quantidade: 1 })], 12);
    expect(m).toContain("(nº 12)");
    expect(m).toContain("• 2x Blusa Um Ombro Com Laço");
    expect(m).toContain("Total: R$ 145,80 + itens a combinar");
    expect(mensagemPedido([item()])).not.toContain("nº");
  });
});
