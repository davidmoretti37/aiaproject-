import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AIAAnimation extends StatefulWidget {
  final VoidCallback onComplete;

  const AIAAnimation({Key? key, required this.onComplete}) : super(key: key);

  @override
  _AIAAnimationState createState() => _AIAAnimationState();
}

class _AIAAnimationState extends State<AIAAnimation> with TickerProviderStateMixin {
  late final AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });

    _lottieController.forward();
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/aia_text_animation.json',
      controller: _lottieController,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      fit: BoxFit.contain,
    );
  }
}
