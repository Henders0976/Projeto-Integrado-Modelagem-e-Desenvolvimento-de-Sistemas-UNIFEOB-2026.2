import { ArrowRight, X } from "lucide-react";
import { useEffect, useRef, useState } from "react";
import { createPortal } from "react-dom";
import { Link } from "react-router-dom";
import { CATEGORIAS, precoTexto, type Peca } from "@/lib/catalogo";
import { formatarReais } from "@/lib/formato";
import { reduzirMovimento } from "@/lib/scroll";
import FotoPeca from "./FotoPeca";

const DURACAO = 700; // ms da transição galeria -> overlay
const CURVA = "cubic-bezier(0.76, 0, 0.24, 1)";
const ALTURA_HERO = "clamp(340px, 62vh, 640px)";

/** Posição da janela de prévia na tela, no formato de `top/left/right/height` (o que a foto do overlay anima). */
interface Origem {
  top: number;
  left: number;
  right: number;
  height: number;
}

function medir(el: HTMLElement): Origem {
  const r = el.getBoundingClientRect();
  return { top: r.top, left: r.left, right: document.documentElement.clientWidth - r.right, height: r.height };
}

/**
 * Vitrine em lista: os nomes das peças, e uma janela com a foto de quem está sob o mouse (ou o foco).
 * Ao abrir, a foto da janela se expande até virar o topo de um overlay com os detalhes da peça.
 */
export default function Vitrine({ pecas }: { pecas: Peca[] }) {
  const [ativaId, setAtivaId] = useState(pecas[0]?.id);
  const [aberta, setAberta] = useState<{ peca: Peca; origem: Origem } | null>(null);
  const janela = useRef<HTMLDivElement>(null);
  const ativa = pecas.find((p) => p.id === ativaId) ?? pecas[0];
  if (!ativa) return null;

  const abrir = (p: Peca) => {
    setAtivaId(p.id);
    if (janela.current) setAberta({ peca: p, origem: medir(janela.current) });
  };

  return (
    <div className="grid items-start gap-8 md:grid-cols-[minmax(0,5fr)_minmax(0,6fr)] md:gap-14">
      <div
        ref={janela}
        className="relative aspect-[4/3] overflow-hidden rounded-2xl bg-white/10 shadow-[0_16px_40px_rgba(0,0,0,0.4)] md:sticky md:top-28 md:aspect-[4/5]"
      >
        {pecas.map((p) => (
          <FotoPeca
            key={p.id}
            src={p.fotos[0]}
            cor={p.cores[0]}
            alt={p.id === ativa.id ? p.nome : ""}
            // Empilhadas e transparentes, as fotos "lazy" nunca carregariam: a troca no hover ficaria em branco.
            loading="eager"
            className={`absolute inset-0 h-full w-full transition-opacity duration-500 ${p.id === ativa.id ? "opacity-100" : "opacity-0"}`}
          />
        ))}
      </div>

      <div>
        <p className="flex items-center gap-4 text-[12px] uppercase tracking-[0.3em] text-suave">
          Nossas peças <span aria-hidden className="h-px flex-1 bg-linha" />
        </p>
        <ul className="mt-5">
          {pecas.map((p) => {
            const eAtiva = p.id === ativa.id;
            return (
              <li key={p.id}>
                <button
                  type="button"
                  aria-haspopup="dialog"
                  onClick={() => abrir(p)}
                  onPointerEnter={() => setAtivaId(p.id)}
                  onFocus={() => setAtivaId(p.id)}
                  className={`flex w-full items-baseline gap-3 py-1 text-left font-titulo text-[clamp(28px,4.6vw,46px)] leading-[1.15] transition-colors duration-300 ${
                    eAtiva ? "text-texto" : "text-texto/40"
                  }`}
                >
                  <span>
                    {p.nome}
                    <span aria-hidden className={`ml-2 transition-opacity duration-300 ${eAtiva ? "opacity-100" : "opacity-0"}`}>
                      ·
                    </span>
                  </span>
                  <span className="ml-auto shrink-0 font-sans text-xs tabular-nums tracking-wide text-suave">
                    {precoTexto(p, formatarReais)}
                  </span>
                </button>
              </li>
            );
          })}
        </ul>
      </div>

      {aberta && <Detalhe peca={aberta.peca} origem={aberta.origem} aoFechar={() => setAberta(null)} />}
    </div>
  );
}

/** Overlay da peça. É montado no body (portal): os ancestrais da página têm transform, que quebraria o `fixed`. */
function Detalhe({ peca, origem, aoFechar }: { peca: Peca; origem: Origem; aoFechar: () => void }) {
  const [fase, setFase] = useState<"abrindo" | "aberto" | "fechando">("abrindo");
  const hero = useRef<HTMLDivElement>(null);
  const fechar = useRef<HTMLButtonElement>(null);
  const temporizador = useRef<number>();
  const rapido = reduzirMovimento();
  const ms = rapido ? 0 : DURACAO;

  // Lê o layout uma vez com a foto na janela de origem; só então manda ela crescer (senão o navegador pula a transição).
  useEffect(() => {
    hero.current?.getBoundingClientRect();
    setFase("aberto");
  }, []);

  // Enquanto aberto: página de trás parada, inerte (some do foco e do leitor de tela) e foco no botão de fechar.
  useEffect(() => {
    const raiz = document.getElementById("root");
    const antes = document.activeElement as HTMLElement | null;
    const overflow = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    raiz?.setAttribute("inert", "");
    fechar.current?.focus();
    return () => {
      document.body.style.overflow = overflow;
      raiz?.removeAttribute("inert");
      window.clearTimeout(temporizador.current);
      antes?.focus?.();
    };
  }, []);

  const sair = () => {
    if (fase === "fechando") return;
    setFase("fechando");
    temporizador.current = window.setTimeout(aoFechar, ms);
  };

  useEffect(() => {
    const tecla = (e: KeyboardEvent) => e.key === "Escape" && sair();
    window.addEventListener("keydown", tecla);
    return () => window.removeEventListener("keydown", tecla);
  });

  const aberto = fase === "aberto";
  const transicao = (prop: string, atraso = 0) => `${prop} ${ms}ms ${CURVA} ${rapido ? 0 : atraso}ms`;
  const extras = [...peca.fotos.slice(1), ...(peca.fotoCostas ? [peca.fotoCostas] : [])];

  return createPortal(
    <div role="dialog" aria-modal="true" aria-label={peca.nome} className="fixed inset-0 z-[70]">
      <div
        aria-hidden
        className="absolute inset-0 bg-preto"
        style={{ opacity: aberto ? 1 : 0, transition: transicao("opacity") }}
      />

      <div
        ref={hero}
        className="fixed overflow-hidden"
        style={{
          top: aberto ? 0 : origem.top,
          left: aberto ? 0 : origem.left,
          right: aberto ? 0 : origem.right,
          height: aberto ? ALTURA_HERO : origem.height,
          borderRadius: aberto ? 0 : 16,
          transition: ["top", "left", "right", "height", "border-radius"].map((p) => transicao(p)).join(", "),
        }}
      >
        <FotoPeca src={peca.fotos[0]} cor={peca.cores[0]} alt="" className="h-full w-full" />
        <div
          aria-hidden
          className="absolute inset-0 bg-gradient-to-t from-preto/85 via-preto/10 to-black/25"
          style={{ opacity: aberto ? 1 : 0, transition: transicao("opacity") }}
        />
      </div>

      <div className="absolute inset-0 overflow-y-auto overscroll-contain">
        <div className="relative flex items-end px-6 pb-8" style={{ height: ALTURA_HERO }}>
          <div
            className="mx-auto w-full max-w-[1100px]"
            style={{
              opacity: aberto ? 1 : 0,
              transform: aberto ? "none" : "translateY(40px)",
              transition: `${transicao("opacity", 300)}, ${transicao("transform", 300)}`,
            }}
          >
            <p className="text-[13px] uppercase tracking-[0.3em]">{CATEGORIAS[peca.categoria]}</p>
            <h2 className="mt-2 text-[clamp(44px,9vw,104px)] leading-[1]">{peca.nome}</h2>
          </div>
        </div>

        <div
          className="relative min-h-[60vh] rounded-t-3xl bg-painel px-6 pb-16 pt-12"
          style={{ transform: aberto ? "none" : "translateY(100vh)", transition: transicao("transform", 120) }}
        >
          <div className="mx-auto max-w-[760px]">
            <p className="font-titulo text-[30px] tabular-nums">{precoTexto(peca, formatarReais)}</p>
            {peca.descricao && <p className="mt-5 text-[17px] leading-[1.6] text-suave">{peca.descricao}</p>}

            <dl className="mt-8 grid grid-cols-[auto_1fr] gap-x-8 gap-y-3 border-t border-linha pt-6 text-[15px]">
              <dt className="text-suave">Cores</dt>
              <dd>{peca.cores.map((c) => c.nome).join(" · ")}</dd>
              <dt className="text-suave">Tamanhos</dt>
              <dd>{peca.tamanhos.join(" · ")}</dd>
              {peca.material && (
                <>
                  <dt className="text-suave">Material</dt>
                  <dd>{peca.material}</dd>
                </>
              )}
            </dl>

            <Link to={`/peca/${peca.id}`} className="btn-cheio mt-10 w-full sm:w-auto">
              Escolher tamanho e cor <ArrowRight className="h-4 w-4" aria-hidden />
            </Link>

            {extras.length > 0 && (
              <div className="mt-12 grid grid-cols-2 gap-4">
                {extras.map((f) => (
                  <FotoPeca key={f} src={f} cor={peca.cores[0]} alt={`${peca.nome}, outra foto`} className="aspect-[4/5] rounded-xl" />
                ))}
              </div>
            )}
          </div>
        </div>
      </div>

      <button
        ref={fechar}
        type="button"
        onClick={sair}
        aria-label="Fechar"
        className="fixed right-4 top-4 z-10 grid h-12 w-12 place-items-center rounded-full bg-black/50 backdrop-blur transition hover:bg-black/70"
        style={{ opacity: aberto ? 1 : 0, transition: transicao("opacity", 300) }}
      >
        <X className="h-5 w-5" aria-hidden />
      </button>
    </div>,
    document.body,
  );
}
