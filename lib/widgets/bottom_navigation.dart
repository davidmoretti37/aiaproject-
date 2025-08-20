import 'package:flutter/material.dart';

class AIABottomNavigation extends StatelessWidget {
  final bool isMuted;
  final VoidCallback onChatTap;
  final VoidCallback onMuteTap;

  const AIABottomNavigation({
    Key? key,
    required this.isMuted,
    required this.onChatTap,
    required this.onMuteTap,
  }) : super(key: key);

  static const Color iconColor = Color(0xFF3DB6D4); // Cor principal do projeto

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40, left: 30, right: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Chat icon button
          GestureDetector(
            onTap: onChatTap,
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Icon(
                Icons.chat_bubble,
                color: iconColor,
                size: 22,
              ),
            ),
          ),
          // Mic/Mute icon button
          GestureDetector(
            onTap: onMuteTap,
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Icon(
                Icons.close,
                color: iconColor,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
