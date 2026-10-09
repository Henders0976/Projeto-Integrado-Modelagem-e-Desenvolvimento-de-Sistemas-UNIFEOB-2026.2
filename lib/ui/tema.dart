import 'package:flutter/material.dart';

/// Cores da marca: vermelho que desce num pequeno degradê até o preto.
/// Para ajustar o tom exato do site, troque só estes dois valores.
const corVermelho = Color(0xFFB3121E);
const corPreto = Color(0xFF0B0B0B);

/// Texto: branco quente em vez de branco puro, e um tom mais suave tirado do
/// próprio vermelho (≥ 4,5:1 sobre o topo do degradê, onde o fundo é mais claro).
const corTexto = Color(0xFFFFF7F5);
const corTextoSuave = Color(0xFFF0D6D6);
const corLinha = Color(0x59FFF7F5); // contornos e divisores
const corPainel = Color(0xFF150E0F); // diálogos

/// Fonte dos títulos (DM Serif Display). Só existe no peso normal: não use w700+.
const fonteTitulo = 'DMSerifDisplay';

/// Raio único: fotos, botões e opções seguem a mesma quina discreta do site.
const raioPadrao = 4.0;

ThemeData temaRvLabel() {
  final esquema = ColorScheme.fromSeed(
    seedColor: corVermelho,
    brightness: Brightness.dark,
  ).copyWith(
    primary: corTexto,
    onPrimary: corPreto,
    surface: corPreto,
    onSurface: corTexto,
    onSurfaceVariant: corTextoSuave,
    outline: corLinha,
    outlineVariant: corLinha,
  );

  const quina = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(2)));
  final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
  final t = base.textTheme.apply(bodyColor: corTexto, displayColor: corTexto);

  TextStyle? titulo(TextStyle? s, {double? tamanho, double espaco = 0}) =>
      s?.copyWith(
        fontFamily: fonteTitulo,
        fontWeight: FontWeight.w400,
        fontSize: tamanho,
        height: 1.08,
        letterSpacing: espaco,
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: esquema,
    scaffoldBackgroundColor: corPreto,
    textTheme: t.copyWith(
      displayMedium: titulo(t.displayMedium, tamanho: 56, espaco: -1.2),
      displaySmall: titulo(t.displaySmall, tamanho: 42, espaco: -0.8),
      headlineMedium: titulo(t.headlineMedium, tamanho: 34, espaco: -0.4),
      headlineSmall: titulo(t.headlineSmall, tamanho: 28, espaco: -0.2),
      titleLarge: titulo(t.titleLarge, tamanho: 24),
      bodyLarge: t.bodyLarge?.copyWith(height: 1.55),
      bodyMedium: t.bodyMedium?.copyWith(height: 1.5),
      labelLarge: t.labelLarge
          ?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.4),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: corVermelho, // igual ao topo do degradê
      foregroundColor: corTexto,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
          fontFamily: fonteTitulo, fontSize: 22, color: corTexto, height: 1.1),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: corTexto,
        foregroundColor: corPreto,
        minimumSize: const Size(64, 52),
        shape: quina,
        textStyle: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.4),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: corTexto,
        minimumSize: const Size(64, 52),
        shape: quina,
        side: const BorderSide(color: corTexto),
        textStyle: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.4),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: corTexto, shape: quina),
    ),
    chipTheme: const ChipThemeData(
      selectedColor: Color(0x55FFFFFF),
      side: BorderSide(color: Colors.white54),
      labelStyle: TextStyle(color: corTexto),
      checkmarkColor: corTexto,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: corPainel,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(raioPadrao),
          side: const BorderSide(color: corLinha)),
      titleTextStyle: const TextStyle(
          fontFamily: fonteTitulo, fontSize: 26, color: corTexto),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(color: corTextoSuave),
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: corLinha)),
      focusedBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: corTexto, width: 2)),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: corTexto,
      contentTextStyle: TextStyle(color: corPreto, fontSize: 15),
      shape: quina,
      insetPadding: EdgeInsets.all(16),
    ),
    dividerTheme: const DividerThemeData(color: corLinha, thickness: 1, space: 1),
    badgeTheme: const BadgeThemeData(backgroundColor: corTexto, textColor: corPreto),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: corTexto,
      selectionColor: Color(0x66FFFFFF),
      selectionHandleColor: corTexto,
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStatePropertyAll(corTexto.withValues(alpha: 0.4)),
      thickness: const WidgetStatePropertyAll(6),
      radius: const Radius.circular(3),
    ),
  );
}
