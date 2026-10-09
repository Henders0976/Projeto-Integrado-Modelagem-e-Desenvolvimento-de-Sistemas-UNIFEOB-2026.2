import 'package:url_launcher/url_launcher.dart';

class WhatsAppService {
  const WhatsAppService({required this.numero});

  /// Formato internacional sem símbolos, ex.: 5535999999999
  final String numero;

  Future<bool> enviar(String mensagem) {
    final uri = Uri.parse(
        'https://wa.me/$numero?text=${Uri.encodeComponent(mensagem)}');
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
