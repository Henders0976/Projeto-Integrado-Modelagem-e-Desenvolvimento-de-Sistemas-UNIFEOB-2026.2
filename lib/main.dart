import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/app_check.dart';
import 'firebase_options.dart';
import 'services/catalogo_repository.dart';
import 'services/sacola.dart';
import 'services/whatsapp_service.dart';
import 'ui/home_page.dart';
import 'ui/tema.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // O Firebase só é necessário para o Assistente (GenUI). Se não estiver
  // configurado, o resto do app continua funcionando.
  var iaDisponivel = false;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await configurarAppCheck();
    iaDisponivel = true;
  } catch (e) {
    debugPrint('Firebase indisponível: $e');
  }

  final catalogo = await CatalogoRepository.carregar();
  runApp(RvLabelApp(catalogo: catalogo, iaDisponivel: iaDisponivel));
}

/// Raiz do app: cria as dependências uma única vez e injeta nas telas.
class RvLabelApp extends StatefulWidget {
  const RvLabelApp({super.key, required this.catalogo, required this.iaDisponivel});
  final CatalogoRepository catalogo;
  final bool iaDisponivel;

  @override
  State<RvLabelApp> createState() => _RvLabelAppState();
}

class _RvLabelAppState extends State<RvLabelApp> {
  final _sacola = Sacola();
  // TODO: trocar pelo WhatsApp real da marca (DDI+DDD+número).
  final _whatsapp = const WhatsAppService(numero: '5511999990000');

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'RV Label',
        debugShowCheckedModeBanner: false,
        theme: temaRvLabel(),
        home: HomePage(
          catalogo: widget.catalogo,
          sacola: _sacola,
          whatsapp: _whatsapp,
          iaDisponivel: widget.iaDisponivel,
        ),
      );
}
