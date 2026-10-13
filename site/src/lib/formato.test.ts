import { describe, expect, it } from "vitest";
import { CNPJ, EMAIL_CONTATO, emailPlausivel, soDigitos } from "./formato";

/** Confere os dois dígitos verificadores do CNPJ (módulo 11). */
function cnpjValido(texto: string): boolean {
  const d = soDigitos(texto).split("").map(Number);
  if (d.length !== 14 || new Set(d).size === 1) return false;
  const dv = (n: number) => {
    const pesos = n === 12 ? [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2] : [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    const resto = d.slice(0, n).reduce((soma, x, i) => soma + x * pesos[i], 0) % 11;
    return resto < 2 ? 0 : 11 - resto;
  };
  return dv(12) === d[12] && dv(13) === d[13];
}

describe("identificação da loja", () => {
  it("o CNPJ do rodapé e da privacidade tem os dígitos verificadores certos", () => {
    expect(cnpjValido(CNPJ)).toBe(true);
    expect(CNPJ).toMatch(/^\d{2}\.\d{3}\.\d{3}\/\d{4}-\d{2}$/);
  });

  it("o validador recusa um dígito trocado", () => {
    expect(cnpjValido("68.647.856/0001-98")).toBe(false);
  });

  it("o e-mail de contato é um e-mail plausível", () => {
    expect(emailPlausivel(EMAIL_CONTATO)).toBe(true);
  });
});
