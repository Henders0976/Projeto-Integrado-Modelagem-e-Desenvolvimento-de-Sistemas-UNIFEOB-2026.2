import { describe, expect, it } from "vitest";
import { deltaEmPixels, eRodaDoMouse, proximoAlvo } from "./rolagemSuave";

describe("rolagem suave", () => {
  it("converte linhas e páginas da roda em pixels", () => {
    expect(deltaEmPixels(100, 0, 800)).toBe(100);
    expect(deltaEmPixels(3, 1, 800)).toBe(120);
    expect(deltaEmPixels(1, 2, 800)).toBe(800);
  });

  it("suaviza a roda do mouse e deixa o touchpad em paz", () => {
    expect(eRodaDoMouse({ deltaY: 100, deltaMode: 0, wheelDeltaY: -120 })).toBe(true); // um clique da roda
    expect(eRodaDoMouse({ deltaY: 3, deltaMode: 0, wheelDeltaY: -9 })).toBe(false); // touchpad
    expect(eRodaDoMouse({ deltaY: 57, deltaMode: 0, wheelDeltaY: -171 })).toBe(false); // flick de touchpad
    expect(eRodaDoMouse({ deltaY: 3, deltaMode: 1 })).toBe(true); // Firefox: linhas
    expect(eRodaDoMouse({ deltaY: 100, deltaMode: 0 })).toBe(true); // sem wheelDeltaY: pelo tamanho do passo
    expect(eRodaDoMouse({ deltaY: 4, deltaMode: 0 })).toBe(false);
  });

  it("cliques seguidos se somam e o alvo respeita o início e o fim da página", () => {
    const primeiro = proximoAlvo(0, null, 100, 1000);
    expect(primeiro).toBe(100);
    expect(proximoAlvo(40, primeiro, 100, 1000)).toBe(200); // a animação ainda corre: soma ao alvo, não à posição
    expect(proximoAlvo(950, null, 100, 1000)).toBe(1000);
    expect(proximoAlvo(30, null, -100, 1000)).toBe(0);
    expect(proximoAlvo(0, null, 100, -5)).toBe(0); // página mais curta que a tela
  });
});
