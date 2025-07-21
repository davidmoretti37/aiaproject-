import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class EmotionalChatbot extends StatefulWidget {
  const EmotionalChatbot({super.key});

  @override
  State<EmotionalChatbot> createState() => _EmotionalChatbotState();
}

class _EmotionalChatbotState extends State<EmotionalChatbot> {
  Artboard? _riveArtboard;
  late StateMachineController _controller;
  SMIInput<double>? _subtleMovements;
  SMIInput<double>? _breathing;
  SMIInput<double>? _lookingAround;
  SMIInput<bool>? _blinking;

  @override
  void initState() {
    super.initState();
    _loadRiveFile();
  }

  Future<void> _loadRiveFile() async {
    try {
      final file = await RiveFile.asset('assets/emotional_chatbot.riv');
      final artboard = file.mainArtboard;
      final controller =
          StateMachineController.fromArtboard(artboard, 'State Machine 1');
      if (controller != null) {
        artboard.addController(controller);
        _controller = controller;
        _subtleMovements = controller.findInput<double>('subtle_movements');
        _breathing = controller.findInput<double>('breathing');
        _lookingAround = controller.findInput<double>('looking_around');
        _blinking = controller.findInput<bool>('blinking');

        // Start with some default values
        _subtleMovements?.value = 1.0;
        _breathing?.value = 1.0;
        _lookingAround?.value = 0.0;
        _blinking?.value = false;

        setState(() => _riveArtboard = artboard);
      }
    } catch (e) {
      // Handle errors, e.g., file not found, format error
      debugPrint('Error loading Rive file: $e');
      // Optionally, show an error message to the user
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _riveArtboard == null
        ? const Center(child: CircularProgressIndicator())
        : Rive(
            artboard: _riveArtboard!,
            fit: BoxFit.cover,
          );
  }
}
