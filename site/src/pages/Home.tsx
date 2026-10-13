import { ArrowRight, Gem, Layers, MessageCircle, Shirt, ShoppingBag } from "lucide-react";
import { useMemo, type CSSProperties } from "react";
import { Link } from "react-router-dom";
import CartaoColecao from "@/components/CartaoColecao";
import CartaoPeca from "@/components/CartaoPeca";
import { AoRolar, ParallaxFoto } from "@/components/Efeitos";
import FotoPeca from "@/components/FotoPeca";
import GuiaDaLoja from "@/components/GuiaDaLoja";
import IndiceCategorias from "@/components/IndiceCategorias";
import Novidades from "@/components/Novidades";
import { useCatalogo } from "@/context/Catalogo";
import { useTitulo } from "@/hooks/useTitulo";
import { precoTexto } from "@/lib/catalogo";
import { COLECOES, pecasDaColecao, primeiraFoto } from "@/lib/colecoes";
import { formatarReais } from "@/lib/formato";
import { resumirCatalogo } from "@/lib/resumo";

const FAIXA = ["Coleção Essence", "Peças únicas", "Pequenos lotes", "Feito com carinho"];

const PILARES = [
  { Icone: Layers, titulo: "Pequenos lotes", texto: "Produzidas com carinho, sem pressa." },
  { Icone: Gem, titulo: "Peças únicas", texto: "Cortes assimétricos, com identidade." },
  { Icone: MessageCircle, titulo: "Atendimento direto", texto: "Cada compra combinada com você, sem intermediário." },
];

const PASSOS = [
  { Icone: Shirt, texto: "Escolha a peça, a cor e o tamanho." },
  { Icone: ShoppingBag, texto: "Adicione à sacola." },
  { Icone: MessageCircle, texto: "Feche o pedido pelo WhatsApp e combine tudo direto com a marca." },
];

const atraso = (ms: number) => ({ "--atraso": `${ms}ms` }) as CSSProperties;

export default function Home() {
  useTitulo();
  const { pecas, carregando, erro } = useCatalogo();
  const comFoto = pecas.filter((p) => p.fotos.length);
  // Peça da campanha no topo: a blusa de um ombro com laço; se ela sair do catálogo, vale a primeira com foto.
  const destaque = comFoto.find((p) => p.id === "essence-005") ?? comFoto[0];
  const destaques = comFoto.filter((p) => p.id !== destaque?.id).slice(0, 3);
  const fotoApoio = comFoto[comFoto.length - 1]?.fotos[0];
  // Catálogo carregado e sem nenhuma peça ativa (a administradora ainda não ligou nenhuma): a Home não promete peças.
  const semPecas = !carregando && !erro && pecas.length === 0;
  const resumo = useMemo(() => resumirCatalogo(pecas), [pecas]);

  return (
    <>
      {/* Hero */}
      <section className="mx-auto max-w-[1100px] px-6 pb-14 pt-36">
        <div className="grid items-center gap-14 lg:grid-cols-[5fr_4fr]">
          <div>
            <h1 className="intro text-[50px] leading-[1.02] tracking-[-0.03em] lg:text-[76px]" style={atraso(120)}>
              RV·LABEL Essence
            </h1>
            <p className="intro mt-6 max-w-[520px] text-[17px] leading-[1.55]" style={atraso(260)}>
              Cortes assimétricos, um ombro só, decotes que respiram. A essência da marca em peças feitas em lote pequeno,
              pensadas pra durar no guarda-roupa e no visual.
            </p>
            <p className="intro mt-3 text-[15px] text-suave" style={atraso(340)}>Peças únicas, feitas pra você.</p>
            <div className="intro mt-8 flex flex-wrap gap-3" style={atraso(420)}>
              <Link to="/loja" className="btn-cheio">Ver peças disponíveis</Link>
              <a href="#como-comprar" className="btn-contorno">Como comprar</a>
            </div>
          </div>

          {/* Enquanto o catálogo carrega, a moldura (mesma proporção 4:5) já ocupa o lugar: sem isso o cartão chega e empurra a página toda para baixo. */}
          {(destaque || carregando) && (
            <div className="intro mb-4 mr-4" style={atraso(300)}>
              <div className="relative">
                <div aria-hidden className="absolute inset-0 translate-x-4 translate-y-4 rounded border border-linha" />
                {destaque ? (
                  <Link to={`/peca/${destaque.id}`} className="relative block aspect-[4/5] overflow-hidden rounded">
                    <ParallaxFoto className="h-full w-full" intensidade={18} escala={1.12}>
                      <FotoPeca src={destaque.fotos[0]} cor={destaque.cores[0]} alt="" loading="eager" className="h-full w-full" />
                    </ParallaxFoto>
                    <div className="absolute inset-0 bg-gradient-to-b from-transparent from-55% to-preto/85" />
                    <div className="absolute inset-x-5 bottom-5">
                      <p className="font-titulo text-2xl leading-tight">{destaque.nome}</p>
                      <p className="mt-1 tabular-nums text-suave">{precoTexto(destaque, formatarReais)}</p>
                    </div>
                  </Link>
                ) : (
                  <div aria-hidden className="relative aspect-[4/5] rounded bg-white/5" />
                )}
              </div>
            </div>
          )}
        </div>
      </section>

      {/* Faixa rolante */}
      <div className="overflow-hidden border-y border-linha py-4" aria-hidden>
        <div className="faixa flex w-max whitespace-nowrap">
          {[0, 1].map((k) => (
            <div key={k} className="flex shrink-0">
              {FAIXA.map((t) => (
                <span key={t} className="mx-8 font-titulo text-2xl text-suave">
                  {t} <span className="mx-8 opacity-50">•</span>
                </span>
              ))}
            </div>
          ))}
        </div>
      </div>

      {/* Peças em destaque */}
      <section className="mx-auto max-w-[1100px] px-6 pt-20" aria-labelledby="destaques-titulo">
        <AoRolar>
          <div className="flex items-end justify-between gap-4">
            <div>
              <h2 id="destaques-titulo" className="text-[34px]">A coleção Essence</h2>
              <p className="mt-2.5 text-suave">
                {semPecas ? "Em breve, peças novas por aqui." : "Toque numa peça pra abrir em detalhe, virar a foto e escolher a cor."}
              </p>
            </div>
            {!semPecas && (
              <Link to="/loja" className="hidden items-center gap-2 text-sm underline-offset-4 hover:underline sm:flex">
                Ver todas <ArrowRight className="h-4 w-4" aria-hidden />
              </Link>
            )}
          </div>
        </AoRolar>
        {carregando && <p className="mt-10 text-suave">Carregando a coleção…</p>}
        {erro && <p role="alert" className="mt-10 text-suave">Não consegui carregar o catálogo agora. Tente recarregar a página.</p>}
        <div className="mt-10 grid grid-cols-2 gap-x-4 gap-y-10 sm:grid-cols-3">
          {destaques.map((p, i) => (
            <AoRolar key={p.id} escalonar={i * 0.1}>
              <CartaoPeca peca={p} />
            </AoRolar>
          ))}
        </div>
        {!semPecas && (
          <div className="mt-10 sm:hidden">
            <Link to="/loja" className="btn-contorno w-full">Ver todas as peças</Link>
          </div>
        )}
      </section>

      {/* Coleções: os cartões usam a foto de uma peça, então só aparecem quando há peça ativa. */}
      {!semPecas && (
        <section className="mx-auto max-w-[1100px] px-6 pt-28" aria-label="Coleções">
          <div className="grid gap-3 md:grid-cols-2">
            {COLECOES.map((c, i) => (
              <AoRolar key={c.slug} dy={96} escalonar={i * 0.12}>
                <CartaoColecao colecao={c} foto={primeiraFoto(pecasDaColecao(c, pecas))} />
              </AoRolar>
            ))}
          </div>
        </section>
      )}

      {/* O que há em cada categoria (vem do catálogo; some junto com as peças) */}
      {!semPecas && <IndiceCategorias resumo={resumo} />}

      {/* Sobre */}
      <section className="mx-auto max-w-[1100px] px-6 pt-28" aria-labelledby="sobre-titulo">
        <div className="grid gap-12 lg:grid-cols-[5fr_4fr] lg:gap-16">
          <AoRolar dx={-64} dy={0}>
            <h2 id="sobre-titulo" className="text-[32px] leading-[1.1] tracking-[-0.02em] lg:text-[46px]">
              Roupa que veste história, não tendência.
            </h2>
          </AoRolar>
          <div>
            <AoRolar>
              <p className="text-[17px] leading-[1.6]">
                A RV Label nasceu da vontade de fazer moda com identidade — peças pensadas com carinho, produzidas em pequenos
                lotes e feitas pra durar. Cada compra é combinada direto com você, sem intermediário, sem pressa.
              </p>
            </AoRolar>
            <div className="mt-7 space-y-5">
              {PILARES.map(({ Icone, titulo, texto }, i) => (
                <AoRolar key={titulo} dx={64} dy={0} escalonar={i * 0.08}>
                  <div className="flex items-start gap-4">
                    <span className="flex h-11 w-11 shrink-0 items-center justify-center rounded-full border border-linha">
                      <Icone className="h-5 w-5" aria-hidden />
                    </span>
                    <div>
                      <p className="font-semibold">{titulo}</p>
                      <p className="mt-0.5 leading-snug text-suave">{texto}</p>
                    </div>
                  </div>
                </AoRolar>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* Tamanhos, cores, preços e atendimento (vem do catálogo; some junto com as peças) */}
      {!semPecas && <GuiaDaLoja resumo={resumo} />}

      {/* Como comprar */}
      <section id="como-comprar" className="mx-auto max-w-[1100px] scroll-mt-24 px-6 pt-28" aria-labelledby="como-titulo">
        <AoRolar>
          <h2 id="como-titulo" className="text-[34px]">Como comprar</h2>
        </AoRolar>
        <div className="mt-7 grid gap-3 md:grid-cols-3">
          {PASSOS.map(({ Icone, texto }, i) => (
            <AoRolar key={texto} escalonar={i * 0.1}>
              <div className="h-full rounded border border-linha bg-white/[0.08] p-6 transition duration-200 hover:-translate-y-1.5 hover:border-texto hover:bg-white/15">
                <div className="flex items-start justify-between">
                  <span className="font-titulo text-[56px] leading-none">{i + 1}</span>
                  <Icone className="h-6 w-6 text-suave" aria-hidden />
                </div>
                <p className="mt-4 text-base leading-normal">{texto}</p>
              </div>
            </AoRolar>
          ))}
        </div>
      </section>

      <div className="mt-28">
        <Novidades foto={fotoApoio} />
      </div>
    </>
  );
}
