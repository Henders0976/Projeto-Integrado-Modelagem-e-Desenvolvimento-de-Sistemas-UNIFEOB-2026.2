import { CheckCircle2, ShoppingBag, X } from "lucide-react";
import { useState } from "react";
import { Link } from "react-router-dom";
import { toast } from "sonner";
import DadosComprador from "@/components/DadosComprador";
import FotoPeca from "@/components/FotoPeca";
import SeletorQuantidade from "@/components/SeletorQuantidade";
import { useCatalogo } from "@/context/Catalogo";
import { useSacola } from "@/context/Sacola";
import { useTitulo } from "@/hooks/useTitulo";
import { API_URL, ApiErro, enviarPedido, type Comprador } from "@/lib/api";
import { formatarReais, urlWhatsApp, WHATSAPP_CONFIGURADO } from "@/lib/formato";
import { mensagemPedido, subtotal } from "@/lib/pedido";

interface Resultado {
  numero?: number;
  aviso?: string;
  url: string;
}

export default function Sacola() {
  useTitulo("Sacola");
  const { pecas } = useCatalogo();
  const { itens, quantidade, total, pendente, alterarQuantidade, remover, limpar } = useSacola();
  const [aberto, setAberto] = useState(false);
  const [enviando, setEnviando] = useState(false);
  const [resultado, setResultado] = useState<Resultado | null>(null);

  /** Grava o pedido na API (se houver) e prepara o WhatsApp. Erro de regra (ex.: sem estoque) para aqui;
   *  falta de conexão só avisa e segue pelo WhatsApp, como o app faz. */
  async function confirmar(comprador: Comprador) {
    setEnviando(true);
    let numero: number | undefined;
    let aviso: string | undefined;
    if (API_URL) {
      try {
        numero = await enviarPedido(itens, comprador);
      } catch (e) {
        if (e instanceof ApiErro) {
          toast.error(e.message);
          setEnviando(false);
          return;
        }
        aviso = "Pedido não foi salvo (sem conexão). Enviando só pelo WhatsApp.";
      }
    }
    const url = urlWhatsApp(mensagemPedido(itens, numero));
    setResultado({ numero, aviso, url });
    setAberto(false);
    setEnviando(false);
    if (numero != null) limpar(); // já está gravado: evita pedir duas vezes
    window.open(url, "_blank", "noopener,noreferrer"); // se o navegador bloquear, o botão abaixo abre
  }

  return (
    <div className="mx-auto max-w-[1100px] px-6 pb-8 pt-32">
      <h1 className="text-[40px]">Sacola</h1>

      {resultado && (
        <div role="status" className="cartao mt-6 max-w-[560px] p-6">
          {resultado.numero != null && <CheckCircle2 className="mb-3 h-9 w-9 text-sucesso" aria-hidden />}
          <p className="font-titulo text-2xl">
            {resultado.numero != null ? `Pedido nº ${resultado.numero} registrado` : "Quase lá."}
          </p>
          {resultado.numero != null && (
            <p className="mt-2 text-suave">Guarde esse número para acompanhar em “Meus pedidos”.</p>
          )}
          {resultado.aviso && <p className="mt-2 text-suave">{resultado.aviso}</p>}
          <p className="mt-2 text-suave">Agora é só enviar a mensagem no WhatsApp para combinar tudo com a marca.</p>
          <a href={resultado.url} target="_blank" rel="noopener noreferrer" className="btn-cheio mt-5">
            Abrir o WhatsApp
          </a>
          {import.meta.env.DEV && !WHATSAPP_CONFIGURADO && (
            <p className="mt-3 text-sm text-suave">(Aviso de desenvolvimento: VITE_WHATSAPP não está definido, o número é fictício.)</p>
          )}
        </div>
      )}

      {itens.length === 0 ? (
        !resultado && (
          <div className="mt-12 flex flex-col items-center text-center">
            <ShoppingBag className="h-12 w-12 text-mudo" aria-hidden />
            <p className="mt-4 font-titulo text-[28px]">Sua sacola tá vazia.</p>
            <p className="mt-2 text-suave">Bora escolher uma peça?</p>
            <Link to="/loja" className="btn-cheio mt-6">Explorar coleção</Link>
          </div>
        )
      ) : (
        // Desktop: resumo num cartão fixo à direita. Celular: preso no rodapé da tela, como no app.
        <div className="mt-8 lg:grid lg:grid-cols-[minmax(0,1fr)_360px] lg:items-start lg:gap-10">
          <ul className="divide-y divide-linha border-y border-linha">
            {itens.map((i) => {
              const cor = pecas.find((p) => p.id === i.id)?.cores.find((c) => c.nome === i.cor);
              const s = subtotal(i);
              return (
                <li key={i.chave} className="flex gap-4 py-5">
                  <Link to={`/peca/${i.id}`} className="block w-20 shrink-0 sm:w-24" aria-label={`Abrir ${i.nome}`}>
                    <FotoPeca src={i.foto} cor={cor} alt="" className="aspect-[4/5] w-full rounded" />
                  </Link>
                  <div className="min-w-0 flex-1">
                    <div className="flex items-start justify-between gap-3">
                      <div>
                        <p className="font-titulo text-xl leading-tight">{i.nome}</p>
                        <p className="mt-1 text-sm text-suave">{i.cor} · {i.tamanho}</p>
                      </div>
                      <button
                        type="button"
                        onClick={() => remover(i.chave)}
                        aria-label={`Remover ${i.nome}`}
                        className="flex h-11 w-11 shrink-0 items-center justify-center rounded transition hover:bg-white/10"
                      >
                        <X className="h-5 w-5" />
                      </button>
                    </div>
                    <div className="mt-3 flex flex-wrap items-center justify-between gap-3">
                      <SeletorQuantidade quantidade={i.quantidade} aoMudar={(q) => alterarQuantidade(i.chave, q)} />
                      <p className="preco whitespace-nowrap">{s == null ? "preço a combinar" : formatarReais(s)}</p>
                    </div>
                  </div>
                </li>
              );
            })}
          </ul>

          <aside
            aria-label="Resumo"
            className="sticky bottom-0 -mx-6 mt-8 border-t border-linha bg-painel px-6 py-4 lg:top-28 lg:mx-0 lg:mt-0 lg:rounded-lg lg:border lg:p-6"
          >
            <h2 className="mb-4 hidden text-2xl lg:block">Resumo</h2>
            <p className="hidden justify-between text-suave lg:flex">
              Itens <span className="tabular-nums text-texto">{quantidade}</span>
            </p>
            <p className="flex items-baseline justify-between gap-3 lg:mt-2">
              Total
              <span className="preco text-right text-xl">
                {formatarReais(total)}
                {pendente && <span className="text-sm font-normal text-suave"> + itens a combinar</span>}
              </span>
            </p>
            <p className="mt-1 text-sm text-suave">Entrega e pagamento você combina no WhatsApp.</p>
            <button type="button" onClick={() => setAberto(true)} className="btn-cheio mt-4 w-full">
              Fechar pedido pelo WhatsApp
            </button>
          </aside>
        </div>
      )}

      <DadosComprador aberto={aberto} enviando={enviando} aoFechar={() => setAberto(false)} aoConfirmar={confirmar} />
    </div>
  );
}
