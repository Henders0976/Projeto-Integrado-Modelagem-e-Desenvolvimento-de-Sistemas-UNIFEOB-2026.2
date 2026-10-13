import { getJson } from "./api";

/** Categorias do catálogo (mesmos nomes do app: lib/models/categoria.dart). */
export const CATEGORIAS = {
  blusas: "Blusas",
  vestidos: "Vestidos",
  tops: "Tops",
  bodys: "Bodys",
  shorts: "Shorts",
  acessorios: "Acessórios",
} as const;
export type Categoria = keyof typeof CATEGORIAS;

/** Uma cor da peça: a foto original é recolorida (hue gira o matiz; tom pinta mantendo a luz). */
export interface Cor {
  nome: string;
  hue: number;
  tom?: string;
}

export interface Peca {
  id: string;
  nome: string;
  categoria: Categoria;
  tipo: "peca" | "acessorio";
  descricao: string;
  preco: number | null; // null = "preço a combinar"
  fotos: string[];
  fotoCostas?: string;
  cores: Cor[];
  tamanhos: string[];
  material?: string;
}

const BASE = import.meta.env.BASE_URL;

/** "assets/fotos/x.jpg" (caminho do app) -> URL pública do site. */
export function urlFoto(caminho: string): string {
  if (/^https?:\/\//.test(caminho)) return caminho;
  return `${BASE}${caminho.replace(/^\/?assets\//, "").replace(/^\//, "")}`;
}

const texto = (v: unknown): string => (typeof v === "string" ? v : "");

function normalizarPeca(j: Record<string, unknown>): Peca {
  const categoria = texto(j.categoria);
  if (!(categoria in CATEGORIAS)) throw new Error(`categoria desconhecida: "${categoria}"`);
  const id = texto(j.id);
  const nome = texto(j.nome);
  if (!id || !nome) throw new Error("peça sem id ou nome");

  const tipo = j.tipo === "acessorio" ? "acessorio" : "peca";
  const cores: Cor[] = (Array.isArray(j.cores) ? j.cores : [])
    .map((c: Record<string, unknown>) => ({
      nome: texto(c.nome),
      hue: Number(c.hue ?? 0) || 0,
      tom: typeof c.tom === "string" ? c.tom : undefined,
    }))
    .filter((c) => c.nome);
  const tamanhos =
    tipo === "acessorio"
      ? ["Único"]
      : Array.isArray(j.tamanhos) && j.tamanhos.length
        ? j.tamanhos.map(String)
        : ["P", "M", "G"];
  const preco = j.preco == null || j.preco === "" ? null : Number(j.preco);

  return {
    id,
    nome,
    categoria: categoria as Categoria,
    tipo,
    descricao: texto(j.descricao),
    preco: preco != null && Number.isFinite(preco) ? preco : null,
    fotos: (Array.isArray(j.fotos) ? j.fotos : []).map(String).map(urlFoto),
    fotoCostas: typeof j.fotoCostas === "string" ? urlFoto(j.fotoCostas) : undefined,
    cores: cores.length ? cores : [{ nome: "Única", hue: 0 }],
    tamanhos,
    material: typeof j.material === "string" ? j.material : undefined,
  };
}

/**
 * Monta o catálogo a partir do JSON. Peça inválida (ex.: categoria desconhecida) é ignorada, não derruba o site.
 * O campo `ativo` do catalogo.json é só do app (lá o catálogo vem desativado): o site mostra o catálogo inteiro.
 */
export function normalizarCatalogo(dados: unknown): Peca[] {
  const lista = dados && typeof dados === "object" ? (dados as { pecas?: unknown }).pecas : null;
  if (!Array.isArray(lista)) throw new Error("catálogo inválido: falta a lista 'pecas'");
  const pecas: Peca[] = [];
  for (const p of lista) {
    try {
      pecas.push(normalizarPeca(p as Record<string, unknown>));
    } catch (e) {
      console.warn("Peça ignorada:", (p as { id?: unknown })?.id, e);
    }
  }
  return pecas;
}

/**
 * Catálogo do site: sempre o catalogo.json que vai junto com ele, com ou sem API.
 * A API (`GET /produtos`) só devolve o que a administradora ativou no app; se o site a usasse, ficaria vazio
 * enquanto o catálogo estiver desativado. A API serve ao site só para gravar e consultar pedidos.
 */
export async function carregarCatalogo(): Promise<Peca[]> {
  return normalizarCatalogo(await getJson(`${BASE}catalogo.json`, 10000));
}

export const precoTexto = (p: Peca, formatar: (v: number) => string): string =>
  p.preco == null ? "Preço a combinar" : formatar(p.preco);
