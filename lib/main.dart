import 'package:flutter/material.dart';
import 'cinematic_intro_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIA Cinematic Intro Sequence',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CinematicIntroScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
