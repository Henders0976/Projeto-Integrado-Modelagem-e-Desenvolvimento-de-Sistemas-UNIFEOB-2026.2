import type { ItemSacola } from "./pedido";

/** Endereço da API (Node + MySQL). Vazio = site estático, sem gravar pedidos. */
export const API_URL: string = String(import.meta.env.VITE_API_URL ?? "")
  .trim()
  .replace(/\/+$/, "");

/** Erro de regra devolvido pelo servidor (ex.: "Sem estoque"). Falha de rede não é ApiErro. */
export class ApiErro extends Error {}

/** fetch + JSON com limite de tempo. Resposta com erro vira ApiErro com a mensagem do servidor. */
export async function getJson(url: string, ms = 6000, init: RequestInit = {}): Promise<unknown> {
  const ctl = new AbortController();
  const timer = setTimeout(() => ctl.abort(), ms);
  try {
    const r = await fetch(url, { ...init, signal: ctl.signal });
    const texto = await r.text();
    const corpo: unknown = texto ? JSON.parse(texto) : null;
    if (!r.ok) {
      const erro = corpo && typeof corpo === "object" ? (corpo as { erro?: unknown }).erro : null;
      throw new ApiErro(typeof erro === "string" ? erro : `Erro ${r.status}`);
    }
    return corpo;
  } finally {
    clearTimeout(timer);
  }
}

export interface Comprador {
  nome: string;
  telefone: string;
  cpf: string | null;
}

/** Grava o pedido e devolve o número. */
export async function enviarPedido(itens: ItemSacola[], comprador: Comprador): Promise<number> {
  const corpo = (await getJson(`${API_URL}/pedidos`, 8000, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      comprador,
      itens: itens.map((i) => ({ produtoId: i.id, cor: i.cor, tamanho: i.tamanho, quantidade: i.quantidade })),
    }),
  })) as { id?: unknown } | null;
  if (!corpo || typeof corpo.id !== "number") throw new ApiErro("Resposta inesperada do servidor.");
  return corpo.id;
}

export interface PedidoConsultado {
  id: number;
  /** Data do pedido (ISO). Só a etapa "Recebido" tem data: a API não guarda quando o status mudou. */
  data?: string;
  status: string;
  total: number;
  precoPendente: boolean;
  itens: { nome: string; cor: string; tamanho: string; quantidade: number; subtotal: number | null }[];
}

/** Consulta pública: exige o número do pedido e o telefone usado nele. */
export async function consultarPedido(id: number, telefone: string): Promise<PedidoConsultado> {
  return (await getJson(`${API_URL}/pedidos/${id}?telefone=${encodeURIComponent(telefone)}`)) as PedidoConsultado;
}
