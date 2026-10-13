import { ArrowRight } from "lucide-react";
import { Link } from "react-router-dom";
import { formatarReais } from "@/lib/formato";
import { contar, faixaDePreco, semQuebra, type ResumoLoja } from "@/lib/resumo";
import { AoRolar } from "./Efeitos";

/**
 * Índice da coleção por categoria: quantas peças tem e quanto custam, e cada linha leva à Loja já filtrada.
 * Tudo vem do catálogo (ResumoLoja), então acompanha o que está à venda. A linha que se desenha no hover é a
 * mesma "linha de tinta" do cabeçalho; as outras linhas se apagam um pouco, como na vitrine da Loja.
 */
export default function IndiceCategorias({ resumo }: { resumo: ResumoLoja }) {
  const { total, categorias, menor, maior } = resumo;
  const preco = menor == null || maior == null ? "" : menor === maior ? `, por ${formatarReais(menor)}` : `, de ${formatarReais(menor)} a ${formatarReais(maior)}`;

  return (
    <section className="mx-auto max-w-[1100px] px-6 pt-28" aria-labelledby="indice-titulo">
      <div className="grid gap-10 lg:grid-cols-[4fr_7fr] lg:gap-16">
        <AoRolar dx={-48} dy={0}>
          <h2 id="indice-titulo" className="text-[32px] leading-[1.1] tracking-[-0.02em] lg:text-[42px]">
            Tudo o que a Essence tem hoje
          </h2>
          <p className="mt-4 max-w-[36ch] leading-[1.6] text-suave">
            {contar(total, "peça", "peças")} em {contar(categorias.length, "categoria", "categorias")}
            {semQuebra(preco)}. Escolha por onde começar.
          </p>
        </AoRolar>

        <ul className="group/indice border-t border-linha">
          {categorias.map((c, i) => {
            const faixa = faixaDePreco(c.menor, c.maior, formatarReais);
            return (
              <li key={c.categoria}>
                <AoRolar dy={32} escalonar={Math.min(0.3, i * 0.06)}>
                  <Link
                    to={`/loja?categoria=${c.categoria}`}
                    aria-label={`${c.rotulo}: ${contar(c.quantidade, "peça", "peças")}${faixa ? `, ${faixa}` : ""}. Ver na loja`}
                    className="group relative grid grid-cols-[1fr_auto] items-baseline gap-x-6 gap-y-1.5 border-b border-linha py-5 transition-colors duration-300 after:absolute after:inset-x-0 after:-bottom-px after:h-px after:origin-left after:scale-x-0 after:bg-texto after:transition-transform after:duration-500 after:[transition-timing-function:cubic-bezier(0.22,1,0.36,1)] group-hover/indice:text-texto/50 hover:!text-texto hover:after:scale-x-100 focus-visible:!text-texto focus-visible:after:scale-x-100 motion-reduce:transition-none motion-reduce:after:transition-none sm:grid-cols-[1fr_6.5rem_13rem_1.5rem]"
                  >
                    <span className="col-start-1 row-start-1 font-titulo text-[clamp(28px,4vw,38px)] leading-none transition-transform duration-500 group-hover:translate-x-1.5 motion-reduce:transition-none sm:col-auto sm:row-auto">
                      {c.rotulo}
                    </span>
                    <span className="col-span-2 row-start-2 flex gap-5 text-sm tabular-nums text-suave sm:contents">
                      <span>{contar(c.quantidade, "peça", "peças")}</span>
                      <span>{faixa ? semQuebra(faixa) : "Preço a combinar"}</span>
                    </span>
                    <ArrowRight
                      aria-hidden
                      className="col-start-2 row-start-1 h-5 w-5 justify-self-end self-center transition-transform duration-300 group-hover:translate-x-1 motion-reduce:transition-none sm:col-auto sm:row-auto"
                    />
                  </Link>
                </AoRolar>
              </li>
            );
          })}
        </ul>
      </div>
    </section>
  );
}
