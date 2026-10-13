import 'package:url_launcher/url_launcher.dart';

/// Identificação da loja: aparece no rodapé e na política de privacidade.
/// O site tem os mesmos dados em site/src/lib/formato.ts: mude os dois juntos.
const cnpjLoja = '68.647.856/0001-97';
const emailContato = 'suporte.rvlabel@gmail.com';

Future<bool> abrirEmailContato() => launchUrl(
    Uri(scheme: 'mailto', path: emailContato),
    mode: LaunchMode.externalApplication);
