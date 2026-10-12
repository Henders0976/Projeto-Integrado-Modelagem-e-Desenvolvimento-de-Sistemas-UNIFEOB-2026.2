import { useEffect, useRef, type ReactNode } from "react";
import { easeOutCubic, observar, reduzirMovimento } from "@/lib/scroll";

interface AoRolarProps {
  children: ReactNode;
  /** De onde o conteúdo vem, em px (padrão: de baixo). */
  dx?: number;
  dy?: number;
  /** 0 a 0.5: atrasa a entrada deste item em relação aos vizinhos, para uma fileira entrar em sequência. */
  escalonar?: number;
  className?: string;
}

/**
 * Animação ligada à rolagem (scroll-linked): o conteúdo vem de (dx, dy), aparece e cresce conforme
 * entra na tela, e desfaz o movimento se a pessoa rolar de volta. Mesma ideia do AoRolar do app.
 */
export function AoRolar({ children, dx = 0, dy = 64, escalonar = 0, className = "" }: AoRolarProps) {
  const medida = useRef<HTMLDivElement>(null); // parado: é ele que se mede
  const movel = useRef<HTMLDivElement>(null); // recebe o movimento

  useEffect(() => {
    const m = medida.current;
    const v = movel.current;
    if (!m || !v) return;
    const mostrar = (t: number) => {
      v.style.opacity = String(t);
      v.style.transform = t >= 0.999 ? "none" : `translate3d(${dx * (1 - t)}px, ${dy * (1 - t)}px, 0) scale(${0.9 + 0.1 * t})`;
    };
    if (reduzirMovimento()) return mostrar(1);
    return observar(m, ({ entrada }) => {
      const e = Math.min(1, Math.max(0, (entrada - escalonar) / (1 - escalonar)));
      mostrar(easeOutCubic(e));
    });
  }, [dx, dy, escalonar]);

  return (
    <div ref={medida} className={className}>
      <div
        ref={movel}
        className="ao-rolar h-full"
        style={{ opacity: 0, transform: `translate3d(${dx}px, ${dy}px, 0) scale(0.9)` }}
      >
        {children}
      </div>
    </div>
  );
}

interface ParallaxProps {
  children: ReactNode;
  /** Quantos px a foto desliza para cada lado. */
  intensidade?: number;
  /** Ampliação da foto: precisa cobrir o deslize, senão aparecem as bordas. */
  escala?: number;
  className?: string;
}

/** Foto com parallax: anda mais devagar que a página. O contêiner recorta (overflow hidden). */
export function ParallaxFoto({ children, intensidade = 20, escala = 1.15, className = "" }: ParallaxProps) {
  const caixa = useRef<HTMLDivElement>(null);
  const foto = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const c = caixa.current;
    const f = foto.current;
    if (!c || !f || reduzirMovimento()) return;
    return observar(c, ({ centro }) => {
      f.style.transform = `translate3d(0, ${-centro * intensidade}px, 0) scale(${escala})`;
    });
  }, [intensidade, escala]);

  return (
    <div ref={caixa} className={`${/\babsolute\b/.test(className) ? "" : "relative"} overflow-hidden ${className}`}>
      <div ref={foto} className="absolute inset-0 will-change-transform" style={{ transform: `scale(${escala})` }}>
        {children}
      </div>
    </div>
  );
}
