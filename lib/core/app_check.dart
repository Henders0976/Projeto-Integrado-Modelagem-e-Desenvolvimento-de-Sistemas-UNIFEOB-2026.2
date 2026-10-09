import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

/// Token de debug do App Check. O iniciar.* gera e passa via --dart-define;
/// ele precisa estar cadastrado no console (App Check > Apps > Gerenciar tokens de debug).
const _tokenDebug = String.fromEnvironment('APP_CHECK_DEBUG_TOKEN');

/// Nome do dispositivo/plataforma em que o app está rodando.
String dispositivoAtual() => kIsWeb ? 'web' : defaultTargetPlatform.name;

/// Ativa o App Check com o provedor certo para cada dispositivo.
/// Web e Windows só têm provedor de debug aqui; no Android e no iOS/macOS,
/// builds release usam os provedores oficiais (Play Integrity / DeviceCheck).
Future<void> configurarAppCheck() async {
  final token = _tokenDebug.isEmpty ? null : _tokenDebug;
  debugPrint('App Check: dispositivo = ${dispositivoAtual()}, '
      'token de debug ${token == null ? 'AUSENTE' : 'presente'}');
  await FirebaseAppCheck.instance.activate(
    providerWeb: WebDebugProvider(debugToken: token),
    providerAndroid: kReleaseMode
        ? const AndroidPlayIntegrityProvider()
        : AndroidDebugProvider(debugToken: token),
    providerApple: kReleaseMode
        ? const AppleDeviceCheckProvider()
        : AppleDebugProvider(debugToken: token),
    providerWindows: WindowsDebugProvider(debugToken: token),
  );
}
