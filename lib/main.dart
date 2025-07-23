import 'package:flutter/material.dart';
import 'particles_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Particles',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ParticlesScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
