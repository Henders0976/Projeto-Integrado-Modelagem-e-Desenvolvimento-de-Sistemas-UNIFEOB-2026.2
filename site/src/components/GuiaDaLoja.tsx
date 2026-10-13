import type { ReactNode } from "react";
import { formatarReais, urlWhatsApp } from "@/lib/formato";
import { contar, emFrase, semQuebra, type ResumoLoja } from "@/lib/resumo";
import { AoRolar } from "./Efeitos";

/**
 * "Antes de escolher": o que dá para saber sobre as peças sem abrir nenhuma (tamanhos, cores, preços) e como falar com a marca.
 * Tamanhos, cores e preços saem do catálogo; o atendimento repete o que a marca já diz no Sobre e no rodapé.
 * Nada aqui promete prazo, troca ou material: o catálogo não traz isso.
 */
export default function GuiaDaLoja({ resumo }: { resumo: ResumoLoja }) {
  const { tamanhos, acessorios, cores, menor, maior, aCombinar } = resumo;
  const linhas: { termo: string; conteudo: ReactNode }[] = [];

  if (tamanhos.length) {
    linhas.push({
      termo: "Tamanhos",
      conteudo: (
        <>
          {emFrase(tamanhos)} nas roupas.{acessorios > 0 ? " Os acessórios têm tamanho único." : ""} O tamanho se escolhe na página de cada peça.
        </>
      ),
    });
  }
  if (cores.length) {
    linhas.push({ termo: "Cores", conteudo: <>{emFrase(cores)}. Na página de cada peça aparecem as cores em que ela existe.</> });
  }
  if (menor != null || aCombinar > 0) {
    const faixa =
      menor == null || maior == null ? "" : menor === maior ? `${formatarReais(menor)}.` : `De ${formatarReais(menor)} a ${formatarReais(maior)}, conforme a peça.`;
    const combinar = aCombinar > 0 ? ` ${contar(aCombinar, "peça está", "peças estão")} com preço a combinar.` : "";
    linhas.push({ termo: "Preços", conteudo: <>{semQuebra(`${faixa}${combinar}`.trim())}</> });
  }
  linhas.push({
    termo: "Atendimento",
    conteudo: (
      <>
        Direto pelo WhatsApp, sem intermediário: cada compra é combinada com você.{" "}
        <a
          href={urlWhatsApp("Olá, RV Label! Gostaria de tirar uma dúvida.")}
          target="_blank"
          rel="noopener noreferrer"
          className="whitespace-nowrap underline decoration-texto/50 underline-offset-4 transition-colors hover:decoration-texto"
        >
          Falar com a marca<span className="sr-only"> (abre o WhatsApp em outra aba)</span>
        </a>
      </>
    ),
  });

  return (
    <section className="mx-auto max-w-[1100px] px-6 pt-28" aria-labelledby="guia-titulo">
      <div className="grid gap-10 lg:grid-cols-[4fr_7fr] lg:gap-16">
        <AoRolar dx={-48} dy={0}>
          <h2 id="guia-titulo" className="text-[32px] leading-[1.1] tracking-[-0.02em] lg:text-[42px]">
            Antes de escolher
          </h2>
          <p className="mt-4 max-w-[36ch] leading-[1.6] text-suave">O que dá para saber sobre as peças antes de abrir uma delas.</p>
        </AoRolar>

        <AoRolar>
          <dl className="border-t border-linha">
            {linhas.map((l) => (
              <div key={l.termo} className="grid gap-1.5 border-b border-linha py-5 sm:grid-cols-[8.5rem_1fr] sm:gap-6">
                <dt className="text-suave">{l.termo}</dt>
                <dd className="max-w-[60ch] text-[17px] leading-[1.6]">{l.conteudo}</dd>
              </div>
            ))}
          </dl>
        </AoRolar>
      </div>
    </section>
  );
}
