import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Uma cor disponível para a peça. A foto original é reaproveitada e
/// recolorida por filtro, então novas cores = só uma linha no catalogo.json.
///
/// - [hue]: gira o matiz em graus (bom para peças já coloridas).
/// - [tom]: cor ARGB aplicada com BlendMode.color (funciona também em
///   peças pretas, brancas ou cinza, onde girar o matiz não muda nada).
class VarianteCor {
  const VarianteCor({required this.nome, this.hue = 0, this.tom});

  final String nome;
  final double hue;
  final int? tom;

  factory VarianteCor.fromJson(Map<String, dynamic> json) {
    final hex = json['tom'] as String?;
    return VarianteCor(
      nome: json['nome'] as String,
      hue: (json['hue'] as num?)?.toDouble() ?? 0,
      tom: hex == null
          ? null
          : int.parse('FF${hex.replaceFirst('#', '')}', radix: 16),
    );
  }

  bool get ehOriginal => hue == 0 && tom == null;

  /// Aplica a cor sobre o widget da foto.
  Widget aplicar(Widget foto) {
    if (ehOriginal) return foto;
    return ColorFiltered(
      colorFilter: tom != null
          ? ColorFilter.mode(Color(tom!), BlendMode.color)
          : ColorFilter.matrix(_matrizHue(hue)),
      child: foto,
    );
  }

  static List<double> _matrizHue(double graus) {
    final r = graus * math.pi / 180;
    final c = math.cos(r), s = math.sin(r);
    return [
      0.213 + c * 0.787 - s * 0.213, 0.715 - c * 0.715 - s * 0.715,
      0.072 - c * 0.072 + s * 0.928, 0, 0, //
      0.213 - c * 0.213 + s * 0.143, 0.715 + c * 0.285 + s * 0.140,
      0.072 - c * 0.072 - s * 0.283, 0, 0, //
      0.213 - c * 0.213 - s * 0.787, 0.715 - c * 0.715 + s * 0.715,
      0.072 + c * 0.928 + s * 0.072, 0, 0, //
      0, 0, 0, 1, 0,
    ];
  }
}
