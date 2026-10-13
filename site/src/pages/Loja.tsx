import { LayoutGrid, List } from "lucide-react";
import { useSearchParams } from "react-router-dom";
import CartaoPeca from "@/components/CartaoPeca";
import { AoRolar } from "@/components/Efeitos";
import Vitrine from "@/components/Vitrine";
import { useCatalogo } from "@/context/Catalogo";
import { useTitulo } from "@/hooks/useTitulo";
import { CATEGORIAS, type Categoria } from "@/lib/catalogo";

export default function Loja() {
  useTitulo("Loja");
  const { pecas, carregando, erro } = useCatalogo();
  const [params, setParams] = useSearchParams();
  const pedida = params.get("categoria");
  const ativa: Categoria | null = pedida && pedida in CATEGORIAS ? (pedida as Categoria) : null;
  const grade = params.get("vista") === "grade";
  const lista = ativa ? pecas.filter((p) => p.categoria === ativa) : pecas;
  const categorias = (Object.keys(CATEGORIAS) as Categoria[]).filter((c) => pecas.some((p) => p.categoria === c));

  // Troca um parâmetro da URL sem perder os outros (categoria e vista convivem).
  const mudar = (chave: string, valor: string | null) => {
    const novos = new URLSearchParams(params);
    if (valor) novos.set(chave, valor);
    else novos.delete(chave);
    setParams(novos);
  };

  const pilula = (rotulo: string, valor: Categoria | null) => (
    <button
      key={rotulo}
      type="button"
      aria-pressed={ativa === valor}
      onClick={() => mudar("categoria", valor)}
      className={`min-h-[44px] shrink-0 rounded-[2px] border px-4 text-sm font-semibold tracking-wide transition ${
        ativa === valor ? "border-texto bg-texto text-preto" : "border-linha text-texto hover:bg-white/10"
      }`}
    >
      {rotulo}
    </button>
  );

  return (
    <div className="mx-auto max-w-[1100px] px-6 pb-8 pt-32">
      <AoRolar>
        <div className="flex items-end justify-between gap-4">
          <div>
            <h1 className="text-[40px] leading-tight">A coleção Essence</h1>
            <p className="mt-2.5 max-w-xl text-suave">Passe o mouse (ou toque) num nome para ver a peça e abra para os detalhes. Filtre por categoria logo abaixo, ou troque para a grade.</p>
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
              onClick={() => mudar("vista", eGrade ? "grade" : null)}
              className={`grid h-11 w-11 place-items-center rounded-[2px] border transition ${
                grade === eGrade ? "border-texto bg-texto text-preto" : "border-linha text-texto hover:bg-white/10"
              }`}
            >
              <Icone className="h-4 w-4" aria-hidden />
            </button>
          ))}
        </div>
      </div>

      {/* min-h: a página curta deixaria o rodapé na tela, e a lista, ao chegar, o empurraria para baixo. */}
      {carregando && <p className="mt-8 min-h-[100svh] text-suave">Carregando a coleção…</p>}
      {erro && <p role="alert" className="mt-8 text-suave">Não consegui carregar o catálogo agora. Tente recarregar a página.</p>}
      {!carregando && !erro && lista.length === 0 && <p className="mt-8 text-center text-suave">Ainda não temos peças nessa categoria.</p>}

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
