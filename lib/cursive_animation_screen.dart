import 'package:flutter/material.dart';
import 'dart:async';
import 'package:aia_project/orb_screen.dart';
import 'package:aia_project/cursive_painter.dart';

class CursiveAnimationScreen extends StatefulWidget {
  const CursiveAnimationScreen({super.key});

  @override
  _CursiveAnimationScreenState createState() => _CursiveAnimationScreenState();
}

class _CursiveAnimationScreenState extends State<CursiveAnimationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
    _controller.forward();

    Timer(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OrbScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CustomPaint(
          size: const Size(300, 200),
          painter: CursivePainter(progress: _animation.value),
        ),
      ),
    );
  }
}
