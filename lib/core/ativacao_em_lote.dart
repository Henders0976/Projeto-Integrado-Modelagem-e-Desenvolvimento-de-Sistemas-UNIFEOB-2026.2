/// O que aconteceu ao ativar ou desativar vários produtos de uma vez.
class ResultadoLote {
  const ResultadoLote({required this.alterados, required this.jaEstavam, required this.falhas});

  /// Quantos mudaram de estado.
  final int alterados;

  /// Quantos já estavam no estado pedido (nada a fazer).
  final int jaEstavam;

  /// Códigos dos que deram erro. Os demais foram feitos mesmo assim.
  final List<String> falhas;
}

/// Ativa ou desativa, um a um, os [codigos] marcados entre os [produtos] (mapas como o `GET /admin/produtos`
/// devolve, com `codigo` e `ativo`). Quem já está no estado pedido é pulado, e um erro num produto não impede os outros.
Future<ResultadoLote> aplicarAtivo({
  required List<Map<String, dynamic>> produtos,
  required Set<String> codigos,
  required bool ativo,
  required Future<void> Function(String codigo, bool ativo) alterar,
}) async {
  var alterados = 0;
  var jaEstavam = 0;
  final falhas = <String>[];
  for (final p in produtos) {
    final codigo = p['codigo'] as String;
    if (!codigos.contains(codigo)) continue;
    if ((p['ativo'] == true) == ativo) {
      jaEstavam++;
      continue;
    }
    try {
      await alterar(codigo, ativo);
      alterados++;
    } catch (_) {
      falhas.add(codigo);
    }
  }
  return ResultadoLote(alterados: alterados, jaEstavam: jaEstavam, falhas: falhas);
}

/// Frase para o aviso depois da ação em lote.
String resumoDoLote(ResultadoLote r, {required bool ativo}) {
  final verbo = ativo ? 'ativado' : 'desativado';
  final partes = <String>[
    if (r.alterados > 0) '${r.alterados} ${r.alterados == 1 ? verbo : '${verbo}s'}',
    if (r.jaEstavam > 0) '${r.jaEstavam} já ${r.jaEstavam == 1 ? 'estava' : 'estavam'} assim',
    if (r.falhas.isNotEmpty) '${r.falhas.length} com erro (${r.falhas.join(', ')})',
  ];
  return partes.isEmpty ? 'Nada foi alterado.' : '${partes.join('; ')}.';
}
