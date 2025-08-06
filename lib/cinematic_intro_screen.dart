import 'package:flutter/material.dart';
import 'cinematic_intro_sequence.dart';

class CinematicIntroScreen extends StatelessWidget {
  const CinematicIntroScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: const CinematicIntroSequence(),
    );
  }
}
