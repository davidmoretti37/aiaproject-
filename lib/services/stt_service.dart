import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class STTService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = '';
  Completer<String> _completer = Completer<String>();

  Future<String> recordCommand() async {
    _completer = Completer<String>();
    bool available = await _speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) => print('onError: $val'),
    );
    if (available) {
      _isListening = true;
      _speech.listen(
        onResult: (val) => _text = val.recognizedWords,
      );
      await Future.delayed(const Duration(seconds: 6));
      _speech.stop();
      _isListening = false;
      _completer.complete(_text);
    } else {
      _completer.completeError('The user has denied the use of speech recognition.');
    }
    return _completer.future;
  }
}
