import { AoRolar, ParallaxFoto } from "@/components/Efeitos";
import FotoPeca from "@/components/FotoPeca";
import { useCatalogo } from "@/context/Catalogo";
import { useTitulo } from "@/hooks/useTitulo";

const texto = "text-[17px] leading-[1.65]";

export default function Sobre() {
  useTitulo("Sobre");
  const { pecas } = useCatalogo();
  const foto = [...pecas].reverse().find((p) => p.fotos.length)?.fotos[0];

  return (
    <article className="mx-auto max-w-[720px] px-6 pb-8 pt-36">
      <AoRolar dx={-64} dy={0}>
        <h1 className="text-[40px] leading-[1.1] tracking-[-0.02em] md:text-[52px]">Uma exploração de corte e identidade.</h1>
      </AoRolar>

      <div className="mt-12 space-y-5">
        <AoRolar>
          <p className={texto}>
            A RV Label nasceu da vontade de fazer moda com identidade: roupa que veste história, não tendência. Cada peça da coleção
            Essence é pensada com carinho, com cortes assimétricos, um ombro só e decotes que respiram.
          </p>
        </AoRolar>
        <AoRolar>
          <p className={texto}>
            Nosso ritmo é lento de propósito. Produzimos em pequenos lotes, e as peças são feitas pra durar no guarda-roupa e no
            visual — nada de excesso, só o que vale a pena vestir.
          </p>
        </AoRolar>
      </div>

      <AoRolar className="mt-14">
        <div className="aspect-[4/5] overflow-hidden rounded">
          <ParallaxFoto className="h-full w-full" intensidade={40} escala={1.2}>
            <FotoPeca src={foto} alt="" posicao="50% 15%" className="h-full w-full" />
          </ParallaxFoto>
        </div>
      </AoRolar>

      <div className="mt-14 space-y-5">
        <AoRolar>
          <p className={texto}>
            Cada compra é combinada direto com você, pelo WhatsApp, sem intermediário e sem pressa. Você escolhe a peça, a cor e o
            tamanho, e a gente cuida do resto.
          </p>
        </AoRolar>
        <AoRolar>
          <p className={texto}>Quando você veste RV Label, leva junto a intenção de quem cuidou de cada detalhe.</p>
        </AoRolar>
      </div>
      <p className="mt-10 text-suave">Moda por RV Label</p>
    </article>
  );
}
