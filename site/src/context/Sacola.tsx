import { createContext, useContext, useEffect, useState, type ReactNode } from "react";
import type { Peca } from "@/lib/catalogo";
import { chaveItem, totais, type ItemSacola } from "@/lib/pedido";

const CHAVE = "rvlabel.sacola.v1";

function lerSalva(): ItemSacola[] {
  try {
    const v: unknown = JSON.parse(localStorage.getItem(CHAVE) ?? "[]");
    if (!Array.isArray(v)) return [];
    return v.filter(
      (i): i is ItemSacola =>
        !!i &&
        typeof i.chave === "string" &&
        typeof i.id === "string" &&
        typeof i.nome === "string" &&
        typeof i.cor === "string" &&
        typeof i.tamanho === "string" &&
        typeof i.quantidade === "number" &&
        i.quantidade >= 1,
    );
  } catch {
    return []; // navegador sem localStorage ou dado corrompido: começa vazia
  }
}

interface SacolaCtx {
  itens: ItemSacola[];
  quantidade: number;
  total: number;
  pendente: boolean;
  adicionar: (peca: Peca, cor: string, tamanho: string, quantidade?: number) => void;
  alterarQuantidade: (chave: string, quantidade: number) => void;
  remover: (chave: string) => void;
  limpar: () => void;
}

const Ctx = createContext<SacolaCtx | null>(null);

/** Sacola da cliente, guardada no navegador (localStorage) para sobreviver a recarregar a página. */
export function SacolaProvider({ children }: { children: ReactNode }) {
  const [itens, setItens] = useState<ItemSacola[]>(lerSalva);

  useEffect(() => {
    try {
      localStorage.setItem(CHAVE, JSON.stringify(itens));
    } catch {
      /* sem armazenamento: a sacola vale só até fechar a aba */
    }
  }, [itens]);

  const adicionar: SacolaCtx["adicionar"] = (peca, cor, tamanho, quantidade = 1) => {
    const chave = chaveItem(peca.id, cor, tamanho);
    setItens((atual) => {
      if (atual.some((i) => i.chave === chave)) {
        return atual.map((i) => (i.chave === chave ? { ...i, quantidade: i.quantidade + quantidade } : i));
      }
      return [
        ...atual,
        { chave, id: peca.id, nome: peca.nome, preco: peca.preco, foto: peca.fotos[0], cor, tamanho, quantidade },
      ];
    });
  };

  const remover = (chave: string) => setItens((atual) => atual.filter((i) => i.chave !== chave));

  const alterarQuantidade = (chave: string, quantidade: number) => {
    if (quantidade < 1) return remover(chave);
    setItens((atual) => atual.map((i) => (i.chave === chave ? { ...i, quantidade } : i)));
  };

  const { quantidade, total, pendente } = totais(itens);
  const valor: SacolaCtx = { itens, quantidade, total, pendente, adicionar, alterarQuantidade, remover, limpar: () => setItens([]) };
  return <Ctx.Provider value={valor}>{children}</Ctx.Provider>;
}

export function useSacola(): SacolaCtx {
  const c = useContext(Ctx);
  if (!c) throw new Error("useSacola precisa estar dentro do SacolaProvider");
  return c;
}
