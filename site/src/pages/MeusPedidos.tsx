import { CheckCircle2, Circle } from "lucide-react";
import { useState, type FormEvent } from "react";
import { useTitulo } from "@/hooks/useTitulo";
import { API_URL, ApiErro, consultarPedido, type PedidoConsultado } from "@/lib/api";
import { formatarReais, soDigitos } from "@/lib/formato";

const ETAPAS = ["Recebido", "Em separação", "Enviado"];

/** O cliente acompanha o andamento com o número do pedido e o telefone usado na compra. */
export default function MeusPedidos() {
  useTitulo("Meus pedidos");
  const [carregando, setCarregando] = useState(false);
  const [erro, setErro] = useState<string | null>(null);
  const [pedido, setPedido] = useState<PedidoConsultado | null>(null);

  async function buscar(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const f = new FormData(e.currentTarget);
    const id = Number(soDigitos(String(f.get("numero") ?? "")));
    const telefone = soDigitos(String(f.get("telefone") ?? ""));
    setPedido(null);
    if (!id || telefone.length < 10) return setErro("Informe o número do pedido e o telefone com DDD.");
    setErro(null);
    setCarregando(true);
    try {
      setPedido(await consultarPedido(id, telefone));
    } catch (err) {
      setErro(err instanceof ApiErro ? err.message : "Sem conexão com o servidor. Tente de novo.");
    } finally {
      setCarregando(false);
    }
  }

  const atual = pedido ? ETAPAS.indexOf(pedido.status) : -1;

  return (
    <div className="mx-auto max-w-[520px] px-6 pb-8 pt-36">
      <h1 className="text-[40px]">Meus pedidos</h1>
      {!API_URL ? (
        <p className="mt-6 leading-relaxed text-suave">
          A consulta de pedidos fica disponível quando o servidor da loja estiver conectado ao site. Enquanto isso, fale com a
          RV Label pelo WhatsApp.
        </p>
      ) : (
        <>
          <p className="mt-4 text-suave">Use o número do pedido (enviado no WhatsApp) e o telefone que você informou na compra.</p>
          <form onSubmit={buscar} noValidate className="mt-6">
            <label htmlFor="mp-numero" className="text-sm text-suave">Número do pedido</label>
            <input id="mp-numero" name="numero" inputMode="numeric" className="campo mb-3" />
            <label htmlFor="mp-telefone" className="text-sm text-suave">Telefone (com DDD)</label>
            <input id="mp-telefone" name="telefone" inputMode="tel" autoComplete="tel" className="campo" />
            <button type="submit" disabled={carregando} className="btn-cheio mt-6 w-full">
              {carregando ? "Consultando…" : "Consultar"}
            </button>
          </form>
          {erro && <p role="alert" className="mt-5 text-suave">{erro}</p>}

          {pedido && (
            <section className="mt-8" aria-live="polite">
              <h2 className="text-[28px]">Pedido nº {pedido.id}</h2>
              {pedido.status === "Cancelado" ? (
                <p className="mt-3">Este pedido foi cancelado.</p>
              ) : (
                <ol className="mt-4 space-y-2">
                  {ETAPAS.map((etapa, i) => (
                    <li key={etapa} className={`flex items-center gap-3 ${i === atual ? "font-bold" : ""}`}>
                      {i <= atual ? <CheckCircle2 className="h-5 w-5" aria-hidden /> : <Circle className="h-5 w-5 text-suave" aria-hidden />}
                      {etapa}
                    </li>
                  ))}
                </ol>
              )}
              <hr className="my-6 border-linha" />
              <ul className="space-y-1">
                {pedido.itens.map((i, k) => (
                  <li key={k}>
                    {i.quantidade}× {i.nome} · {i.cor} · {i.tamanho}
                    {i.subtotal == null ? " · a combinar" : ` · ${formatarReais(i.subtotal)}`}
                  </li>
                ))}
              </ul>
              <p className="mt-4 font-bold tabular-nums">
                Total: {formatarReais(pedido.total)}
                {pedido.precoPendente ? " + itens a combinar" : ""}
              </p>
            </section>
          )}
        </>
      )}
    </div>
  );
}
