import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda no aparelho o último catálogo que a API devolveu, isto é, só as peças que a administradora ativou.
/// Assim, quando o app abre sem a API (servidor desligado, sem internet), a loja continua mostrando o que ela
/// ativou, até a próxima vez que a API responder e o catálogo ser atualizado (ou a peça ser desativada).
/// Falha ao gravar ou ler nunca derruba o app: sem cache, ele só usa o catálogo embutido.
class CatalogoLocal {
  static const _chave = 'catalogo_ativado_v1';

  static Future<void> salvar(Map<String, dynamic> dados) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_chave, jsonEncode(dados));
    } catch (e) {
      debugPrint('Não consegui guardar o catálogo no aparelho: $e');
    }
  }

  /// O catálogo guardado, ou null se não há nenhum (ou se o que foi guardado não presta).
  static Future<Map<String, dynamic>?> ler() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final texto = prefs.getString(_chave);
      if (texto == null) return null;
      final dados = jsonDecode(texto);
      if (dados is Map<String, dynamic> && dados['pecas'] is List) return dados;
    } catch (e) {
      debugPrint('Catálogo guardado ilegível, ignorado: $e');
    }
    return null;
  }
}
