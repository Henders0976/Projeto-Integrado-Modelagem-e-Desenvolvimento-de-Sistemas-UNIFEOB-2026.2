import { useEffect } from "react";

/** Título da aba do navegador: "Loja | RV·LABEL" (ou o padrão da marca, sem argumento). */
export function useTitulo(titulo?: string): void {
  useEffect(() => {
    document.title = titulo ? `${titulo} | RV·LABEL` : "RV·LABEL | Coleção Essence";
  }, [titulo]);
}
