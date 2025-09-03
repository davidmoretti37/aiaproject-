import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts _flutterTts = FlutterTts();

  Future<void> speak(String text) async {
    await _flutterTts.setLanguage("pt-BR");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }
}
