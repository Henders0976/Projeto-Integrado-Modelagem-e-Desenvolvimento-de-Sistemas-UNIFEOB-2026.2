import { X, ZoomIn } from "lucide-react";
import { useEffect, useRef, useState, type MouseEvent } from "react";
import { Link, useNavigate, useParams } from "react-router-dom";
import { toast } from "sonner";
import CartaoPeca from "@/components/CartaoPeca";
import { AoRolar } from "@/components/Efeitos";
import FotoPeca from "@/components/FotoPeca";
import SeletorQuantidade from "@/components/SeletorQuantidade";
import { useCatalogo } from "@/context/Catalogo";
import { useSacola } from "@/context/Sacola";
import { useTitulo } from "@/hooks/useTitulo";
import { CATEGORIAS, precoTexto, type Cor } from "@/lib/catalogo";
import { formatarReais } from "@/lib/formato";
import NaoEncontrada from "./NaoEncontrada";

export default function Peca() {
  const { id } = useParams();
  const { pecas, carregando } = useCatalogo();
  const { adicionar } = useSacola();
  const navegar = useNavigate();
  const peca = pecas.find((p) => p.id === id);

  const [corIdx, setCorIdx] = useState(0);
  const [tamanho, setTamanho] = useState<string | null>(null);
  const [quantidade, setQuantidade] = useState(1);
  const [lado, setLado] = useState<"frente" | "costas">("frente");
  const [ampliada, setAmpliada] = useState(false);
  useTitulo(peca?.nome);

  if (carregando)
    return (
      <div role="status" aria-label="Carregando a peça" className="mx-auto grid min-h-[100svh] max-w-[1000px] items-start gap-10 px-6 pt-28 motion-safe:animate-pulse lg:grid-cols-2 lg:gap-14">
        <div aria-hidden className="aspect-[3/4] rounded bg-elevado" />
        <div aria-hidden className="space-y-4 pt-8">
          <div className="h-10 w-3/4 rounded-sm bg-elevado" />
          <div className="h-8 w-1/3 rounded-sm bg-elevado" />
          <div className="h-20 rounded-sm bg-elevado" />
        </div>
      </div>
    );
  if (!peca) return <NaoEncontrada />;

  const cor = peca.cores[Math.min(corIdx, peca.cores.length - 1)];
  const tam = tamanho ?? (peca.tamanhos.length === 1 ? peca.tamanhos[0] : null);
  const foto = lado === "costas" && peca.fotoCostas ? peca.fotoCostas : peca.fotos[0];
  const parecidas = [...pecas.filter((p) => p.categoria === peca.categoria && p.id !== peca.id), ...pecas.filter((p) => p.categoria !== peca.categoria)]
    .filter((p) => p.id !== peca.id)
    .slice(0, 3);

  function adicionarASacola() {
    if (!tam) return toast("Escolha o tamanho antes de adicionar.");
    adicionar(peca!, cor.nome, tam, quantidade);
    toast(`${quantidade}× ${peca!.nome} (${cor.nome}, ${tam}) na sacola.`, {
      action: { label: "Ver sacola", onClick: () => navegar("/sacola") },
    });
    setQuantidade(1);
  }

  const pilula = (ativa: boolean, aoTocar: () => void, rotulo: string, extra?: React.ReactNode) => (
    <button key={rotulo} type="button" aria-pressed={ativa} onClick={aoTocar} className="pilula">
      {extra}
      {rotulo}
    </button>
  );

  const miniatura = (l: "frente" | "costas", src: string | undefined) => (
    <button
      key={l}
      type="button"
      aria-pressed={lado === l}
      aria-label={`Foto: ${l === "frente" ? "Frente" : "Costas"}`}
      onClick={() => setLado(l)}
      className={`h-20 w-16 overflow-hidden rounded-sm p-0.5 transition ${lado === l ? "ring-2 ring-vermelho" : "ring-1 ring-linha hover:ring-mudo"}`}
    >
      <FotoPeca src={src} cor={cor} alt="" className="h-full w-full rounded-[4px]" />
    </button>
  );

  return (
    <>
      <div className="mx-auto max-w-[1000px] px-6 pb-8 pt-28">
        <nav aria-label="Você está em" className="mb-6 text-sm text-suave">
          <Link to="/loja" className="hover:text-texto">Loja</Link>
          <span className="mx-2" aria-hidden>›</span>
          <Link to={`/loja?categoria=${peca.categoria}`} className="hover:text-texto">{CATEGORIAS[peca.categoria]}</Link>
          <span className="mx-2" aria-hidden>›</span>
          <span className="text-texto">{peca.nome}</span>
        </nav>

        <div className="grid items-start gap-10 lg:grid-cols-2 lg:gap-14">
          <div>
            {/* 3:4 e enquadramento do app (peca_page.dart): a foto inteira, sem cortar. O nome liga com o do cartão (Hero). */}
            <button
              type="button"
              disabled={!foto}
              onClick={() => setAmpliada(true)}
              aria-label="Ampliar foto"
              className="relative block aspect-[3/4] w-full cursor-zoom-in overflow-hidden rounded shadow-[0_16px_30px_rgba(0,0,0,0.35)] disabled:cursor-default"
              style={{ viewTransitionName: "foto-peca" }}
            >
              <FotoPeca src={foto} cor={cor} alt={`${peca.nome}, ${lado}`} loading="eager" className="h-full w-full" posicao="50% 25%" />
              {foto && (
                <span aria-hidden className="absolute bottom-3 right-3 grid h-9 w-9 place-items-center rounded-full bg-preto/70">
                  <ZoomIn className="h-5 w-5" />
                </span>
              )}
            </button>
            {peca.fotoCostas && (
              <div className="mt-3 flex justify-center gap-2" role="group" aria-label="Lado da peça">
                {miniatura("frente", peca.fotos[0])}
                {miniatura("costas", peca.fotoCostas)}
              </div>
            )}
            {ampliada && foto && <Ampliada src={foto} cor={cor} alt={`${peca.nome}, ${lado}`} aoFechar={() => setAmpliada(false)} />}
          </div>

          <div className="flex flex-col">
            <p className="text-xs uppercase tracking-[0.3em] text-suave">
              {peca.tipo === "acessorio" ? "Acessório" : "Peça"} · {CATEGORIAS[peca.categoria]}
              {peca.material ? ` · ${peca.material}` : ""}
            </p>
            <h1 className="mt-3 text-[36px] leading-[1.1]">{peca.nome}</h1>
            <p className="preco mt-3 text-[28px]">{precoTexto(peca, formatarReais)}</p>
            {peca.descricao && <p className="mt-5 leading-relaxed text-suave">{peca.descricao}</p>}

            {peca.cores.length > 1 && (
              <fieldset className="mt-7">
                <legend className="mb-2 text-sm text-suave">Cor: <span className="text-texto">{cor.nome}</span></legend>
                <div className="flex flex-wrap gap-2">
                  {peca.cores.map((c, i) =>
                    pilula(i === corIdx, () => setCorIdx(i), c.nome,
                      <span className="relative inline-block h-5 w-5 overflow-hidden rounded-full ring-1 ring-linha">
                        <FotoPeca src={peca.fotos[0]} cor={c} alt="" posicao="50% 35%" className="absolute inset-0 h-full w-full scale-[4]" />
                      </span>),
                  )}
                </div>
              </fieldset>
            )}

            <fieldset className="mt-6">
              <legend className="mb-2 text-sm text-suave">Tamanho</legend>
              <div className="flex flex-wrap gap-2">
                {peca.tamanhos.map((t) => pilula(t === tam, () => setTamanho(t), t))}
              </div>
            </fieldset>

            <div className="mt-8 flex flex-wrap items-stretch gap-3">
              <SeletorQuantidade quantidade={quantidade} aoMudar={setQuantidade} />
              <button type="button" onClick={adicionarASacola} className="btn-cheio flex-1">Adicionar à sacola</button>
            </div>
            <p className="mt-4 text-sm text-suave">O pedido é fechado direto com a marca pelo WhatsApp, sem intermediário.</p>
          </div>
        </div>
      </div>

      {parecidas.length > 0 && (
        <section className="mx-auto max-w-[1000px] px-6 pb-8 pt-16" aria-labelledby="parecidas-titulo">
          <h2 id="parecidas-titulo" className="mb-8 text-[28px]">Você também pode gostar</h2>
          <div className="grid grid-cols-2 gap-x-4 gap-y-10 sm:grid-cols-3">
            {parecidas.map((p, i) => (
              <AoRolar key={p.id} escalonar={i * 0.1}>
                <CartaoPeca peca={p} transicao={false} />
              </AoRolar>
            ))}
          </div>
        </section>
      )}
    </>
  );
}

/**
 * Foto em tela cheia (o Dialog.fullscreen + InteractiveViewer do app). Clique dá zoom de 2,5x no ponto clicado e o
 * mouse passeia pela foto; outro clique volta. No celular, o gesto de pinça do navegador também funciona aqui.
 */
function Ampliada({ src, cor, alt, aoFechar }: { src: string; cor: Cor; alt: string; aoFechar: () => void }) {
  const ref = useRef<HTMLDialogElement>(null);
  const [zoom, setZoom] = useState<{ x: number; y: number } | null>(null);
  useEffect(() => ref.current?.showModal(), []);

  const ponto = (e: MouseEvent<HTMLElement>) => {
    const r = e.currentTarget.getBoundingClientRect();
    return { x: ((e.clientX - r.left) / r.width) * 100, y: ((e.clientY - r.top) / r.height) * 100 };
  };

  return (
    <dialog
      ref={ref}
      onClose={aoFechar}
      aria-label={alt}
      className="m-0 h-[100dvh] max-h-none w-screen max-w-none bg-preto p-0 text-texto backdrop:bg-preto"
    >
      <div className="grid h-full w-full place-items-center overflow-hidden">
        <div
          className={`aspect-[3/4] h-full max-h-[100dvh] max-w-full overflow-hidden ${zoom ? "cursor-zoom-out" : "cursor-zoom-in"}`}
          onClick={(e) => setZoom(zoom ? null : ponto(e))}
          onPointerMove={(e) => zoom && e.pointerType === "mouse" && setZoom(ponto(e))}
        >
          <div
            className="h-full w-full transition-transform duration-200 motion-reduce:transition-none"
            style={zoom ? { transform: "scale(2.5)", transformOrigin: `${zoom.x}% ${zoom.y}%` } : undefined}
          >
            <FotoPeca src={src} cor={cor} alt={alt} loading="eager" posicao="50% 50%" className="h-full w-full" />
          </div>
        </div>
      </div>
      <button
        type="button"
        onClick={() => ref.current?.close()}
        aria-label="Fechar"
        autoFocus
        className="fixed right-4 top-4 grid h-12 w-12 place-items-center rounded-full bg-elevado/90 transition hover:bg-elevado"
      >
        <X className="h-5 w-5" aria-hidden />
      </button>
    </dialog>
  );
}
