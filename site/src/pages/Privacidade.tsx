import type { ReactNode } from "react";
import { useTitulo } from "@/hooks/useTitulo";
import { CNPJ, EMAIL_CONTATO } from "@/lib/formato";

const email = (
  <a href={`mailto:${EMAIL_CONTATO}`} className="underline decoration-texto/50 underline-offset-4 hover:decoration-texto">
    {EMAIL_CONTATO}
  </a>
);

/** Política de privacidade (LGPD) e termos de uso, em linguagem direta. Mesmo texto do app, com o item do navegador. */
const BLOCOS: [string, ReactNode][] = [
  [
    "Quem é o responsável",
    <>A RV Label (CNPJ {CNPJ}) decide como os seus dados são usados e responde por eles. Para qualquer assunto sobre seus dados, escreva para {email}.</>,
  ],
  [
    "Que dados coletamos",
    "Nome e telefone para atender seu pedido. O CPF é opcional e só pedimos se você quiser nota fiscal. Não pedimos senha nem dados de cartão.",
  ],
  [
    "Para que usamos",
    "Somente para registrar, separar e entregar o seu pedido e falar com você sobre ele pelo WhatsApp. Não vendemos nem compartilhamos seus dados.",
  ],
  [
    "Por quanto tempo guardamos",
    "Enquanto o pedido existir ou a lei exigir (por exemplo, obrigações fiscais). Depois disso, apagamos ou tornamos os dados anônimos.",
  ],
  [
    "Seus direitos (LGPD)",
    <>Você pode pedir acesso, correção ou exclusão dos seus dados, e retirar o consentimento quando quiser. Escreva para {email} ou chame a RV Label no WhatsApp.</>,
  ],
  [
    "Como consultar seu pedido",
    'Em "Meus pedidos" você vê o andamento informando o número do pedido e o telefone usado na compra.',
  ],
  [
    "O que fica no seu navegador",
    "A sacola fica guardada só no seu navegador (armazenamento local) e não é enviada a ninguém até você fechar o pedido. O site não usa cookies de rastreamento.",
  ],
  [
    "Termos de uso",
    "As peças são produzidas em pequenos lotes e as informações do site (preço, cor, tamanho) valem até o fechamento do pedido pelo WhatsApp. Trocas e devoluções seguem o Código de Defesa do Consumidor e são combinadas direto com a marca.",
  ],
];

export default function Privacidade() {
  useTitulo("Privacidade e termos");
  return (
    <div className="mx-auto max-w-[640px] px-6 pb-8 pt-36">
      <h1 className="mb-10 text-[40px]">Privacidade e termos</h1>
      {BLOCOS.map(([titulo, texto]) => (
        <section key={titulo} className="mb-7">
          <h2 className="text-2xl">{titulo}</h2>
          <p className="mt-1.5 text-base leading-relaxed">{texto}</p>
        </section>
      ))}
    </div>
  );
}
