import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/aia_video_player.dart';

class OrbScreen extends StatefulWidget {
  const OrbScreen({Key? key}) : super(key: key);

  @override
  State<OrbScreen> createState() => _OrbScreenState();
}

class _OrbScreenState extends State<OrbScreen> {
  bool _showTapToSpeak = true;

  void _onTapToSpeak() {
    setState(() {
      _showTapToSpeak = false;
    });
    // TODO: Implement your AI tap-to-speak logic here
    // For example: context.read<YourAIProvider>().startListening();
    print('Tap to speak triggered');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          AIAVideoPlayer(
            size: MediaQuery.of(context).size.width * 0.8,
          ),
          if (_showTapToSpeak)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _onTapToSpeak,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      'Tap to speak',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
