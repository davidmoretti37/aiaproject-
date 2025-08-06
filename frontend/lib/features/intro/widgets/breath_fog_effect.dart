import 'package:flutter/material.dart';

class BreathFogEffect extends StatefulWidget {
  final Widget child;

  const BreathFogEffect({Key? key, required this.child}) : super(key: key);

  @override
  _BreathFogEffectState createState() => _BreathFogEffectState();
}

class _BreathFogEffectState extends State<BreathFogEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Colors.white.withOpacity(_animation.value * 0.2),
                Colors.transparent,
              ],
              stops: [0.0, 1.0],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
