import 'dart:async';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart'
    as bg_service;
import '../ai_service.dart';
import '../domain/intent_router.dart';
import 'hotword_precise.dart';
import 'stt_service.dart';
import 'tts_service.dart';

class BackgroundService {
  static final bg_service.FlutterBackgroundService _service =
      bg_service.FlutterBackgroundService();

  static Future<void> initialize() async {
    await _service.configure(
      androidConfiguration: bg_service.AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true,
        autoStart: true,
      ),
      iosConfiguration: bg_service.IosConfiguration(
        onForeground: onStart,
        onBackground: (service) {
          // Handle background execution for iOS
          return true;
        },
      ),
    );
  }
}

@pragma('vm:entry-point')
void onStart(bg_service.ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();

  final hotword = PreciseHotword();
  final stt = STTService();
  final tts = TTSService();

  hotword.onHotwordDetected = () async {
    final command = await stt.recordCommand();
    if (command.isNotEmpty) {
      final aiService = AIService();
      final response = await aiService.sendMessage(command);
      if (response['success']) {
        final intent = response['intent_category'];
        final entities = response['metadata'];
        IntentRouter.routeIntent(intent, entities);
        await tts.speak(response['message']);
      } else {
        await tts.speak("Desculpe, não entendi.");
      }
    }
  };

  hotword.startListening();

  service.on('stopService').listen((event) {
    hotword.stopListening();
    service.stopSelf();
  });
}
