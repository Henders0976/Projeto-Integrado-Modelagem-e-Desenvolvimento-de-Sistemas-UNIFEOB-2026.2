import { Shirt } from "lucide-react";
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

/** Foto da peça já recolorida pela cor escolhida, ou "Foto em breve" quando a peça não tem foto. */
export default function FotoPeca({ src, cor, alt, className = "", posicao = "50% 12%", loading = "lazy" }: Props) {
  if (!src) {
    return (
      <div className={`flex flex-col items-center justify-center gap-1 bg-white/10 text-xs text-suave ${className}`}>
        <Shirt className="h-10 w-10" aria-hidden />
        Foto em breve
      </div>
    );
  }
  const filtro = cor && !cor.tom && cor.hue ? `hue-rotate(${cor.hue}deg)` : undefined;
  return (
    <div className={`relative isolate overflow-hidden bg-white/10 ${className}`}>
      <img
        src={src}
        alt={alt}
        loading={loading}
        decoding="async"
        className="h-full w-full object-cover"
        style={{ filter: filtro, objectPosition: posicao }}
      />
      {cor?.tom && (
        <div
          aria-hidden
          className="pointer-events-none absolute inset-0"
          style={{ backgroundColor: cor.tom, mixBlendMode: "color" }}
        />
      )}
    </div>
  );
}
