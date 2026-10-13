import { useParams } from "react-router-dom";
import CartaoPeca from "@/components/CartaoPeca";
import { AoRolar, ParallaxFoto } from "@/components/Efeitos";
import FotoPeca from "@/components/FotoPeca";
import { useCatalogo } from "@/context/Catalogo";
import { useTitulo } from "@/hooks/useTitulo";
import { COLECOES, pecasDaColecao, primeiraFoto } from "@/lib/colecoes";
import NaoEncontrada from "./NaoEncontrada";

/** Página de uma coleção: foto grande com título, texto, grade de peças e um fecho. */
export default function Colecao() {
  const { slug } = useParams();
  const colecao = COLECOES.find((c) => c.slug === slug);
  const { pecas, carregando } = useCatalogo();
  useTitulo(colecao?.titulo);

  if (!colecao) return <NaoEncontrada />;
  const daColecao = pecasDaColecao(colecao, pecas);

  return (
    <>
      <section className="relative h-[50vh] min-h-[300px] max-h-[520px] w-full overflow-hidden">
        <ParallaxFoto className="absolute inset-0" intensidade={70} escala={1.3}>
          <FotoPeca src={primeiraFoto(daColecao)} alt="" posicao="50% 6%" loading="eager" className="h-full w-full" />
        </ParallaxFoto>
        <div className="absolute inset-0 bg-black/45" />
        <div className="absolute inset-0 flex flex-col items-center justify-center px-6 text-center">
          <p className="text-[13px] uppercase tracking-[0.35em]">{colecao.chamada}</p>
          <h1 className="mt-3.5 text-[42px] leading-tight">{colecao.titulo}</h1>
        </div>
      </section>

      <AoRolar className="mx-auto max-w-[760px] px-6 pt-16 text-center">
        <h2 className="text-[34px] leading-tight">{colecao.frase}</h2>
        <div className="mt-6 space-y-4">
          {colecao.textos.map((t) => (
            <p key={t} className="text-[17px] leading-[1.6]">{t}</p>
          ))}
        </div>
      </AoRolar>

      <section className="mx-auto max-w-[1100px] px-6 pt-12" aria-label={`Peças: ${colecao.titulo}`}>
        {carregando && <p className="min-h-[100svh] text-center text-suave">Carregando…</p>}
        {!carregando && daColecao.length === 0 && <p className="text-center text-suave">Ainda não temos peças nessa coleção.</p>}
        <div className="grid grid-cols-2 gap-x-4 gap-y-10 md:grid-cols-3 lg:grid-cols-4">
          {daColecao.map((p, i) => (
            <AoRolar key={p.id} escalonar={(i % 4) * 0.1}>
              <CartaoPeca peca={p} />
            </AoRolar>
          ))}
        </div>
      </section>

      <AoRolar className="mx-auto max-w-[760px] px-6 pb-8 pt-24 text-center">
        <hr className="border-linha" />
        <h2 className="mt-10 text-[28px]">{colecao.fecho}</h2>
        <p className="mt-3 leading-normal text-suave">{colecao.fechoTexto}</p>
      </AoRolar>
    </>
  );
}
