import { useState, type FormEvent } from "react";
import { toast } from "sonner";
import { emailPlausivel, mensagemNovidades, urlWhatsApp } from "@/lib/formato";
import { ParallaxFoto } from "./Efeitos";
import FotoPeca from "./FotoPeca";

/**
 * Faixa "Novidades RV" com foto de fundo e campo de e-mail. Não há servidor de e-mail: o pedido segue
 * pelo WhatsApp da marca (shortcut: trocar por uma lista de e-mails quando a API tiver um endpoint de inscrição).
 */
export default function Novidades({ foto }: { foto?: string }) {
  const [email, setEmail] = useState("");
  const [erro, setErro] = useState<string | null>(null);

  function enviar(e: FormEvent) {
    e.preventDefault();
    if (!emailPlausivel(email)) return setErro("Informe um e-mail válido");
    setErro(null);
    window.open(urlWhatsApp(mensagemNovidades(email.trim())), "_blank", "noopener,noreferrer");
    toast("Pronto! Envie a mensagem no WhatsApp para entrar na lista.");
    setEmail("");
  }

  return (
    <section className="relative isolate overflow-hidden" aria-labelledby="novidades-titulo">
      {/* Sem foto (loja sem peças ativas) não há o que mostrar: nada de "Foto em breve" atrás do texto. */}
      {foto && (
        <ParallaxFoto className="absolute inset-0 -z-10" intensidade={50} escala={1.3}>
          <FotoPeca src={foto} alt="" posicao="50% 30%" className="h-full w-full" />
        </ParallaxFoto>
      )}
      <div className="absolute inset-0 -z-10 bg-black/60" />
      <div className="mx-auto max-w-md px-6 py-24 text-center">
        <h2 id="novidades-titulo" className="text-[34px] leading-tight">Novidades RV</h2>
        <p className="mt-3 text-suave">Receba lançamentos e peças novas direto no WhatsApp.</p>
        <form onSubmit={enviar} className="mt-7 text-left" noValidate>
          <label htmlFor="novidades-email" className="text-sm text-suave">Seu e-mail</label>
          <input
            id="novidades-email"
            type="email"
            autoComplete="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            aria-invalid={!!erro}
            aria-describedby={erro ? "novidades-erro" : undefined}
            className="campo"
          />
          {erro && <p id="novidades-erro" role="alert" className="mt-1 text-sm text-suave">{erro}</p>}
          <button type="submit" className="btn-cheio mt-5 w-full">Quero receber</button>
        </form>
      </div>
    </section>
  );
}
