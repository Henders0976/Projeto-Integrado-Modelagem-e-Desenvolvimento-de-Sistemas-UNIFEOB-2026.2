import type { Categoria, Peca } from "./catalogo";

/** Uma coleção da vitrine: agrupa categorias do catálogo e traz o texto da página (igual ao app). */
export interface Colecao {
  slug: string;
  chamada: string;
  titulo: string;
  frase: string;
  textos: string[];
  fecho: string;
  fechoTexto: string;
  categorias: Categoria[];
}

export const COLECOES: Colecao[] = [
  {
    slug: "parte-de-cima",
    chamada: "Explore",
    titulo: "Parte de cima",
    frase: "Um ombro só, um laço, um recorte.",
    textos: [
      "Blusas, tops e bodys da coleção Essence: cortes assimétricos e decotes que respiram, pensados pra valorizar sem esforço.",
      "Cada peça é produzida em pequeno lote. Escolha a cor e o tamanho, adicione à sacola e feche tudo direto com a marca.",
    ],
    fecho: "Monte o seu look",
    fechoTexto: "Combine com shorts e vestidos da coleção — as cores conversam entre si.",
    categorias: ["blusas", "tops", "bodys"],
  },
  {
    slug: "vestidos-e-mais",
    chamada: "Complete o look",
    titulo: "Vestidos e mais",
    frase: "Pra quando a peça é o look inteiro.",
    textos: [
      "Vestidos, shorts e acessórios da Essence. Costas nuas, fendas e alfaiataria: identidade em cada detalhe.",
      "Mistura à vontade entre as coleções. Tudo é feito em lote pequeno, então vale garantir a sua enquanto há tamanho.",
    ],
    fecho: "Dúvida de tamanho?",
    fechoTexto: "Chame a RV Label no WhatsApp e a gente ajuda a escolher.",
    categorias: ["vestidos", "shorts", "acessorios"],
  },
];

export const pecasDaColecao = (c: Colecao, pecas: Peca[]): Peca[] =>
  pecas.filter((p) => c.categorias.includes(p.categoria));

/** Primeira foto disponível entre as peças, ou undefined se nenhuma tiver foto. */
export const primeiraFoto = (pecas: Peca[]): string | undefined => pecas.find((p) => p.fotos.length)?.fotos[0];
