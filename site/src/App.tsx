import { BrowserRouter, Route, Routes } from "react-router-dom";
import Layout from "@/components/Layout";
import { CatalogoProvider } from "@/context/Catalogo";
import { SacolaProvider } from "@/context/Sacola";
import Colecao from "@/pages/Colecao";
import Contato from "@/pages/Contato";
import Home from "@/pages/Home";
import Loja from "@/pages/Loja";
import MeusPedidos from "@/pages/MeusPedidos";
import NaoEncontrada from "@/pages/NaoEncontrada";
import Peca from "@/pages/Peca";
import Privacidade from "@/pages/Privacidade";
import Sacola from "@/pages/Sacola";
import Sobre from "@/pages/Sobre";

// Hospedado numa subpasta (VITE_BASE=/rvlabel_site/)? O roteador precisa saber, sem a barra final.
const basename = import.meta.env.BASE_URL.replace(/\/$/, "") || undefined;

export default function App() {
  return (
    <BrowserRouter basename={basename} future={{ v7_startTransition: true, v7_relativeSplatPath: true }}>
      <CatalogoProvider>
        <SacolaProvider>
          <Routes>
            <Route element={<Layout />}>
              <Route index element={<Home />} />
              <Route path="loja" element={<Loja />} />
              <Route path="peca/:id" element={<Peca />} />
              <Route path="sacola" element={<Sacola />} />
              <Route path="colecoes/:slug" element={<Colecao />} />
              <Route path="sobre" element={<Sobre />} />
              <Route path="contato" element={<Contato />} />
              <Route path="meus-pedidos" element={<MeusPedidos />} />
              <Route path="privacidade" element={<Privacidade />} />
              <Route path="*" element={<NaoEncontrada />} />
            </Route>
          </Routes>
        </SacolaProvider>
      </CatalogoProvider>
    </BrowserRouter>
  );
}
