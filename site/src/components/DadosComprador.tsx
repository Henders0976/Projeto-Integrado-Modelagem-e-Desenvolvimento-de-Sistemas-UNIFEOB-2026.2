import { useEffect, useRef, useState, type FormEvent } from "react";
import { Link } from "react-router-dom";
import type { Comprador } from "@/lib/api";
import { formatarCpf, formatarTelefone, soDigitos } from "@/lib/formato";

interface Props {
  aberto: boolean;
  enviando: boolean;
  aoFechar: () => void;
  aoConfirmar: (c: Comprador) => void;
}

/** Pede os dados do comprador antes de gravar o pedido. Sem o consentimento (LGPD) não segue. */
export default function DadosComprador({ aberto, enviando, aoFechar, aoConfirmar }: Props) {
  const ref = useRef<HTMLDialogElement>(null);
  const [erros, setErros] = useState<Record<string, string>>({});

  useEffect(() => {
    const d = ref.current;
    if (!d) return;
    if (aberto && !d.open) d.showModal();
    if (!aberto && d.open) d.close();
  }, [aberto]);

  function enviar(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const f = new FormData(e.currentTarget);
    const nome = String(f.get("nome") ?? "").trim();
    const telefone = soDigitos(String(f.get("telefone") ?? ""));
    const cpf = soDigitos(String(f.get("cpf") ?? ""));
    const novos: Record<string, string> = {};
    if (!nome) novos.nome = "Informe o nome";
    if (telefone.length < 10 || telefone.length > 13) novos.telefone = "Telefone inválido";
    if (cpf && cpf.length !== 11) novos.cpf = "CPF deve ter 11 dígitos";
    if (f.get("aceito") !== "on") novos.aceito = "Aceite para continuar";
    setErros(novos);
    if (Object.keys(novos).length === 0) aoConfirmar({ nome, telefone, cpf: cpf || null });
  }

  // shortcut: a máscara põe o cursor no fim (como no app); editar no meio do número pula o cursor. Calcular a posição se incomodar.
  const mascara = (formatar: (t: string) => string) => (e: FormEvent<HTMLInputElement>) => {
    e.currentTarget.value = formatar(e.currentTarget.value);
  };

  const campo = (id: string, rotulo: string, extra: Record<string, string> = {}, aoDigitar?: (e: FormEvent<HTMLInputElement>) => void) => (
    <div className="mb-4">
      <label htmlFor={`comprador-${id}`} className="rotulo">{rotulo}</label>
      <input
        id={`comprador-${id}`}
        name={id}
        className="campo"
        aria-invalid={!!erros[id]}
        aria-describedby={erros[id] ? `comprador-${id}-erro` : undefined}
        onInput={aoDigitar}
        {...extra}
      />
      {erros[id] && <p id={`comprador-${id}-erro`} role="alert" className="erro">{erros[id]}</p>}
    </div>
  );

  return (
    <dialog
      ref={ref}
      onClose={aoFechar}
      className="w-[min(92vw,440px)] rounded-lg border border-linha bg-elevado p-6 text-texto backdrop:bg-black/70"
      aria-labelledby="comprador-titulo"
    >
      <form onSubmit={enviar} noValidate>
        <h2 id="comprador-titulo" className="mb-5 text-[26px]">Seus dados</h2>
        {campo("nome", "Nome", { autoComplete: "name" })}
        {campo("telefone", "Telefone (com DDD)", { inputMode: "tel", autoComplete: "tel", placeholder: "(11) 99999-9999" }, mascara(formatarTelefone))}
        {campo("cpf", "CPF (opcional)", { inputMode: "numeric", placeholder: "000.000.000-00" }, mascara(formatarCpf))}
        <label className="flex items-start gap-3 text-sm">
          <input type="checkbox" name="aceito" className="mt-1 h-4 w-4 accent-vermelho" />
          <span>
            Concordo em usar meus dados só para este pedido.{" "}
            <Link to="/privacidade" target="_blank" className="underline">Ler privacidade e termos</Link>
          </span>
        </label>
        {erros.aceito && <p role="alert" className="erro">{erros.aceito}</p>}
        <div className="mt-6 flex justify-end gap-3">
          <button type="button" onClick={aoFechar} className="btn-contorno min-h-[44px] px-5">Cancelar</button>
          <button type="submit" disabled={enviando} className="btn-cheio min-h-[44px] px-5">
            {enviando ? "Enviando…" : "Continuar"}
          </button>
        </div>
      </form>
    </dialog>
  );
}
