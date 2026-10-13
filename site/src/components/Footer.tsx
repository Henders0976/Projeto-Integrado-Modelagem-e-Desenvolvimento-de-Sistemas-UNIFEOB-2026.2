import { Link } from "react-router-dom";
import { COLECOES } from "@/lib/colecoes";
import { CNPJ, EMAIL_CONTATO, urlWhatsApp } from "@/lib/formato";

const linkCls = "block py-1.5 text-suave transition hover:text-texto";
const tituloCls = "mb-2.5 text-xs font-semibold uppercase tracking-[0.25em]";

export default function Footer() {
  return (
    <footer className="mx-auto max-w-[1100px] px-6 pb-10 pt-28">
      <hr className="border-linha" />
      <div className="mt-10 grid gap-10 md:grid-cols-[4fr_2fr_2fr]">
        <div>
          <p className="font-titulo text-[28px] tracking-[0.25em]">RV·LABEL</p>
          <p className="mt-3 max-w-sm leading-relaxed text-suave">
            Peças únicas para o seu estilo. Produção em pequenos lotes, atendimento direto pelo WhatsApp, sem letra miúda.
          </p>
        </div>
        <nav aria-label="Loja">
          <p className={tituloCls}>Loja</p>
          <Link to="/loja" className={linkCls}>Coleção Essence</Link>
          {COLECOES.map((c) => (
            <Link key={c.slug} to={`/colecoes/${c.slug}`} className={linkCls}>
              {c.titulo}
            </Link>
          ))}
          <Link to="/sobre" className={linkCls}>Sobre</Link>
          <Link to="/contato" className={linkCls}>Contato</Link>
        </nav>
        <nav aria-label="Ajuda">
          <p className={tituloCls}>Ajuda</p>
          <Link to="/meus-pedidos" className={linkCls}>Meus pedidos</Link>
          <Link to="/privacidade" className={linkCls}>Privacidade e termos</Link>
          <a
            href={urlWhatsApp("Olá, RV Label! Gostaria de tirar uma dúvida.")}
            target="_blank"
            rel="noopener noreferrer"
            className={linkCls}
          >
            Falar no WhatsApp
          </a>
          <a href={`mailto:${EMAIL_CONTATO}`} className={linkCls}>
            Enviar e-mail
          </a>
        </nav>
      </div>
      <p className="mt-10 text-[13px] text-suave">© 2026 RV Label · CNPJ {CNPJ} · Feito com carinho, peça por peça</p>
    </footer>
  );
}
