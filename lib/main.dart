import 'package:flutter/material.dart';
import 'complete_intro_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIA Complete Intro Sequence',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CompleteIntroScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
