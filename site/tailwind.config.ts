import type { Config } from "tailwindcss";

// Tokens do DESIGN.md, os mesmos do app (lib/ui/tema.dart: RvColors, RvRadius).
// Os nomes antigos (vermelho, preto, texto, suave, painel, linha) continuam, apontando para os tokens novos.
export default {
  content: ["./index.html", "./src/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        vermelho: { DEFAULT: "#B3121E", hover: "#C8202D", suave: "rgba(179, 18, 30, 0.14)" },
        preto: "#0B0B0C",
        painel: "#141416",
        elevado: "#1C1C1F",
        linha: "#2A2A2E",
        texto: "#F4F1EE",
        suave: "#A8A3A0",
        mudo: "#6E6A68",
        sucesso: "#2E9E6A",
        aviso: "#D9A441",
        perigo: "#E5484D",
        info: "#5B8DEF",
      },
      fontFamily: {
        sans: ["Manrope", "system-ui", "sans-serif"],
        titulo: ['"DM Serif Display"', "Georgia", "serif"],
      },
      borderRadius: { sm: "6px", DEFAULT: "10px", lg: "16px" },
    },
  },
  plugins: [],
} satisfies Config;
