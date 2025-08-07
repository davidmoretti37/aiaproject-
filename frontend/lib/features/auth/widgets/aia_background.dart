import 'package:flutter/material.dart';
import 'iridescence_overlay.dart';

class AiaBackground extends StatelessWidget {
  const AiaBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: Stack(
        children: [
          IridescenceOverlay(
            color: Color(0xFF0d2e1a),
            speed: 0.008,
            amplitude: 0.2,
          ),
          IgnorePointer(
            child: ColoredBox(
              color: Color(0xFF444444),
            ),
          ),
        ],
      ),
    );
  }
}
