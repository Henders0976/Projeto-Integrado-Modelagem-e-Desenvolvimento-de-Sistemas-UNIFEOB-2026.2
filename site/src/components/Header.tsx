import { ClipboardList, Menu, ShoppingBag, X } from "lucide-react";
import { useEffect, useLayoutEffect, useRef, useState, type CSSProperties } from "react";
import { Link, useLocation } from "react-router-dom";
import { useSacola } from "@/context/Sacola";

interface Opcao {
  to: string;
  /** Outras rotas que também são desta opção. */
  tambem: string[];
}

const LINKS: (Opcao & { rotulo: string })[] = [
  // Peça e coleção fazem parte da loja: a linha fica sob "Loja" nelas também, em vez de a barra ficar sem escolha.
  { to: "/loja", rotulo: "Loja", tambem: ["/peca", "/colecoes"] },
  { to: "/sobre", rotulo: "Sobre", tambem: [] },
  { to: "/contato", rotulo: "Contato", tambem: [] },
];
const PEDIDOS = "/meus-pedidos";
const SACOLA = "/sacola";
const OPCOES: Opcao[] = [...LINKS, { to: PEDIDOS, tambem: [] }, { to: SACOLA, tambem: [] }];

const dentroDe = (pathname: string, base: string): boolean => pathname === base || pathname.startsWith(`${base}/`);
/** A opção vale para a própria rota, para o que vem embaixo dela e para as rotas em `tambem`. */
const eDaOpcao = (pathname: string, o: Opcao): boolean => [o.to, ...o.tambem].some((base) => dentroDe(pathname, base));

/** Onde a linha das opções está: x e largura na caixa do cabeçalho; `deslizar` só se ela já estava visível. */
interface Barra {
  x: number;
  y: number;
  w: number;
  visivel: boolean;
  deslizar: boolean;
}

/** Barra do topo: transparente sobre o hero da home e vidro fosco ao rolar, com a barra de progresso da página. */
export default function Header() {
  const { pathname } = useLocation();
  const { quantidade } = useSacola();
  const [y, setY] = useState(0);
  const [progresso, setProgresso] = useState(0);
  const [menu, setMenu] = useState(false);
  const home = pathname === "/";

  // Linha que escolhe: fica sob a opção da página atual, desliza até a opção sob o mouse/teclado e volta ao sair.
  const caixa = useRef<HTMLDivElement>(null);
  const [alvo, setAlvo] = useState<string | null>(null);
  const [barra, setBarra] = useState<Barra>({ x: 0, y: 0, w: 1, visivel: false, deslizar: false });
  const ativa = OPCOES.find((o) => eDaOpcao(pathname, o))?.to ?? null;
  const destino = alvo ?? ativa;
  // Leitor de tela: "page" na própria página da opção; "true" numa página que pertence a ela (uma peça, em "Loja").
  const atual = (to: string) => (pathname === to ? ("page" as const) : ativa === to ? ("true" as const) : undefined);
  // A medição atrasada (fontes carregando, redimensionar) lê o destino de AGORA, não o de quando foi agendada.
  const destinoAtual = useRef(destino);
  destinoAtual.current = destino;

  // Pulinho do contador da sacola quando a quantidade muda (não ao carregar a página).
  const [pulso, setPulso] = useState(0);
  const anterior = useRef(quantidade);
  useEffect(() => {
    if (anterior.current !== quantidade) {
      anterior.current = quantidade;
      setPulso((p) => p + 1);
    }
  }, [quantidade]);

  useEffect(() => {
    const aoRolar = () => {
      setY(window.scrollY);
      const max = document.documentElement.scrollHeight - window.innerHeight;
      setProgresso(max > 0 ? Math.min(1, window.scrollY / max) : 0);
    };
    aoRolar();
    window.addEventListener("scroll", aoRolar, { passive: true });
    window.addEventListener("resize", aoRolar);
    return () => {
      window.removeEventListener("scroll", aoRolar);
      window.removeEventListener("resize", aoRolar);
    };
  }, [pathname]);

  useEffect(() => {
    setMenu(false);
    setAlvo(null); // trocou de página: a linha assenta na opção nova
  }, [pathname]);

  useLayoutEffect(() => {
    const c = caixa.current;
    if (!c) return;
    let vivo = true;
    const medir = () => {
      if (!vivo) return;
      const agora = destinoAtual.current;
      const el = agora ? c.querySelector<HTMLElement>(`[data-nav="${agora}"] [data-medida]`) : null;
      const r = el?.getBoundingClientRect();
      // Sem destino, ou a opção está escondida (os textos somem no celular): a linha some no lugar, sem viajar.
      if (!el || !r || r.width === 0) {
        setBarra((b) => (b.visivel ? { ...b, visivel: false, deslizar: false } : b));
        return;
      }
      const cr = c.getBoundingClientRect();
      const trilha = parseFloat(getComputedStyle(el).letterSpacing) || 0; // o espaço depois da última letra não conta
      const x = r.left - cr.left;
      const w = Math.max(1, r.width - trilha);
      const yy = cr.height / 2 + 16;
      setBarra((b) =>
        b.visivel && Math.abs(b.x - x) < 0.5 && Math.abs(b.w - w) < 0.5 && Math.abs(b.y - yy) < 0.5
          ? b
          : { x, y: yy, w, visivel: true, deslizar: b.visivel },
      );
    };
    medir();
    const ro = new ResizeObserver(medir);
    ro.observe(c);
    void document.fonts?.ready.then(medir);
    return () => {
      vivo = false;
      ro.disconnect();
    };
  }, [destino]);

  const t = home && !menu ? Math.min(1, y / 140) : 1;
  const estilo = {
    backgroundColor: `rgba(11, 11, 11, ${0.6 * t})`,
    backdropFilter: `blur(${18 * t}px)`,
    WebkitBackdropFilter: `blur(${18 * t}px)`,
    borderBottom: `1px solid rgba(255, 247, 245, ${0.17 * t})`,
  };

  /** Mouse e teclado "escolhem" a opção; só o foco de teclado conta (clicar com o mouse também foca e atrapalharia). */
  const escolher = (to: string) => ({
    "data-nav": to,
    onPointerEnter: () => setAlvo(to),
    onFocus: (e: React.FocusEvent<HTMLElement>) => {
      if (e.currentTarget.matches(":focus-visible")) setAlvo(to);
    },
    onBlur: () => setAlvo(null),
  });

  return (
    <header className="fixed inset-x-0 top-0 z-50" style={estilo}>
      <div ref={caixa} onPointerLeave={() => setAlvo(null)} className="relative mx-auto flex h-[72px] max-w-[1148px] items-center px-4">
        <Link
          to="/"
          className="px-2 py-2 font-titulo tracking-[0.25em]"
          style={{ fontSize: `${28 - 6 * t}px` }}
          aria-label="RV·LABEL, página inicial"
        >
          RV·LABEL
        </Link>

        <nav className="ml-auto hidden items-center gap-1 md:flex" aria-label="Principal">
          {LINKS.map((l) => (
            <Link
              key={l.to}
              to={l.to}
              {...escolher(l.to)}
              aria-current={atual(l.to)}
              // A cor segue a linha: só a opção escolhida (sob a linha) fica clara; as outras ficam em segundo plano.
              className={`px-3 py-2 text-[13px] uppercase tracking-[0.2em] transition-colors ${destino === l.to ? "text-texto" : "text-suave"}`}
            >
              <span data-medida>{l.rotulo}</span>
            </Link>
          ))}
        </nav>

        <div className="ml-auto flex items-center gap-1 md:ml-2">
          <Link
            to={PEDIDOS}
            {...escolher(PEDIDOS)}
            aria-current={atual(PEDIDOS)}
            aria-label="Meus pedidos"
            className="flex h-11 w-11 items-center justify-center rounded transition hover:bg-white/10 active:scale-90"
          >
            <ClipboardList data-medida className="h-5 w-5" />
          </Link>
          <Link
            to={SACOLA}
            {...escolher(SACOLA)}
            aria-current={atual(SACOLA)}
            aria-label={`Sacola${quantidade ? `, ${quantidade} ${quantidade === 1 ? "item" : "itens"}` : ""}`}
            className="relative flex h-11 w-11 items-center justify-center rounded transition hover:bg-white/10 active:scale-90"
          >
            <ShoppingBag data-medida className="h-5 w-5" />
            {quantidade > 0 && (
              <span
                key={pulso}
                className={`absolute right-0.5 top-0.5 flex h-[18px] min-w-[18px] items-center justify-center rounded-full bg-texto px-1 text-[11px] font-semibold text-preto ${pulso ? "selo-pulso" : ""}`}
              >
                {quantidade}
              </span>
            )}
          </Link>
          <button
            type="button"
            className="flex h-11 w-11 items-center justify-center rounded transition hover:bg-white/10 active:scale-90 md:hidden"
            aria-label={menu ? "Fechar menu" : "Abrir menu"}
            aria-expanded={menu}
            onClick={() => setMenu((m) => !m)}
          >
            <span key={menu ? "fechar" : "abrir"} className="icone-troca">
              {menu ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
            </span>
          </button>
        </div>

        <span
          aria-hidden
          className="barra-nav pointer-events-none absolute left-0 top-0 h-[2px] w-px origin-top-left bg-texto"
          style={{
            transform: `translate3d(${barra.x}px, ${barra.y}px, 0) scale3d(${barra.w}, 1, 1)`,
            opacity: barra.visivel ? 1 : 0,
          }}
          {...(barra.deslizar ? {} : { "data-parada": "" })}
        />
      </div>

      {menu && (
        <nav className="painel-menu border-t border-linha bg-preto/90 px-6 py-4 md:hidden" aria-label="Menu">
          {LINKS.map((l, i) => (
            <Link
              key={l.to}
              to={l.to}
              aria-current={atual(l.to)}
              style={{ "--atraso": `${60 + i * 55}ms` } as CSSProperties}
              className={`item-menu relative block py-3 pl-4 text-sm uppercase tracking-[0.2em] transition-colors before:absolute before:left-0 before:top-1/2 before:h-4 before:w-0.5 before:-translate-y-1/2 before:bg-texto before:transition-transform before:duration-300 before:content-[''] ${
                ativa === l.to ? "text-texto before:scale-y-100" : "text-suave before:scale-y-0"
              }`}
            >
              {l.rotulo}
            </Link>
          ))}
        </nav>
      )}

      <div
        aria-hidden
        className="absolute bottom-0 left-0 h-0.5 bg-texto"
        style={{ width: `${progresso * 100}%`, opacity: t }}
      />
    </header>
  );
}
