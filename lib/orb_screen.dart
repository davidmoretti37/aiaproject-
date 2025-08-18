import 'package:flutter/material.dart';
import 'widgets/aia_video_player.dart';

class OrbScreen extends StatefulWidget {
  const OrbScreen({Key? key}) : super(key: key);

  @override
  State<OrbScreen> createState() => _OrbScreenState();
}

class _OrbScreenState extends State<OrbScreen> {
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
          // Tap to speak overlay (invisible, but triggers AI)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                // TODO: Implement your AI tap-to-speak logic here
                // For example: context.read<YourAIProvider>().startListening();
                print('Tap to speak triggered');
              },
            ),
          ),
        ],
      ),
    );
  }
}
