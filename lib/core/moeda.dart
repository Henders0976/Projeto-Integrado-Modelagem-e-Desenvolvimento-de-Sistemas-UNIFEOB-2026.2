/// Formata valores em reais (ex.: 89.9 -> "R$ 89,90").
String formatarReais(double valor) =>
    'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
