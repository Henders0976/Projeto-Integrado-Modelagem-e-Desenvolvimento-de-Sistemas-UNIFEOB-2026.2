import { formatarReais } from "./formato";

/** Peça + escolhas da cliente (cor, tamanho, quantidade). Guarda uma cópia dos dados da peça. */
export interface ItemSacola {
  chave: string;
  id: string;
  nome: string;
  preco: number | null;
  foto?: string;
  cor: string;
  tamanho: string;
  quantidade: number;
}

/** Mesma peça/cor/tamanho = mesmo item (soma a quantidade). */
export const chaveItem = (id: string, cor: string, tamanho: string): string => `${id}|${cor}|${tamanho}`;

export const subtotal = (i: ItemSacola): number | null => (i.preco == null ? null : i.preco * i.quantidade);

export function totais(itens: ItemSacola[]): { quantidade: number; total: number; pendente: boolean } {
  return {
    quantidade: itens.reduce((s, i) => s + i.quantidade, 0),
    total: itens.reduce((s, i) => s + (i.preco ?? 0) * i.quantidade, 0),
    pendente: itens.some((i) => i.preco == null),
  };
}

export function linhaPedido(i: ItemSacola): string {
  const s = subtotal(i);
  return `• ${i.quantidade}x ${i.nome} (${i.cor}, ${i.tamanho}) - ${s == null ? "preço a combinar" : formatarReais(s)}`;
}

/** Mensagem do WhatsApp: a mesma que o app monta ao fechar o pedido. */
export function mensagemPedido(itens: ItemSacola[], numeroPedido?: number): string {
  const { total, pendente } = totais(itens);
  const cabecalho = `Olá, RV Label! Quero fechar este pedido${numeroPedido == null ? "" : ` (nº ${numeroPedido})`}:`;
  const linhas = itens.map(linhaPedido).join("\n");
  return `${cabecalho}\n\n${linhas}\n\nTotal: ${formatarReais(total)}${pendente ? " + itens a combinar" : ""}\n`;
}
