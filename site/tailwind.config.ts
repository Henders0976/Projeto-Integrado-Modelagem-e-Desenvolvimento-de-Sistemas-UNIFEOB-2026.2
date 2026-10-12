import type { Config } from "tailwindcss";

// Cores e fonte do app RV Label (lib/ui/tema.dart): vermelho que desce até o preto.
export default {
  content: ["./index.html", "./src/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        vermelho: "#B3121E",
        preto: "#0B0B0B",
        texto: "#FFF7F5",
        suave: "#F0D6D6",
        painel: "#150E0F",
        linha: "rgba(255, 247, 245, 0.35)",
      },
      fontFamily: {
        titulo: ['"DM Serif Display"', "Georgia", "serif"],
      },
      borderRadius: { DEFAULT: "4px" },
    },
  },
  plugins: [],
} satisfies Config;
