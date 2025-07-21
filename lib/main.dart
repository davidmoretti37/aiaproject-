// Minimal Flutter voice-only AI bot with animated orb
// Required dependencies in pubspec.yaml:
//   speech_to_text: ^6.3.0
//   flutter_tts: ^3.8.5
//   http: ^1.2.1
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'package:aia_project/orb_all_in_one.dart';

void main() {
  runApp(const OrbVoiceApp());
}

class OrbVoiceApp extends StatelessWidget {
  const OrbVoiceApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ModularOrbDemoScreen(),
    );
  }
}

class ModularOrbDemoScreen extends StatefulWidget {
  const ModularOrbDemoScreen({super.key});
  @override
  State<ModularOrbDemoScreen> createState() => _ModularOrbDemoScreenState();
}

class _ModularOrbDemoScreenState extends State<ModularOrbDemoScreen> {
  final OrbController _orbController = OrbController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: MagnetWrapper(
          child: ModularAnimatedOrb(
            controller: _orbController,
          ),
        ),
      ),
    );
  }
}
