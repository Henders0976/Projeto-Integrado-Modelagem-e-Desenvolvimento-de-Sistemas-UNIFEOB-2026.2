import { Shirt } from "lucide-react";
import { useState } from "react";
import type { Cor } from "@/lib/catalogo";

interface Props {
  src?: string;
  /** Cor escolhida: a foto original é recolorida (tom pinta mantendo a luz; hue gira o matiz). */
  cor?: Cor;
  alt: string;
  className?: string;
  /** Enquadramento da foto (CSS object-position). */
  posicao?: string;
  loading?: "lazy" | "eager";
}

function EmBreve({ className }: { className: string }) {
  return (
    <div className={`flex flex-col items-center justify-center gap-1 bg-white/10 text-xs text-suave ${className}`}>
      <Shirt className="h-10 w-10" aria-hidden />
      Foto em breve
    </div>
  );
}

/** Foto da peça já recolorida pela cor escolhida, ou "Foto em breve" quando a peça não tem foto (ou ela não carregou). */
export default function FotoPeca({ src, ...resto }: Props) {
  if (!src) return <EmBreve className={resto.className ?? ""} />;
  // A chave troca o estado (carregou/falhou) junto com a foto: frente -> costas começa de novo, com o fade.
  return <Quadro key={src} src={src} {...resto} />;
}

function Quadro({ src, cor, alt, className = "", posicao = "50% 12%", loading = "lazy" }: Props & { src: string }) {
  const [pronta, setPronta] = useState(false);
  const [falhou, setFalhou] = useState(false);
  if (falhou) return <EmBreve className={className} />;

  const filtro = cor && !cor.tom && cor.hue ? `hue-rotate(${cor.hue}deg)` : undefined;
  // "relative" e "absolute" na mesma classe: no CSS do Tailwind o relative vence e as fotos empilhadas da vitrine
  // (absolute inset-0) deixariam de se sobrepor. Só vira relative se quem chama não pediu outro posicionamento.
  const posicionamento = /\b(absolute|fixed|sticky)\b/.test(className) ? "" : "relative";
  return (
    <div className={`${posicionamento} isolate overflow-hidden bg-white/10 ${className}`}>
      <img
        // Foto que já estava no cache não dispara onLoad a tempo: confere aqui também.
        ref={(el) => {
          if (el?.complete && el.naturalWidth > 0) setPronta(true);
        }}
        src={src}
        alt={alt}
        loading={loading}
        decoding="async"
        onLoad={() => setPronta(true)}
        onError={() => setFalhou(true)}
        className="foto-img h-full w-full object-cover"
        style={{ filter: filtro, objectPosition: posicao, opacity: pronta ? 1 : 0 }}
      />
      {cor?.tom && (
        <div
          aria-hidden
          className="foto-img pointer-events-none absolute inset-0"
          style={{ backgroundColor: cor.tom, mixBlendMode: "color", opacity: pronta ? 1 : 0 }}
        />
      )}
    </div>
  );
}
