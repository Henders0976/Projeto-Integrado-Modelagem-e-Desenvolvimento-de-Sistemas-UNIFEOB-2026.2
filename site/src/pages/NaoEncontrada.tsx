import { Link } from "react-router-dom";
import { useTitulo } from "@/hooks/useTitulo";

export default function NaoEncontrada() {
  useTitulo("Página não encontrada");
  return (
    <div className="mx-auto flex min-h-[70vh] max-w-[520px] flex-col items-center justify-center px-6 pt-24 text-center">
      <p className="font-titulo text-[80px] leading-none">404</p>
      <h1 className="mt-4 text-[28px]">Não achamos essa página.</h1>
      <p className="mt-2 text-suave">O endereço pode ter mudado ou a peça saiu da coleção.</p>
      <div className="mt-8 flex flex-wrap justify-center gap-3">
        <Link to="/" className="btn-cheio">Voltar ao início</Link>
        <Link to="/loja" className="btn-contorno">Ver a coleção</Link>
      </div>
    </div>
  );
}
