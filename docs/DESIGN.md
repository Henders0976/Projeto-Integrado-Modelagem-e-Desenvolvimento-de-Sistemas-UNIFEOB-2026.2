# RV Label — Design System & Melhorias (Flutter)

> Documento para orientar a evolução visual do app RV Label (coleção Essence).
> **Regra principal:** mudar apenas aparência e experiência. Não alterar regras de negócio, chamadas à API, cálculo de totais, estoque ou fluxo do WhatsApp.

---

## 1. Identidade atual (manter)

- **Cor da marca:** vermelho `#B3121E` sobre fundo quase preto.
- **Títulos:** DM Serif Display (serifada, elegante).
- **Fundo "líquido"** animado (shader) — é a assinatura visual; manter, mas com opção de reduzir.
- **Sublinhado animado** no menu do topo.
- Tom: moda feminina, sofisticado, noturno, editorial.

Direção: **editorial de luxo escuro** — muito respiro, fotos grandes, vermelho usado com moderação (só ações e destaques), nunca como cor de fundo de áreas grandes.

---

## 2. Tokens de design

### 2.1 Cores

| Token | Hex | Uso |
|---|---|---|
| `bg` | `#0B0B0C` | Fundo do app |
| `surface` | `#141416` | Cards, painéis |
| `surfaceRaised` | `#1C1C1F` | Modais, menus, hover |
| `border` | `#2A2A2E` | Linhas divisórias, contornos |
| `textPrimary` | `#F4F1EE` | Texto principal (off-white quente) |
| `textSecondary` | `#A8A3A0` | Legendas, descrições |
| `textMuted` | `#6E6A68` | Placeholders, desabilitado |
| `brand` | `#B3121E` | Botão principal, preço em destaque, seleção |
| `brandHover` | `#C8202D` | Hover/pressionado |
| `brandSoft` | `#B3121E` @ 14% | Fundo de chip selecionado, badges |
| `onBrand` | `#FFFFFF` | Texto sobre vermelho |
| `success` | `#2E9E6A` | Pedido enviado, estoque ok |
| `warning` | `#D9A441` | Poucas unidades, em separação |
| `danger` | `#E5484D` | Erros, cancelado (diferente do vermelho da marca) |
| `info` | `#5B8DEF` | Recebido |

> O vermelho da marca **não** deve ser usado para erro — use `danger`, senão a cliente confunde destaque com problema.

### 2.2 Tipografia

| Estilo | Fonte | Tamanho / Altura | Peso |
|---|---|---|---|
| display | DM Serif Display | 48 / 1.05 | 400 |
| h1 | DM Serif Display | 36 / 1.1 | 400 |
| h2 | DM Serif Display | 28 / 1.15 | 400 |
| h3 | DM Serif Display | 22 / 1.2 | 400 |
| bodyLg | Manrope (ou DM Sans) | 17 / 1.55 | 400 |
| body | Manrope | 15 / 1.5 | 400 |
| label | Manrope | 13 / 1.3 | 600, letterSpacing 0.8, MAIÚSCULAS |
| caption | Manrope | 12 / 1.4 | 500 |
| price | Manrope | 18 / 1.2 | 700, tabular figures |

Serif só em títulos e nomes de peça. Corpo sempre sans para legibilidade.

### 2.3 Espaçamento, cantos, sombras, movimento

- Espaçamento base 4: `4, 8, 12, 16, 24, 32, 48, 64, 96`.
- Margem lateral: 16 (celular), 32 (tablet), 64 (desktop). Largura máxima de conteúdo: 1280.
- Cantos: `sm 6`, `md 10`, `lg 16`, `pill 999`. Fotos de produto: `md`.
- Sombras: quase nenhuma (fundo escuro). Use borda `border` + leve brilho `brand` @ 20% blur 24 só no foco/hover de cards.
- Movimento: `fast 150ms`, `base 250ms`, `slow 450ms`, curva `Curves.easeOutCubic`. Respeitar `MediaQuery.disableAnimations`.

### 2.4 Código Flutter sugerido (`lib/theme/`)

```dart
// lib/theme/rv_colors.dart
import 'package:flutter/material.dart';

class RvColors {
  static const bg = Color(0xFF0B0B0C);
  static const surface = Color(0xFF141416);
  static const surfaceRaised = Color(0xFF1C1C1F);
  static const border = Color(0xFF2A2A2E);
  static const textPrimary = Color(0xFFF4F1EE);
  static const textSecondary = Color(0xFFA8A3A0);
  static const textMuted = Color(0xFF6E6A68);
  static const brand = Color(0xFFB3121E);
  static const brandHover = Color(0xFFC8202D);
  static const success = Color(0xFF2E9E6A);
  static const warning = Color(0xFFD9A441);
  static const danger = Color(0xFFE5484D);
  static const info = Color(0xFF5B8DEF);
}

class RvSpace {
  static const xs = 4.0, sm = 8.0, md = 12.0, lg = 16.0,
      xl = 24.0, x2 = 32.0, x3 = 48.0, x4 = 64.0;
}

class RvRadius {
  static const sm = 6.0, md = 10.0, lg = 16.0;
}

class RvMotion {
  static const fast = Duration(milliseconds: 150);
  static const base = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 450);
  static const curve = Curves.easeOutCubic;
}
```

```dart
// lib/theme/rv_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'rv_colors.dart';

ThemeData buildRvTheme() {
  final scheme = const ColorScheme.dark(
    primary: RvColors.brand,
    onPrimary: Colors.white,
    surface: RvColors.surface,
    onSurface: RvColors.textPrimary,
    error: RvColors.danger,
    outline: RvColors.border,
  );
  final serif = GoogleFonts.dmSerifDisplay(color: RvColors.textPrimary);
  final sans = GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme)
      .apply(bodyColor: RvColors.textPrimary, displayColor: RvColors.textPrimary);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: RvColors.bg,
    textTheme: sans.copyWith(
      displayLarge: serif.copyWith(fontSize: 48, height: 1.05),
      headlineLarge: serif.copyWith(fontSize: 36, height: 1.1),
      headlineMedium: serif.copyWith(fontSize: 28, height: 1.15),
      headlineSmall: serif.copyWith(fontSize: 22, height: 1.2),
      bodyLarge: sans.bodyLarge?.copyWith(fontSize: 17, height: 1.55),
      bodyMedium: sans.bodyMedium?.copyWith(fontSize: 15, height: 1.5),
      labelLarge: sans.labelLarge?.copyWith(
          fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.8),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: RvColors.brand,
        foregroundColor: Colors.white,
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RvRadius.sm)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: RvColors.textPrimary,
        side: const BorderSide(color: RvColors.border),
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(RvRadius.sm)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: RvColors.surface,
      hintStyle: const TextStyle(color: RvColors.textMuted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RvRadius.sm),
        borderSide: const BorderSide(color: RvColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RvRadius.sm),
        borderSide: const BorderSide(color: RvColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RvRadius.sm),
        borderSide: const BorderSide(color: RvColors.brand, width: 1.5),
      ),
    ),
    cardTheme: CardThemeData(
      color: RvColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RvRadius.md),
        side: const BorderSide(color: RvColors.border),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: RvColors.surface,
      selectedColor: RvColors.brand.withOpacity(0.14),
      side: const BorderSide(color: RvColors.border),
      shape: const StadiumBorder(),
    ),
    dividerColor: RvColors.border,
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: RvColors.surfaceRaised,
      contentTextStyle: TextStyle(color: RvColors.textPrimary),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
```

---

## 3. Melhorias por tela (prioridade: P1 alta → P3 baixa)

### Início
- **P1** Hero de tela cheia: foto grande da coleção Essence sobre o fundo líquido, título display, um único botão "Ver coleção".
- **P2** Categorias como cards com foto (proporção 4:5) em vez de lista de texto.
- **P2** "Antes de escolher" como 3 passos com ícone (medidas, cores, entrega).
- **P3** "Novidades" em carrossel horizontal com snap.

### Coleção (Vitrine / Grade)
- **P1** Barra de filtros fixa no topo: categoria, cor, tamanho, faixa de preço, ordenar. Mostrar quantidade ("24 peças").
- **P1** Estados: skeleton enquanto carrega, mensagem amigável quando vazio ("Nenhuma peça com esses filtros" + botão "Limpar filtros"), erro com "Tentar de novo".
- **P2** Card de produto padrão (ver seção 4), troca para foto das costas no hover/long-press.
- **P2** Grade responsiva: 2 colunas (celular), 3 (tablet), 4 (desktop).

### Produto
- **P1** Galeria com miniaturas + zoom (pinça/clique).
- **P1** Seletor de cor com bolinhas da cor real (não só texto); seletor de tamanho em chips; tamanho sem estoque riscado e desabilitado.
- **P1** Aviso de estoque: "Últimas 2 unidades" em `warning`.
- **P2** Botão "Adicionar à sacola" fixo no rodapé no celular.
- **P2** Guia de medidas em bottom sheet.
- **P3** "Você também pode gostar" com o mesmo card da coleção.

### Sacola e checkout
- **P1** Resumo fixo (subtotal, total) à direita no desktop / no rodapé no celular.
- **P1** Validação na hora: máscara de telefone `(11) 99999-9999` e CPF `000.000.000-00`, mensagem de erro abaixo do campo.
- **P1** Tela de confirmação antes de abrir o WhatsApp, mostrando o número do pedido.
- **P2** Sacola vazia com ilustração e botão "Explorar coleção".
- **P2** Alterar quantidade com stepper (− 1 +) e "Remover" com desfazer (snackbar).

### Meus pedidos
- **P1** Linha do tempo do status: Recebido → Em separação → Enviado (Cancelado em `danger`), com data de cada etapa.
- **P2** Card do pedido com miniaturas das peças e total.

### Assistente de estilo (IA)
- **P1** Balões de conversa diferenciados (cliente à direita em `surfaceRaised`, assistente à esquerda com borda).
- **P1** Indicador "digitando…" e sugestões rápidas: "Look para casamento", "Algo casual", "Combina com vermelho?".
- **P2** Cards de produto dentro do chat iguais aos da coleção, com "Adicionar à sacola".
- **P3** Montar look completo (peça + acessório) com total.

### Admin
- **P1** Tabela de produtos densa com busca, filtros (ativo/inativo, categoria) e ações em massa visíveis quando há seleção.
- **P1** Status de pedido como badge colorido (info / warning / success / danger).
- **P2** Estoque em grade cor × tamanho, editável, com célula em `warning` quando ≤ 2.
- **P2** Painel: cards de indicadores (vendas do mês, pedidos, ticket médio) + gráfico simples de barras por semana.
- **P3** Menu lateral recolhível no desktop.

### Contato / Sobre / Privacidade
- **P2** Layout de leitura: coluna de 680px, títulos serif, bom espaçamento entre parágrafos.
- **P2** Contato com botões grandes (WhatsApp, e-mail, Instagram).

---

## 4. Componentes padrão

- **RvButton**: `primary` (vermelho), `secondary` (contorno), `ghost` (só texto). Altura mínima 48. Estado carregando com spinner no lugar do texto.
- **RvProductCard**: foto 4:5, nome em serif 18, preço em `price`, badge "Novo" / "Últimas unidades" no canto. Hover: leve zoom na foto (1.03) + borda `brand` @ 40%.
- **RvChip**: tamanho, cor, filtro. Selecionado = fundo `brandSoft` + borda `brand`.
- **RvColorSwatch**: círculo 28px com anel de 2px quando selecionado.
- **RvTextField**: label acima, ajuda/erro abaixo, máscara quando aplicável.
- **RvStatusBadge**: pill com ponto colorido + texto.
- **RvEmptyState**: ícone, título, texto curto, um botão.
- **RvSkeleton**: blocos `surfaceRaised` com shimmer suave.
- **Avisos**: snackbar flutuante para confirmações; dialog só para ações destrutivas.

Regra: telas usam esses componentes; nada de `Color(0x...)` ou `TextStyle` solto nas telas.

---

## 5. Acessibilidade e celular

- Contraste mínimo 4.5:1 para texto (os tokens acima já atendem sobre `bg`).
- Alvos de toque ≥ 44×44.
- `Semantics` em ícones sem texto (sacola, favoritos, fechar).
- Fundo líquido: reduzir intensidade e FPS no celular; desligar quando "reduzir movimento" estiver ativo ou bateria baixa.
- Breakpoints: `< 600` celular, `600–1024` tablet, `> 1024` desktop (usar `LayoutBuilder`).
- Fotos com `cacheWidth` adequado ao tamanho exibido para não pesar.

---

## 6. Instruções para o Claude

```
Você vai melhorar o design do app Flutter RV Label seguindo o DESIGN.md.

1. Crie lib/theme/rv_colors.dart e lib/theme/rv_theme.dart com o código da seção 2.4
   e aplique buildRvTheme() no MaterialApp.
2. Substitua todas as cores e estilos fixos nas telas por tokens (RvColors, RvSpace,
   RvRadius, Theme.of(context).textTheme).
3. Crie os componentes da seção 4 em lib/widgets/ e use-os nas telas.
4. Implemente as melhorias P1 da seção 3, tela por tela. Depois P2.
5. NÃO altere: regras de negócio, chamadas à API, cálculo de total, verificação de
   estoque, montagem da mensagem do WhatsApp, autenticação do admin.
6. Mantenha o fundo líquido e o sublinhado animado do menu; adicione a opção de
   reduzir movimento (seção 5).
7. Ao final de cada tela, liste o que mudou e qualquer ponto que precise de decisão.
```
