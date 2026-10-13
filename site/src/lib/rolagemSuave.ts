import { easeOutCubic, reduzirMovimento } from "./scroll";

/** Mesma duração do ControladorSuave do app (lib/ui/rolagem_suave.dart). */
const DURACAO_MS = 480;

/** Delta da roda em pixels: "linhas" e "páginas" (Firefox, alguns drivers) viram px. */
export function deltaEmPixels(deltaY: number, deltaMode: number, alturaTela: number): number {
  return deltaMode === 1 ? deltaY * 40 : deltaMode === 2 ? deltaY * alturaTela : deltaY;
}

/**
 * Roda de mouse (passos grandes e certinhos) ou touchpad (muitos eventos pequenos, que já têm inércia própria)?
 * Só a roda do mouse é suavizada: no touchpad, animar por cima só atrasa o dedo.
 * shortcut: no Chrome/Edge/Safari a roda manda wheelDeltaY múltiplo de 120; no Firefox cai no tamanho do passo. Trocar por
 * uma detecção melhor se algum mouse de alta resolução ficar de fora.
 */
export function eRodaDoMouse(e: { deltaY: number; deltaMode: number; wheelDeltaY?: number }): boolean {
  if (e.deltaMode !== 0) return true;
  if (typeof e.wheelDeltaY === "number" && e.wheelDeltaY !== 0) return e.wheelDeltaY % 120 === 0;
  return Math.abs(e.deltaY) >= 50;
}

/** Cliques seguidos se somam: o alvo parte do alvo anterior (se a animação ainda corre) ou da posição atual. */
export function proximoAlvo(atual: number, alvoEmCurso: number | null, delta: number, maximo: number): number {
  return Math.min(Math.max(maximo, 0), Math.max(0, (alvoEmCurso ?? atual) + delta));
}

/** O elemento sob o mouse (ou um ancestral) tem rolagem própria que ainda anda nessa direção? Então deixa o navegador rolar. */
function temRolagemPropria(alvo: EventTarget | null, deltaY: number): boolean {
  let el = alvo instanceof Element ? alvo : null;
  for (; el && el !== document.documentElement && el !== document.body; el = el.parentElement) {
    const { overflowY } = getComputedStyle(el);
    if ((overflowY === "auto" || overflowY === "scroll") && el.scrollHeight > el.clientHeight) {
      const noTopo = el.scrollTop <= 0;
      const noFim = el.scrollTop + el.clientHeight >= el.scrollHeight - 1;
      if (!(deltaY < 0 && noTopo) && !(deltaY > 0 && noFim)) return true;
    }
  }
  return false;
}

/**
 * Rolagem fluida da roda do mouse, como no app: sem isto cada "clique" da roda pula a distância de uma vez.
 * Aqui cada clique vira um alvo, os cliques seguidos se somam e a tela desliza até ele com desaceleração.
 * Não age com "reduzir movimento", com Ctrl (zoom), em rolagem horizontal, com a página travada (overlay aberto)
 * nem dentro de caixas que rolam sozinhas. Devolve a função que desliga tudo.
 */
export function ativarRolagemSuave(): () => void {
  if (typeof window === "undefined" || reduzirMovimento()) return () => {};

  let alvo: number | null = null;
  let quadro = 0;
  let de = 0;
  let para = 0;
  let inicio = 0;
  let ultimo = 0; // onde NÓS deixamos a página no último frame

  const passo = (agora: number) => {
    const t = Math.min(1, (agora - inicio) / DURACAO_MS);
    // "instant" vale por cima do scroll-behavior: smooth do CSS, que brigaria com a animação.
    window.scrollTo({ top: de + (para - de) * easeOutCubic(t), behavior: "instant" });
    ultimo = window.scrollY;
    if (t < 1) {
      quadro = requestAnimationFrame(passo);
    } else {
      quadro = 0;
      alvo = null;
    }
  };

  const aoRodar = (e: WheelEvent) => {
    if (e.defaultPrevented || e.ctrlKey || Math.abs(e.deltaX) > Math.abs(e.deltaY) || !eRodaDoMouse(e)) return;
    if (document.body.style.overflow === "hidden" || temRolagemPropria(e.target, e.deltaY)) return;
    e.preventDefault();
    const maximo = document.documentElement.scrollHeight - window.innerHeight;
    alvo = proximoAlvo(window.scrollY, alvo, deltaEmPixels(e.deltaY, e.deltaMode, window.innerHeight), maximo);
    de = window.scrollY;
    para = alvo;
    inicio = performance.now();
    if (!quadro) quadro = requestAnimationFrame(passo);
  };

  // Alguém mais rolou (teclado, barra de rolagem, âncora, troca de página): a animação em curso deixa de valer.
  const aoRolar = () => {
    if (quadro && Math.abs(window.scrollY - ultimo) > 2) {
      cancelAnimationFrame(quadro);
      quadro = 0;
    }
    if (!quadro) alvo = null;
  };

  window.addEventListener("wheel", aoRodar, { passive: false });
  window.addEventListener("scroll", aoRolar, { passive: true });
  return () => {
    window.removeEventListener("wheel", aoRodar);
    window.removeEventListener("scroll", aoRolar);
    cancelAnimationFrame(quadro);
  };
}
