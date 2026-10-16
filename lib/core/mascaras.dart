import 'package:flutter/services.dart';

String _digitos(String s) => s.replaceAll(RegExp(r'\D'), '');

/// (11) 99999-9999 com 11 dígitos, (11) 9999-9999 com 10. Com mais de 11 (ex.: +55 na frente)
/// devolve só os dígitos: a validação do formulário continua aceitando de 10 a 13.
String formatarTelefone(String texto) {
  final d = _digitos(texto);
  if (d.length > 11) return d;
  final b = StringBuffer();
  for (var i = 0; i < d.length; i++) {
    if (i == 0) b.write('(');
    if (i == 2) b.write(') ');
    // O hífen vai antes dos 4 últimos: depois do 6º dígito com 10, do 7º com 11.
    if (i == (d.length == 11 ? 7 : 6)) b.write('-');
    b.write(d[i]);
  }
  return b.toString();
}

/// 000.000.000-00 (no máximo 11 dígitos).
String formatarCpf(String texto) {
  final d = _digitos(texto);
  final n = d.length > 11 ? d.substring(0, 11) : d;
  final b = StringBuffer();
  for (var i = 0; i < n.length; i++) {
    if (i == 3 || i == 6) b.write('.');
    if (i == 9) b.write('-');
    b.write(n[i]);
  }
  return b.toString();
}

/// Aplica uma das funções acima enquanto a pessoa digita.
/// shortcut: o cursor sempre vai para o fim; editar no meio do número pula o cursor. Trocar por
/// cálculo de posição se alguém reclamar.
class Mascara extends TextInputFormatter {
  const Mascara(this.formatar);
  final String Function(String) formatar;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue antigo, TextEditingValue novo) {
    final texto = formatar(novo.text);
    return TextEditingValue(
        text: texto, selection: TextSelection.collapsed(offset: texto.length));
  }
}
