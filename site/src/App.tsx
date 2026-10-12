import { createBrowserRouter, RouterProvider } from "react-router-dom";
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

// Roteador "de dados" (e não o <BrowserRouter>): só ele suporta a transição da foto entre páginas (View Transitions),
// o equivalente do Hero do app. As rotas e os provedores são os mesmos de antes.
const roteador = createBrowserRouter(
  [
    {
      element: (
        <CatalogoProvider>
          <SacolaProvider>
            <Layout />
          </SacolaProvider>
        </CatalogoProvider>
      ),
      children: [
        { index: true, element: <Home /> },
        { path: "loja", element: <Loja /> },
        { path: "peca/:id", element: <Peca /> },
        { path: "sacola", element: <Sacola /> },
        { path: "colecoes/:slug", element: <Colecao /> },
        { path: "sobre", element: <Sobre /> },
        { path: "contato", element: <Contato /> },
        { path: "meus-pedidos", element: <MeusPedidos /> },
        { path: "privacidade", element: <Privacidade /> },
        { path: "*", element: <NaoEncontrada /> },
      ],
    },
  ],
  {
    basename,
    future: {
      v7_relativeSplatPath: true,
      v7_fetcherPersist: true,
      v7_normalizeFormMethod: true,
      v7_partialHydration: true,
      v7_skipActionErrorRevalidation: true,
    },
  },
);

export default function App() {
  return <RouterProvider router={roteador} future={{ v7_startTransition: true }} />;
}
