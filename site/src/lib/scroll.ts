/** Posição de um elemento na tela, para as animações ligadas à rolagem (scroll-linked). */
export interface Progresso {
  /** 0 = o topo do elemento está a 95% da altura da tela (acabou de aparecer); 1 = já chegou a 50%. */
  entrada: number;
  /** -1 = centro do elemento acima do meio da tela; 0 = no meio; 1 = abaixo. */
  centro: number;
}

const limitar = (v: number, min: number, max: number): number => Math.min(max, Math.max(min, v));

export function calcularProgresso(topo: number, altura: number, alturaTela: number): Progresso {
  return {
    entrada: limitar((alturaTela * 0.95 - topo) / (alturaTela * 0.45), 0, 1),
    centro: limitar((topo + altura / 2 - alturaTela / 2) / alturaTela, -1, 1),
  };
}

export const easeOutCubic = (t: number): number => 1 - Math.pow(1 - t, 3);

export const reduzirMovimento = (): boolean =>
  typeof window !== "undefined" && !!window.matchMedia?.("(prefers-reduced-motion: reduce)").matches;

type Alvo = { el: Element; aplicar: (p: Progresso) => void };
const alvos = new Set<Alvo>();
let agendado = false;

function medir(): void {
  agendado = false;
  const h = window.innerHeight;
  alvos.forEach((a) => {
    const r = a.el.getBoundingClientRect();
    a.aplicar(calcularProgresso(r.top, r.height, h));
  });
}

function agendar(): void {
  if (agendado) return;
  agendado = true;
  requestAnimationFrame(medir);
}

/**
 * Chama [aplicar] a cada frame de rolagem com a posição de [el]. Um único listener serve todos os
 * elementos. Meça um elemento que NÃO se move (o movimento vai num filho), senão ele mede a si mesmo.
 * Devolve a função que para de observar.
 */
export function observar(el: Element, aplicar: (p: Progresso) => void): () => void {
  if (alvos.size === 0) {
    window.addEventListener("scroll", agendar, { passive: true });
    window.addEventListener("resize", agendar);
  }
  const alvo: Alvo = { el, aplicar };
  alvos.add(alvo);
  agendar();
  return () => {
    alvos.delete(alvo);
    if (alvos.size === 0) {
      window.removeEventListener("scroll", agendar);
      window.removeEventListener("resize", agendar);
    }
  };
}
