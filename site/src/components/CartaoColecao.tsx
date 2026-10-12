import { Link } from "react-router-dom";
import type { Colecao } from "@/lib/colecoes";
import { ParallaxFoto } from "./Efeitos";
import FotoPeca from "./FotoPeca";

/** Cartão da coleção na vitrine: foto grande com parallax, chamada no alto e título embaixo. */
export default function CartaoColecao({ colecao, foto }: { colecao: Colecao; foto?: string }) {
  return (
    <Link
      to={`/colecoes/${colecao.slug}`}
      className="group relative block aspect-[4/5] overflow-hidden rounded"
      aria-label={`Coleção ${colecao.titulo}`}
    >
      <div className="absolute inset-0 transition-transform duration-700 ease-out group-hover:scale-[1.04]">
        <ParallaxFoto className="h-full w-full" escala={1.15} intensidade={20}>
          <FotoPeca src={foto} alt="" posicao="50% 20%" loading="lazy" className="h-full w-full" />
        </ParallaxFoto>
      </div>
      <div className="absolute inset-0 bg-gradient-to-b from-black/40 via-black/10 to-preto/70" />
      <div className="absolute inset-0 flex flex-col justify-between p-7">
        <span className="text-[13px] uppercase tracking-[0.3em]">{colecao.chamada}</span>
        <h3 className="font-titulo text-[32px] leading-[1.1]">{colecao.titulo}</h3>
      </div>
    </Link>
  );
}
