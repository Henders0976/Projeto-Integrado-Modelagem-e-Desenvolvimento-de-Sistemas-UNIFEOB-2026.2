/** Formata valores em reais (89.9 -> "R$ 89,90"). */
export const formatarReais = (valor: number): string => `R$ ${valor.toFixed(2).replace(".", ",")}`;

export const soDigitos = (texto: string): string => texto.replace(/\D/g, "");

/** E-mail com "algo@algo.algo": só barra erro de digitação, não valida de verdade. */
export const emailPlausivel = (v: string): boolean => /^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(v.trim());

/** WhatsApp da loja (DDI + DDD + número). Sem VITE_WHATSAPP, usa um número fictício. */
const configurado = soDigitos(String(import.meta.env.VITE_WHATSAPP ?? ""));
export const WHATSAPP_NUMERO: string = configurado || "5511999990000";
export const WHATSAPP_CONFIGURADO: boolean = configurado.length > 0;

export const urlWhatsApp = (mensagem: string, numero: string = WHATSAPP_NUMERO): string =>
  `https://wa.me/${numero}?text=${encodeURIComponent(mensagem)}`;

/** Texto enviado ao WhatsApp da marca a partir do formulário de contato. */
export const mensagemContato = (d: { nome: string; email: string; assunto: string; mensagem: string }): string =>
  `Olá, RV Label! Aqui é ${d.nome} (${d.email}).\nAssunto: ${d.assunto}\n\n${d.mensagem}`;

/** Texto enviado ao WhatsApp da marca quando a cliente pede as novidades. */
export const mensagemNovidades = (email: string): string =>
  `Olá, RV Label! Quero receber as novidades da coleção. Meu e-mail: ${email}`;
