import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieAIAAnimation extends StatefulWidget {
  const LottieAIAAnimation({Key? key}) : super(key: key);

  @override
  _LottieAIAAnimationState createState() => _LottieAIAAnimationState();
}

class _LottieAIAAnimationState extends State<LottieAIAAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6), // Match the duration of the animation
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        'assets/aia_animation.json',
        controller: _controller,
        width: 350,
        height: 200,
        fit: BoxFit.contain,
        onLoaded: (composition) {
          // Configure the AnimationController with the duration of the
          // Lottie file to ensure the animation syncs with the file
          _controller.duration = composition.duration;
          _controller.forward();
        },
      ),
    );
  }

}
