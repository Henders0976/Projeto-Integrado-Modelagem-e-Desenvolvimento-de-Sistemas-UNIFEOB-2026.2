/** Formata valores em reais (89.9 -> "R$ 89,90"). */
export const formatarReais = (valor: number): string => `R$ ${valor.toFixed(2).replace(".", ",")}`;

export const soDigitos = (texto: string): string => texto.replace(/\D/g, "");

/** (11) 99999-9999 com 11 dígitos, (11) 9999-9999 com 10, como no app (lib/core/mascaras.dart).
 *  Com mais de 11 (ex.: +55 na frente) devolve só os dígitos: a validação continua aceitando de 10 a 13. */
export function formatarTelefone(texto: string): string {
  const d = soDigitos(texto);
  if (d.length > 11) return d;
  // O hífen vai antes dos 4 últimos: depois do 6º dígito com 10, do 7º com 11.
  const hifen = d.length === 11 ? 7 : 6;
  return [...d].map((c, i) => (i === 0 ? "(" : i === 2 ? ") " : i === hifen ? "-" : "") + c).join("");
}

/** 000.000.000-00 (no máximo 11 dígitos). */
export const formatarCpf = (texto: string): string =>
  [...soDigitos(texto).slice(0, 11)].map((c, i) => (i === 3 || i === 6 ? "." : i === 9 ? "-" : "") + c).join("");

/** E-mail com "algo@algo.algo": só barra erro de digitação, não valida de verdade. */
export const emailPlausivel = (v: string): boolean => /^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(v.trim());

/** WhatsApp da loja (DDI + DDD + número). Sem VITE_WHATSAPP, usa um número fictício. */
const configurado = soDigitos(String(import.meta.env.VITE_WHATSAPP ?? ""));
export const WHATSAPP_NUMERO: string = configurado || "5511999990000";
export const WHATSAPP_CONFIGURADO: boolean = configurado.length > 0;

/** Identificação da loja: aparece no rodapé e na política de privacidade. */
export const CNPJ = "68.647.856/0001-97";
export const EMAIL_CONTATO = "suporte.rvlabel@gmail.com";

export const urlWhatsApp = (mensagem: string, numero: string = WHATSAPP_NUMERO): string =>
  `https://wa.me/${numero}?text=${encodeURIComponent(mensagem)}`;

/** Texto enviado ao WhatsApp da marca a partir do formulário de contato. */
export const mensagemContato = (d: { nome: string; email: string; assunto: string; mensagem: string }): string =>
  `Olá, RV Label! Aqui é ${d.nome} (${d.email}).\nAssunto: ${d.assunto}\n\n${d.mensagem}`;

/** Texto enviado ao WhatsApp da marca quando a cliente pede as novidades. */
export const mensagemNovidades = (email: string): string =>
  `Olá, RV Label! Quero receber as novidades da coleção. Meu e-mail: ${email}`;
