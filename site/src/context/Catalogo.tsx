import { createContext, useContext, useEffect, useState, type ReactNode } from "react";
import { carregarCatalogo, type FonteCatalogo, type Peca } from "@/lib/catalogo";

interface Estado {
  pecas: Peca[];
  carregando: boolean;
  erro: string | null;
  fonte: FonteCatalogo | null;
}

const Ctx = createContext<Estado | null>(null);

/** Carrega o catálogo uma vez (API ou catalogo.json) e o entrega às páginas. */
export function CatalogoProvider({ children }: { children: ReactNode }) {
  const [estado, setEstado] = useState<Estado>({ pecas: [], carregando: true, erro: null, fonte: null });

  useEffect(() => {
    let vivo = true;
    carregarCatalogo()
      .then((r) => vivo && setEstado({ pecas: r.pecas, carregando: false, erro: null, fonte: r.fonte }))
      .catch((e) =>
        vivo && setEstado({ pecas: [], carregando: false, erro: e instanceof Error ? e.message : String(e), fonte: null }),
      );
    return () => {
      vivo = false;
    };
  }, []);

  return <Ctx.Provider value={estado}>{children}</Ctx.Provider>;
}

export function useCatalogo(): Estado {
  const c = useContext(Ctx);
  if (!c) throw new Error("useCatalogo precisa estar dentro do CatalogoProvider");
  return c;
}
