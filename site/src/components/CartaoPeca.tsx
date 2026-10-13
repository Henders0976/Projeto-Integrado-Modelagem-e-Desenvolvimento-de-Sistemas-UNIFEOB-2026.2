import { ArrowRight } from "lucide-react";
import { Link, useViewTransitionState } from "react-router-dom";
import { precoTexto, type Peca } from "@/lib/catalogo";
import { formatarReais } from "@/lib/formato";
import FotoPeca from "./FotoPeca";

/**
 * Cartão da vitrine: a foto dá zoom no hover, aparece "Ver peça" e as cores aparecem como bolinhas.
 * Ao abrir a peça a foto "voa" até a página dela (View Transitions; onde o navegador não tem, só troca de página).
 * `transicao={false}` desliga isso (cartões dentro da própria página de uma peça: dois "foto-peca" na tela anulam a transição).
 */
export default function CartaoPeca({ peca, transicao = true }: { peca: Peca; transicao?: boolean }) {
  const foto = peca.fotos[0];
  const destino = `/peca/${peca.id}`;
  const voando = useViewTransitionState(destino);
  return (
    <Link
      to={destino}
      viewTransition={transicao}
      className="group block"
    >
      <div
        className="relative aspect-[4/5] overflow-hidden rounded shadow-[0_6px_14px_rgba(0,0,0,0.16)] transition duration-300 group-hover:-translate-y-1.5 group-hover:shadow-[0_16px_30px_rgba(0,0,0,0.45)]"
        style={transicao && voando ? { viewTransitionName: "foto-peca" } : undefined}
      >
        <FotoPeca
          src={foto}
          cor={peca.cores[0]}
          alt=""
          className="h-full w-full transition-transform duration-500 group-hover:scale-[1.07]"
        />
        <div aria-hidden className="pointer-events-none absolute inset-x-0 bottom-0 flex translate-y-full items-center justify-center gap-2 bg-gradient-to-b from-transparent to-preto/80 py-3.5 text-xs font-semibold tracking-[0.25em] opacity-0 transition duration-300 group-hover:translate-y-0 group-hover:opacity-100">
          VER PEÇA <ArrowRight className="h-3.5 w-3.5" aria-hidden />
        </div>
      </div>
      <h3 className="mt-3.5 font-titulo text-[19px] leading-tight">{peca.nome}</h3>
      <p className="mt-1 text-sm tabular-nums text-suave">{precoTexto(peca, formatarReais)}</p>
      {peca.cores.length > 1 && (
        <div className="mt-2 flex items-center gap-1.5">
          {peca.cores.slice(0, 5).map((c) => (
            <span key={c.nome} title={c.nome} className="relative inline-block h-3.5 w-3.5 overflow-hidden rounded-full ring-1 ring-linha">
              <FotoPeca src={foto} cor={c} alt="" posicao="50% 35%" className="absolute inset-0 h-full w-full scale-[4]" />
            </span>
          ))}
          {peca.cores.length > 5 && <span className="text-xs text-suave">+{peca.cores.length - 5}</span>}
        </div>
      )}
    </Link>
  );
}
