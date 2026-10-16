import 'package:flutter/material.dart';

/// Tokens do design (DESIGN.md, seção 2): editorial de luxo escuro. O vermelho da
/// marca fica para ações e destaques; nunca como fundo de área grande nem como erro.
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
  static const brandSoft = Color(0x24B3121E); // brand @ 14%
  static const onBrand = Color(0xFFFFFFFF);
  static const success = Color(0xFF2E9E6A);
  static const warning = Color(0xFFD9A441);
  static const danger = Color(0xFFE5484D);
  static const info = Color(0xFF5B8DEF);

  /// Topo do fundo líquido: vinho bem escuro, para o vermelho não virar fundo de tela.
  static const brandDeep = Color(0xFF2A0A0E);
}

class RvSpace {
  static const xs = 4.0, sm = 8.0, md = 12.0, lg = 16.0,
      xl = 24.0, x2 = 32.0, x3 = 48.0, x4 = 64.0, x5 = 96.0;
}

class RvRadius {
  static const sm = 6.0, md = 10.0, lg = 16.0, pill = 999.0;
}

class RvMotion {
  static const fast = Duration(milliseconds: 150);
  static const base = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 450);
  static const curve = Curves.easeOutCubic;

  /// Duração respeitando "reduzir movimento" do sistema.
  static Duration de(BuildContext context, Duration d) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : d;
}

/// Estilos de texto que não cabem no textTheme do Material.
class RvText {
  static const price = TextStyle(
    fontFamily: fonteCorpo,
    fontSize: 18,
    height: 1.2,
    fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  static const label = TextStyle(
    fontFamily: fonteCorpo,
    fontSize: 13,
    height: 1.3,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
  );
  static const caption = TextStyle(
    fontFamily: fonteCorpo,
    fontSize: 12,
    height: 1.4,
    fontWeight: FontWeight.w500,
    color: RvColors.textSecondary,
  );
}

// Nomes usados nas telas desde antes dos tokens; apontam para eles.
const corVermelho = RvColors.brand;
const corPreto = RvColors.bg;
const corTexto = RvColors.textPrimary;
const corTextoSuave = RvColors.textSecondary;
const corLinha = RvColors.border;
const corPainel = RvColors.surfaceRaised;

/// Fonte dos títulos (DM Serif Display). Só existe no peso normal: não use w700+.
const fonteTitulo = 'DMSerifDisplay';

/// Fonte do corpo (Manrope, pesos 400 a 700).
const fonteCorpo = 'Manrope';

/// Raio de fotos de produto e cartões.
const raioPadrao = RvRadius.md;

ThemeData temaRvLabel() {
  const esquema = ColorScheme.dark(
    primary: RvColors.brand,
    onPrimary: RvColors.onBrand,
    secondary: RvColors.textPrimary,
    onSecondary: RvColors.bg,
    surface: RvColors.surface,
    onSurface: RvColors.textPrimary,
    onSurfaceVariant: RvColors.textSecondary,
    surfaceContainerHighest: RvColors.surfaceRaised,
    surfaceContainerHigh: RvColors.surfaceRaised,
    surfaceContainer: RvColors.surface,
    error: RvColors.danger,
    onError: RvColors.onBrand,
    outline: RvColors.border,
    outlineVariant: RvColors.border,
  );

  const cantoSm = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(RvRadius.sm)));
  final base = ThemeData(brightness: Brightness.dark, useMaterial3: true, fontFamily: fonteCorpo);
  final t = base.textTheme.apply(bodyColor: RvColors.textPrimary, displayColor: RvColors.textPrimary);

  TextStyle? serif(TextStyle? s, double tamanho, double altura, {double espaco = 0}) =>
      s?.copyWith(
        fontFamily: fonteTitulo,
        fontWeight: FontWeight.w400,
        fontSize: tamanho,
        height: altura,
        letterSpacing: espaco,
      );

  // Vermelho no repouso, um tom mais claro no hover/pressionado.
  final fundoBotao = WidgetStateProperty.resolveWith<Color>((s) {
    if (s.contains(WidgetState.disabled)) return RvColors.surfaceRaised;
    if (s.contains(WidgetState.hovered) || s.contains(WidgetState.pressed)) {
      return RvColors.brandHover;
    }
    return RvColors.brand;
  });
  final textoBotao = WidgetStateProperty.resolveWith<Color>((s) =>
      s.contains(WidgetState.disabled) ? RvColors.textMuted : RvColors.onBrand);
  const estiloBotao = TextStyle(
      fontFamily: fonteCorpo, fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.3);
  final bordaCampo = OutlineInputBorder(
    borderRadius: BorderRadius.circular(RvRadius.sm),
    borderSide: const BorderSide(color: RvColors.border),
  );

  return ThemeData(
    useMaterial3: true,
    fontFamily: fonteCorpo,
    colorScheme: esquema,
    scaffoldBackgroundColor: RvColors.bg,
    textTheme: t.copyWith(
      displayLarge: serif(t.displayLarge, 48, 1.05, espaco: -0.8),
      displayMedium: serif(t.displayMedium, 48, 1.05, espaco: -0.8),
      displaySmall: serif(t.displaySmall, 40, 1.08, espaco: -0.6),
      headlineLarge: serif(t.headlineLarge, 36, 1.1, espaco: -0.4),
      headlineMedium: serif(t.headlineMedium, 28, 1.15, espaco: -0.2),
      headlineSmall: serif(t.headlineSmall, 22, 1.2),
      titleLarge: serif(t.titleLarge, 22, 1.2),
      bodyLarge: t.bodyLarge?.copyWith(fontSize: 17, height: 1.55),
      bodyMedium: t.bodyMedium?.copyWith(fontSize: 15, height: 1.5),
      bodySmall: t.bodySmall?.copyWith(fontSize: 12, height: 1.4, color: RvColors.textSecondary),
      labelLarge: t.labelLarge?.copyWith(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.8),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: RvColors.bg,
      foregroundColor: RvColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: Border(bottom: BorderSide(color: RvColors.border)),
      titleTextStyle: TextStyle(
          fontFamily: fonteTitulo, fontSize: 22, color: RvColors.textPrimary, height: 1.1),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor: fundoBotao,
        foregroundColor: textoBotao,
        iconColor: textoBotao,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
        padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: RvSpace.xl, vertical: 14)),
        shape: const WidgetStatePropertyAll(cantoSm),
        textStyle: const WidgetStatePropertyAll(estiloBotao),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: RvColors.textPrimary,
        side: const BorderSide(color: RvColors.border),
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: RvSpace.xl, vertical: 14),
        shape: cantoSm,
        textStyle: estiloBotao,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
          foregroundColor: RvColors.textPrimary, shape: cantoSm, textStyle: estiloBotao),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: RvColors.brand,
      foregroundColor: RvColors.onBrand,
      hoverColor: RvColors.brandHover,
    ),
    cardTheme: CardThemeData(
      color: RvColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: RvSpace.xs),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RvRadius.md),
        side: const BorderSide(color: RvColors.border),
      ),
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: RvColors.surface,
      selectedColor: RvColors.brandSoft,
      side: BorderSide(color: RvColors.border),
      shape: StadiumBorder(),
      labelStyle: TextStyle(color: RvColors.textPrimary),
      checkmarkColor: RvColors.textPrimary,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: RvColors.surfaceRaised,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RvRadius.lg),
          side: const BorderSide(color: RvColors.border)),
      titleTextStyle: const TextStyle(
          fontFamily: fonteTitulo, fontSize: 26, color: RvColors.textPrimary),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: RvColors.surfaceRaised,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: RvColors.textMuted,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: RvColors.surfaceRaised,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RvRadius.md),
          side: const BorderSide(color: RvColors.border)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: RvColors.surface,
      hintStyle: const TextStyle(color: RvColors.textMuted),
      labelStyle: const TextStyle(color: RvColors.textSecondary),
      helperStyle: RvText.caption,
      errorStyle: const TextStyle(color: RvColors.danger, fontSize: 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: RvSpace.lg, vertical: 14),
      border: bordaCampo,
      enabledBorder: bordaCampo,
      focusedBorder: bordaCampo.copyWith(
          borderSide: const BorderSide(color: RvColors.brand, width: 1.5)),
      errorBorder: bordaCampo.copyWith(borderSide: const BorderSide(color: RvColors.danger)),
      focusedErrorBorder: bordaCampo.copyWith(
          borderSide: const BorderSide(color: RvColors.danger, width: 1.5)),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? RvColors.brand : Colors.transparent),
      checkColor: const WidgetStatePropertyAll(RvColors.onBrand),
      side: const BorderSide(color: RvColors.textSecondary, width: 1.5),
    ),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? RvColors.brand : RvColors.surfaceRaised),
      thumbColor: const WidgetStatePropertyAll(RvColors.textPrimary),
      trackOutlineColor: const WidgetStatePropertyAll(RvColors.border),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: RvColors.brand,
      linearTrackColor: RvColors.surfaceRaised,
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: RvColors.textPrimary,
      unselectedLabelColor: RvColors.textSecondary,
      indicatorColor: RvColors.brand,
      dividerColor: RvColors.border,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: RvColors.surfaceRaised,
      contentTextStyle: const TextStyle(color: RvColors.textPrimary, fontSize: 15),
      actionTextColor: RvColors.brandHover,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RvRadius.md),
          side: const BorderSide(color: RvColors.border)),
      insetPadding: const EdgeInsets.all(RvSpace.lg),
    ),
    dividerTheme: const DividerThemeData(color: RvColors.border, thickness: 1, space: 1),
    dividerColor: RvColors.border,
    badgeTheme: const BadgeThemeData(backgroundColor: RvColors.brand, textColor: RvColors.onBrand),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: RvColors.surfaceRaised,
        borderRadius: BorderRadius.circular(RvRadius.sm),
        border: Border.all(color: RvColors.border),
      ),
      textStyle: const TextStyle(color: RvColors.textPrimary, fontSize: 12),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: RvColors.brandHover,
      selectionColor: Color(0x66B3121E),
      selectionHandleColor: RvColors.brand,
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStatePropertyAll(RvColors.textPrimary.withValues(alpha: 0.3)),
      thickness: const WidgetStatePropertyAll(6),
      radius: const Radius.circular(3),
    ),
  );
}
