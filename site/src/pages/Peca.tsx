import { useState } from "react";
import { Link, useNavigate, useParams } from "react-router-dom";
import { toast } from "sonner";
import CartaoPeca from "@/components/CartaoPeca";
import { AoRolar } from "@/components/Efeitos";
import FotoPeca from "@/components/FotoPeca";
import SeletorQuantidade from "@/components/SeletorQuantidade";
import { useCatalogo } from "@/context/Catalogo";
import { useSacola } from "@/context/Sacola";
import { useTitulo } from "@/hooks/useTitulo";
import { CATEGORIAS, precoTexto } from "@/lib/catalogo";
import { formatarReais } from "@/lib/formato";
import NaoEncontrada from "./NaoEncontrada";

export default function Peca() {
  const { id } = useParams();
  const { pecas, carregando } = useCatalogo();
  const { adicionar } = useSacola();
  const navegar = useNavigate();
  const peca = pecas.find((p) => p.id === id);

  const [corIdx, setCorIdx] = useState(0);
  const [tamanho, setTamanho] = useState<string | null>(null);
  const [quantidade, setQuantidade] = useState(1);
  const [lado, setLado] = useState<"frente" | "costas">("frente");
  useTitulo(peca?.nome);

  if (carregando) return <p className="mx-auto max-w-[1000px] px-6 pt-36 text-suave">Carregando…</p>;
  if (!peca) return <NaoEncontrada />;

  const cor = peca.cores[Math.min(corIdx, peca.cores.length - 1)];
  const tam = tamanho ?? (peca.tamanhos.length === 1 ? peca.tamanhos[0] : null);
  const foto = lado === "costas" && peca.fotoCostas ? peca.fotoCostas : peca.fotos[0];
  const parecidas = [...pecas.filter((p) => p.categoria === peca.categoria && p.id !== peca.id), ...pecas.filter((p) => p.categoria !== peca.categoria)]
    .filter((p) => p.id !== peca.id)
    .slice(0, 3);

  function adicionarASacola() {
    if (!tam) return toast("Escolha o tamanho antes de adicionar.");
    adicionar(peca!, cor.nome, tam, quantidade);
    toast(`${quantidade}× ${peca!.nome} (${cor.nome}, ${tam}) na sacola.`, {
      action: { label: "Ver sacola", onClick: () => navegar("/sacola") },
    });
    setQuantidade(1);
  }

  const pilula = (ativa: boolean, aoTocar: () => void, rotulo: string, extra?: React.ReactNode) => (
    <button
      key={rotulo}
      type="button"
      aria-pressed={ativa}
      onClick={aoTocar}
      className={`flex min-h-[44px] min-w-[44px] items-center justify-center gap-2 rounded-[2px] border px-4 text-sm font-semibold transition ${
        ativa ? "border-texto bg-texto text-preto" : "border-linha hover:bg-white/10"
      }`}
    >
      {extra}
      {rotulo}
    </button>
  );

  return (
    <>
      <div className="mx-auto max-w-[1000px] px-6 pb-8 pt-28">
        <nav aria-label="Você está em" className="mb-6 text-sm text-suave">
          <Link to="/loja" className="hover:text-texto">Loja</Link>
          <span className="mx-2" aria-hidden>›</span>
          <Link to={`/loja?categoria=${peca.categoria}`} className="hover:text-texto">{CATEGORIAS[peca.categoria]}</Link>
          <span className="mx-2" aria-hidden>›</span>
          <span className="text-texto">{peca.nome}</span>
        </nav>

        <div className="grid items-start gap-10 lg:grid-cols-2 lg:gap-14">
          <div>
            {/* 3:4 e enquadramento do app (peca_page.dart): a foto inteira, sem cortar. O nome liga com o do cartão (Hero). */}
            <div
              className="aspect-[3/4] overflow-hidden rounded shadow-[0_16px_30px_rgba(0,0,0,0.35)]"
              style={{ viewTransitionName: "foto-peca" }}
            >
              <FotoPeca src={foto} cor={cor} alt={`${peca.nome}, ${lado}`} loading="eager" className="h-full w-full" posicao="50% 25%" />
            </div>
            {peca.fotoCostas && (
              <div className="mt-3 flex gap-2" role="group" aria-label="Lado da peça">
                {pilula(lado === "frente", () => setLado("frente"), "Frente")}
                {pilula(lado === "costas", () => setLado("costas"), "Costas")}
              </div>
            )}
          </div>

          <div className="flex flex-col">
            <p className="text-xs uppercase tracking-[0.3em] text-suave">
              {peca.tipo === "acessorio" ? "Acessório" : "Peça"} · {CATEGORIAS[peca.categoria]}
              {peca.material ? ` · ${peca.material}` : ""}
            </p>
            <h1 className="mt-3 text-[36px] leading-[1.1]">{peca.nome}</h1>
            <p className="mt-3 text-[28px] tabular-nums">{precoTexto(peca, formatarReais)}</p>
            {peca.descricao && <p className="mt-5 leading-relaxed text-suave">{peca.descricao}</p>}

            {peca.cores.length > 1 && (
              <fieldset className="mt-7">
                <legend className="mb-2 text-sm text-suave">Cor: <span className="text-texto">{cor.nome}</span></legend>
                <div className="flex flex-wrap gap-2">
                  {peca.cores.map((c, i) =>
                    pilula(i === corIdx, () => setCorIdx(i), c.nome,
                      <span className="relative inline-block h-5 w-5 overflow-hidden rounded-full ring-1 ring-linha">
                        <FotoPeca src={peca.fotos[0]} cor={c} alt="" posicao="50% 35%" className="absolute inset-0 h-full w-full scale-[4]" />
                      </span>),
                  )}
                </div>
              </fieldset>
            )}

            <fieldset className="mt-6">
              <legend className="mb-2 text-sm text-suave">Tamanho</legend>
              <div className="flex flex-wrap gap-2">
                {peca.tamanhos.map((t) => pilula(t === tam, () => setTamanho(t), t))}
              </div>
            </fieldset>

            <div className="mt-8 flex flex-wrap items-stretch gap-3">
              <SeletorQuantidade quantidade={quantidade} aoMudar={setQuantidade} />
              <button type="button" onClick={adicionarASacola} className="btn-cheio flex-1">Adicionar à sacola</button>
            </div>
            <p className="mt-4 text-sm text-suave">O pedido é fechado direto com a marca pelo WhatsApp, sem intermediário.</p>
          </div>
        </div>
      </div>

      {parecidas.length > 0 && (
        <section className="mx-auto max-w-[1000px] px-6 pb-8 pt-16" aria-labelledby="parecidas-titulo">
          <h2 id="parecidas-titulo" className="mb-8 text-[28px]">Você também pode gostar</h2>
          <div className="grid grid-cols-2 gap-x-4 gap-y-10 sm:grid-cols-3">
            {parecidas.map((p, i) => (
              <AoRolar key={p.id} escalonar={i * 0.1}>
                <CartaoPeca peca={p} transicao={false} />
              </AoRolar>
            ))}
          </div>
        </section>
      )}
    </>
  );
}
