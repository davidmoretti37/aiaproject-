import 'package:flutter/material.dart';
import 'dart:async';
import 'package:aia_project/orb_screen.dart';
import 'package:aia_project/hello_animation.dart';

class HelloAnimationScreen extends StatefulWidget {
  const HelloAnimationScreen({super.key});

  @override
  _HelloAnimationScreenState createState() => _HelloAnimationScreenState();
}

class _HelloAnimationScreenState extends State<HelloAnimationScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OrbScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: HelloAnimation(),
      ),
    );
  }
}
