import 'package:flutter/material.dart';
import 'cinematic_intro_sequence.dart';
// import 'google_signin_screen.dart'; // Removed Google signin import

class AppFlowScreen extends StatefulWidget {
  const AppFlowScreen({super.key});

  @override
  State<AppFlowScreen> createState() => _AppFlowScreenState();
}

class _AppFlowScreenState extends State<AppFlowScreen> {
  bool _showCinematicIntro = true;

  void _onCinematicIntroComplete() {
    setState(() {
      _showCinematicIntro = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showCinematicIntro) {
      return CinematicIntroSequenceWrapper(
        onComplete: _onCinematicIntroComplete,
      );
    } else {
      // Skip Google signin and go directly to chat
      return const CinematicIntroSequence();
    }
  }
}

class CinematicIntroSequenceWrapper extends StatefulWidget {
  final VoidCallback onComplete;

  const CinematicIntroSequenceWrapper({
    super.key,
    required this.onComplete,
  });

  @override
  State<CinematicIntroSequenceWrapper> createState() => _CinematicIntroSequenceWrapperState();
}

class _CinematicIntroSequenceWrapperState extends State<CinematicIntroSequenceWrapper> {
  @override
  void initState() {
    super.initState();
    
    // After the cinematic intro completes (estimated 15 seconds), navigate to Google Sign-In
    Future.delayed(const Duration(seconds: 15), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const CinematicIntroSequence();
  }
}
