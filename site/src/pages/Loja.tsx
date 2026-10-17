import { LayoutGrid, List, SearchX } from "lucide-react";
import { useSearchParams } from "react-router-dom";
import CartaoPeca from "@/components/CartaoPeca";
import { AoRolar } from "@/components/Efeitos";
import Vitrine from "@/components/Vitrine";
import { useCatalogo } from "@/context/Catalogo";
import { useTitulo } from "@/hooks/useTitulo";
import { CATEGORIAS, type Categoria } from "@/lib/catalogo";
import { FAIXAS, filtrarVitrine, ORDENS, type Faixa, type Ordem } from "@/lib/filtro";

/** Valor da URL só vale se for uma das opções (link velho ou editado à mão não quebra a página). */
const opcao = <T extends string>(valor: string | null, opcoes: readonly T[]): T | null =>
  valor && (opcoes as readonly string[]).includes(valor) ? (valor as T) : null;

export default function Loja() {
  useTitulo("Loja");
  const { pecas, carregando, erro } = useCatalogo();
  const [params, setParams] = useSearchParams();
  const ativa = opcao(params.get("categoria"), Object.keys(CATEGORIAS) as Categoria[]);
  const grade = params.get("vista") === "grade";
  const daCategoria = ativa ? pecas.filter((p) => p.categoria === ativa) : pecas;
  const categorias = (Object.keys(CATEGORIAS) as Categoria[]).filter((c) => pecas.some((p) => p.categoria === c));

  // Opções dos filtros vêm da categoria aberta: nunca oferece um tamanho ou cor que não existe nela.
  const tamanhos = [...new Set(daCategoria.flatMap((p) => p.tamanhos))];
  const cores = [...new Set(daCategoria.flatMap((p) => p.cores.map((c) => c.nome)))].sort((a, b) => a.localeCompare(b, "pt-BR"));
  const filtros = {
    tamanho: opcao(params.get("tamanho"), tamanhos),
    cor: opcao(params.get("cor"), cores),
    faixa: opcao(params.get("preco"), Object.keys(FAIXAS) as Faixa[]),
    ordem: opcao(params.get("ordem"), Object.keys(ORDENS) as Ordem[]),
  };
  const lista = filtrarVitrine(daCategoria, filtros);
  const comFiltro = !!(filtros.tamanho || filtros.cor || filtros.faixa);

  // Troca parâmetros da URL sem perder os outros (categoria, vista e filtros convivem).
  const mudar = (trocas: Record<string, string | null>) => {
    const novos = new URLSearchParams(params);
    for (const [chave, valor] of Object.entries(trocas)) {
      if (valor) novos.set(chave, valor);
      else novos.delete(chave);
    }
    setParams(novos, { replace: true, preventScrollReset: true });
  };
  const limparFiltros = () => mudar({ tamanho: null, cor: null, preco: null });

  const pilula = (rotulo: string, valor: Categoria | null) => (
    <button key={rotulo} type="button" aria-pressed={ativa === valor} onClick={() => mudar({ categoria: valor })} className="pilula">
      {rotulo}
    </button>
  );

  const seletor = (chave: string, rotulo: string, valor: string | null, opcoes: [string, string][], vazio: string) => (
    <label className="block min-w-0">
      <span className="rotulo">{rotulo}</span>
      <select className="campo" value={valor ?? ""} onChange={(e) => mudar({ [chave]: e.target.value || null })}>
        <option value="">{vazio}</option>
        {opcoes.map(([v, r]) => (
          <option key={v} value={v}>{r}</option>
        ))}
      </select>
    </label>
  );

  return (
    <div className="mx-auto max-w-[1100px] px-6 pb-8 pt-32">
      <AoRolar>
        <div className="flex items-end justify-between gap-4">
          <div>
            <h1 className="text-[40px] leading-tight">A coleção Essence</h1>
            <p className="mt-2.5 max-w-xl text-suave">Passe o mouse (ou toque) num nome para ver a peça e abra para os detalhes. Filtre logo abaixo, ou troque para a grade.</p>
          </div>
          <p className="shrink-0 text-suave tabular-nums" aria-live="polite">
            {lista.length} {lista.length === 1 ? "peça" : "peças"}
          </p>
        </div>
      </AoRolar>

      <div className="mt-6 flex items-start justify-between gap-3">
        <div className="-ml-6 flex gap-2 overflow-x-auto pb-4 pl-6" role="group" aria-label="Filtrar por categoria">
          {pilula("Todos", null)}
          {categorias.map((c) => pilula(CATEGORIAS[c], c))}
        </div>
        <div className="flex shrink-0 gap-1" role="group" aria-label="Modo de exibição">
          {(
            [
              ["Vitrine", List, false],
              ["Grade", LayoutGrid, true],
            ] as const
          ).map(([rotulo, Icone, eGrade]) => (
            <button
              key={rotulo}
              type="button"
              aria-pressed={grade === eGrade}
              aria-label={rotulo}
              title={rotulo}
              onClick={() => mudar({ vista: eGrade ? "grade" : null })}
              className="pilula w-11 px-0"
            >
              <Icone className="h-4 w-4" aria-hidden />
            </button>
          ))}
        </div>
      </div>

      {pecas.length > 0 && (
        <div className="grid grid-cols-2 gap-3 md:grid-cols-4" role="group" aria-label="Filtros">
          {seletor("tamanho", "Tamanho", filtros.tamanho, tamanhos.map((t) => [t, t]), "Todos")}
          {seletor("cor", "Cor", filtros.cor, cores.map((c) => [c, c]), "Todas")}
          {seletor("preco", "Preço", filtros.faixa, Object.entries(FAIXAS).map(([k, f]) => [k, f.rotulo]), "Qualquer")}
          {seletor("ordem", "Ordenar", filtros.ordem === "destaque" ? null : filtros.ordem, [["menor", ORDENS.menor], ["maior", ORDENS.maior]], ORDENS.destaque)}
        </div>
      )}

      {/* min-h: a página curta deixaria o rodapé na tela, e a lista, ao chegar, o empurraria para baixo. */}
      {carregando && <p className="mt-8 min-h-[100svh] text-suave">Carregando a coleção…</p>}
      {erro && <p role="alert" className="mt-8 text-perigo">Não consegui carregar o catálogo agora. Tente recarregar a página.</p>}
      {!carregando && !erro && lista.length === 0 && (
        <div className="mt-12 flex flex-col items-center text-center">
          <SearchX className="h-10 w-10 text-mudo" aria-hidden />
          <p className="mt-4 font-titulo text-[26px]">{comFiltro ? "Nenhuma peça com esses filtros" : "Ainda não temos peças nessa categoria."}</p>
          {comFiltro && (
            <button type="button" onClick={limparFiltros} className="btn-contorno mt-6">Limpar filtros</button>
          )}
        </div>
      )}

      {grade ? (
        // A chave inclui o filtro: ao trocar de categoria os cartões entram de novo.
        <div className="mt-6 grid grid-cols-2 gap-x-4 gap-y-10 md:grid-cols-3 lg:grid-cols-4">
          {lista.map((p, i) => (
            <AoRolar key={`${ativa}-${p.id}`} escalonar={(i % 4) * 0.1}>
              <CartaoPeca peca={p} />
            </AoRolar>
          ))}
        </div>
      ) : (
        <div className="mt-6">
          <Vitrine key={ativa ?? "todos"} pecas={lista} />
        </div>
      )}
    </div>
  );
}
