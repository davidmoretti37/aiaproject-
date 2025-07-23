import 'package:flutter/material.dart';
import 'aia_animation.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIA Animation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AIAAnimationScreen(),
    );
  }
}

class AIAAnimationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AIAAnimation(),
      ),
    );
  }
}
