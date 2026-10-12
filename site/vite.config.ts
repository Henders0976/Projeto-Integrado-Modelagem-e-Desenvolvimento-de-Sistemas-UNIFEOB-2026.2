import { defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react-swc";
import path from "node:path";

// VITE_BASE: subpasta de hospedagem (ex.: "/rvlabel_site/" no GitHub Pages). Padrão: raiz do domínio.
export default defineConfig({
  base: process.env.VITE_BASE ?? "/",
  plugins: [react()],
  resolve: { alias: { "@": path.resolve(__dirname, "./src") } },
  server: { port: 5173 },
  test: { environment: "node", include: ["src/**/*.test.ts"] },
});
