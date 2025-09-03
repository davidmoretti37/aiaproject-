import 'dart:async';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PreciseHotword {
  // Method channel to communicate with native code
  static const MethodChannel _channel = MethodChannel('hotword_precise');

  // Callback for when the hotword is detected
  Function? onHotwordDetected;

  // Start listening for the hotword
  Future<void> startListening() async {
    try {
      // Get the path to the model file in the assets
      final modelPath = await _getAssetPath('assets/precise_model/hey-mycroft.pb');
      
      // Start the hotword detection on the native side
      await _channel.invokeMethod('start', {'modelPath': modelPath});

      // Listen for the hotword detection event from the native side
      _channel.setMethodCallHandler(_handleMethodCall);
    } on PlatformException catch (e) {
      print("Failed to start hotword detection: '${e.message}'.");
    }
  }

  // Stop listening for the hotword
  Future<void> stopListening() async {
    try {
      await _channel.invokeMethod('stop');
    } on PlatformException catch (e) {
      print("Failed to stop hotword detection: '${e.message}'.");
    }
  }

  // Handle method calls from the native side
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onHotwordDetected') {
      onHotwordDetected?.call();
    }
  }

  // Helper method to get the absolute path of an asset
  Future<String> _getAssetPath(String asset) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$asset';
    final byteData = await rootBundle.load(asset);
    final buffer = byteData.buffer;
    await File(path).writeAsBytes(
        buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return path;
  }
}
