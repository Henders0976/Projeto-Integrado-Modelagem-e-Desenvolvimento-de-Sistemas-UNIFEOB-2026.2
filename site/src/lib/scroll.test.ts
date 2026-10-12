import { describe, expect, it } from "vitest";
import { calcularProgresso, easeOutCubic } from "./scroll";

describe("calcularProgresso (tela de 800 px)", () => {
  it("elemento ainda fora da tela: entrada 0", () => {
    expect(calcularProgresso(900, 100, 800).entrada).toBe(0);
    expect(calcularProgresso(760, 100, 800).entrada).toBe(0); // exatamente a 95%
  });

  it("elemento que subiu até a metade da tela: entrada 1", () => {
    expect(calcularProgresso(400, 100, 800).entrada).toBe(1);
    expect(calcularProgresso(50, 100, 800).entrada).toBe(1);
  });

  it("entre os dois pontos, a entrada anda proporcionalmente", () => {
    // 760 -> 0 e 400 -> 1: no meio (580) dá 0.5
    expect(calcularProgresso(580, 100, 800).entrada).toBeCloseTo(0.5);
  });

  it("centro: 0 no meio da tela, negativo acima e positivo abaixo, limitado a ±1", () => {
    expect(calcularProgresso(350, 100, 800).centro).toBeCloseTo(0);
    expect(calcularProgresso(-500, 100, 800).centro).toBeLessThan(0);
    expect(calcularProgresso(2000, 100, 800).centro).toBe(1);
    expect(calcularProgresso(-2000, 100, 800).centro).toBe(-1);
  });

  it("easeOutCubic vai de 0 a 1 e é mais rápido no começo", () => {
    expect(easeOutCubic(0)).toBe(0);
    expect(easeOutCubic(1)).toBe(1);
    expect(easeOutCubic(0.5)).toBeGreaterThan(0.5);
  });
});
