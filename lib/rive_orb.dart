import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class RiveOrb extends StatelessWidget {
  const RiveOrb({super.key});

  @override
  Widget build(BuildContext context) {
    return RiveAnimation.asset(
      'assets/emotional_chatbot.riv',
      fit: BoxFit.cover,
      artboard: 'Artboard',
      stateMachines: const ['State Machine 1'],
    );
  }
}
