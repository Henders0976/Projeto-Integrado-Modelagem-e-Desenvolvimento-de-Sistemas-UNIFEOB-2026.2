import { ClipboardList, Menu, ShoppingBag, X } from "lucide-react";
import { useEffect, useState } from "react";
import { Link, NavLink, useLocation } from "react-router-dom";
import { useSacola } from "@/context/Sacola";

const LINKS = [
  { to: "/loja", rotulo: "Loja" },
  { to: "/sobre", rotulo: "Sobre" },
  { to: "/contato", rotulo: "Contato" },
];

/** Barra do topo: transparente sobre o hero da home e vidro fosco ao rolar, com a barra de progresso da página. */
export default function Header() {
  const { pathname } = useLocation();
  const { quantidade } = useSacola();
  const [y, setY] = useState(0);
  const [progresso, setProgresso] = useState(0);
  const [menu, setMenu] = useState(false);
  const home = pathname === "/";

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

  useEffect(() => setMenu(false), [pathname]);

  const t = home && !menu ? Math.min(1, y / 140) : 1;
  const estilo = {
    backgroundColor: `rgba(11, 11, 11, ${0.6 * t})`,
    backdropFilter: `blur(${18 * t}px)`,
    WebkitBackdropFilter: `blur(${18 * t}px)`,
    borderBottom: `1px solid rgba(255, 247, 245, ${0.17 * t})`,
  };

  return (
    <header className="fixed inset-x-0 top-0 z-50" style={estilo}>
      <div className="mx-auto flex h-[72px] max-w-[1148px] items-center px-4">
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
            <NavLink
              key={l.to}
              to={l.to}
              className={({ isActive }) =>
                `px-3 py-2 text-[13px] uppercase tracking-[0.2em] transition hover:text-texto ${isActive ? "text-texto underline underline-offset-8" : "text-suave"}`
              }
            >
              {l.rotulo}
            </NavLink>
          ))}
        </nav>

        <div className="ml-auto flex items-center gap-1 md:ml-2">
          <Link to="/meus-pedidos" aria-label="Meus pedidos" className="flex h-11 w-11 items-center justify-center rounded transition hover:bg-white/10">
            <ClipboardList className="h-5 w-5" />
          </Link>
          <Link
            to="/sacola"
            aria-label={`Sacola${quantidade ? `, ${quantidade} ${quantidade === 1 ? "item" : "itens"}` : ""}`}
            className="relative flex h-11 w-11 items-center justify-center rounded transition hover:bg-white/10"
          >
            <ShoppingBag className="h-5 w-5" />
            {quantidade > 0 && (
              <span className="absolute right-0.5 top-0.5 flex h-[18px] min-w-[18px] items-center justify-center rounded-full bg-texto px-1 text-[11px] font-semibold text-preto">
                {quantidade}
              </span>
            )}
          </Link>
          <button
            type="button"
            className="flex h-11 w-11 items-center justify-center rounded transition hover:bg-white/10 md:hidden"
            aria-label={menu ? "Fechar menu" : "Abrir menu"}
            aria-expanded={menu}
            onClick={() => setMenu((m) => !m)}
          >
            {menu ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
          </button>
        </div>
      </div>

      {menu && (
        <nav className="border-t border-linha bg-preto/90 px-6 py-4 md:hidden" aria-label="Menu">
          {LINKS.map((l) => (
            <NavLink key={l.to} to={l.to} className="block py-3 text-sm uppercase tracking-[0.2em] text-suave">
              {l.rotulo}
            </NavLink>
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
