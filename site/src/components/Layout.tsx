import { useEffect } from "react";
import { Outlet, useLocation } from "react-router-dom";
import { Toaster } from "sonner";
import { ativarRolagemSuave } from "@/lib/rolagemSuave";
import Footer from "./Footer";
import Header from "./Header";

/** Ao trocar de página, volta ao topo (a menos que a URL tenha #âncora). */
function ScrollToTop() {
  const { pathname, hash } = useLocation();
  useEffect(() => {
    if (!hash) window.scrollTo(0, 0);
  }, [pathname, hash]);
  return null;
}

export default function Layout() {
  // Roda do mouse desliza em vez de pular, como no app (ControladorSuave).
  useEffect(() => ativarRolagemSuave(), []);
  return (
    <div className="flex min-h-screen flex-col">
      <ScrollToTop />
      <Header />
      <main className="flex-1">
        <Outlet />
      </main>
      <Footer />
      <Toaster position="bottom-center" toastOptions={{ style: { background: "#1C1C1F", color: "#F4F1EE", border: "1px solid #2A2A2E", borderRadius: 10 } }} />
    </div>
  );
}
