import 'package:flutter_test/flutter_test.dart';
import 'package:rvlabel_app/core/mascaras.dart';

void main() {
  test('telefone com 11 e 10 dígitos', () {
    expect(formatarTelefone('11999998888'), '(11) 99999-8888');
    expect(formatarTelefone('1133334444'), '(11) 3333-4444');
  });

  test('telefone digitado aos poucos e com +55', () {
    expect(formatarTelefone('1'), '(1');
    expect(formatarTelefone('119'), '(11) 9');
    expect(formatarTelefone('(11) 9999'), '(11) 9999');
    expect(formatarTelefone('5511999998888'), '5511999998888');
  });

  test('CPF', () {
    expect(formatarCpf('12345678901'), '123.456.789-01');
    expect(formatarCpf('1234'), '123.4');
    expect(formatarCpf('123456789012345'), '123.456.789-01');
  });
}
