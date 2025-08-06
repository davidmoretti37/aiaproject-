import 'package:flutter/material.dart';
import '../widgets/halo_orb.dart';
import '../../chat/screens/chat_screen.dart';

class OrbScreen extends StatelessWidget {
  const OrbScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen()),
              );
            },
            child: const HaloOrb(),
          ),
          const SizedBox(height: 40),
          Text(
            'Tap the halo to start chatting',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
