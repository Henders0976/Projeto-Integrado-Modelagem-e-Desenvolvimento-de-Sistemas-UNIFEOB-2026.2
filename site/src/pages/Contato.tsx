import { MessageCircle } from "lucide-react";
import { useState, type FormEvent } from "react";
import { toast } from "sonner";
import { AoRolar } from "@/components/Efeitos";
import Novidades from "@/components/Novidades";
import { useCatalogo } from "@/context/Catalogo";
import { useTitulo } from "@/hooks/useTitulo";
import { emailPlausivel, mensagemContato, urlWhatsApp } from "@/lib/formato";

/** Contato: texto de boas-vindas e formulário que segue pelo WhatsApp. */
export default function Contato() {
  useTitulo("Contato");
  const { pecas } = useCatalogo();
  const foto = [...pecas].reverse().find((p) => p.fotos.length)?.fotos[0];
  const [erros, setErros] = useState<Record<string, string>>({});

  function enviar(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const form = e.currentTarget;
    const f = new FormData(form);
    const dados = {
      nome: String(f.get("nome") ?? "").trim(),
      email: String(f.get("email") ?? "").trim(),
      assunto: String(f.get("assunto") ?? "").trim(),
      mensagem: String(f.get("mensagem") ?? "").trim(),
    };
    const novos: Record<string, string> = {};
    if (!dados.nome) novos.nome = "Campo obrigatório";
    if (!emailPlausivel(dados.email)) novos.email = "Informe um e-mail válido";
    if (!dados.assunto) novos.assunto = "Campo obrigatório";
    if (!dados.mensagem) novos.mensagem = "Campo obrigatório";
    setErros(novos);
    if (Object.keys(novos).length) return;
    window.open(urlWhatsApp(mensagemContato(dados)), "_blank", "noopener,noreferrer");
    toast("Pronto! Envie a mensagem no WhatsApp.");
    form.reset();
  }

  const campo = (id: string, rotulo: string, props: React.InputHTMLAttributes<HTMLInputElement> = {}) => (
    <div className="mb-3">
      <label htmlFor={`contato-${id}`} className="text-sm text-suave">{rotulo}</label>
      <input
        id={`contato-${id}`}
        name={id}
        className="campo"
        aria-invalid={!!erros[id]}
        aria-describedby={erros[id] ? `contato-${id}-erro` : undefined}
        {...props}
      />
      {erros[id] && <p id={`contato-${id}-erro`} role="alert" className="mt-1 text-sm text-suave">{erros[id]}</p>}
    </div>
  );

  return (
    <>
      <section className="mx-auto max-w-[1100px] px-6 pb-24 pt-36">
        <AoRolar>
          <div className="grid gap-12 md:grid-cols-[5fr_6fr] md:gap-16">
            <div>
              <h1 className="text-[40px] leading-tight md:text-[52px]">Fale com a gente.</h1>
              <p className="mt-6 text-[17px] leading-[1.6] text-suave">
                Tem dúvida sobre uma peça, tamanho ou pedido? Escreva aqui e a mensagem segue direto pro WhatsApp da RV Label — sem
                intermediário, sem pressa.
              </p>
              <a
                href={urlWhatsApp("Olá, RV Label! Gostaria de tirar uma dúvida.")}
                target="_blank"
                rel="noopener noreferrer"
                className="btn-contorno mt-7"
              >
                <MessageCircle className="h-5 w-5" aria-hidden /> Chamar no WhatsApp
              </a>
            </div>

            <form onSubmit={enviar} noValidate aria-label="Fale com a RV Label">
              {campo("nome", "Nome", { autoComplete: "name" })}
              {campo("email", "E-mail", { type: "email", autoComplete: "email" })}
              {campo("assunto", "Assunto")}
              <div className="mb-3">
                <label htmlFor="contato-mensagem" className="text-sm text-suave">Mensagem</label>
                <textarea
                  id="contato-mensagem"
                  name="mensagem"
                  rows={4}
                  className="campo resize-y"
                  aria-invalid={!!erros.mensagem}
                  aria-describedby={erros.mensagem ? "contato-mensagem-erro" : undefined}
                />
                {erros.mensagem && <p id="contato-mensagem-erro" role="alert" className="mt-1 text-sm text-suave">{erros.mensagem}</p>}
              </div>
              <button type="submit" className="btn-cheio mt-3 w-full sm:w-auto">Enviar pelo WhatsApp</button>
            </form>
          </div>
        </AoRolar>
      </section>
      <Novidades foto={foto} />
    </>
  );
}
