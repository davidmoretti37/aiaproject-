import 'package:flutter/material.dart';
import 'clean_app_flow.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIA Experience',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CleanAppFlow(), // Back to normal app flow: intro -> sign-in -> orb -> chat
      debugShowCheckedModeBanner: false,
    );
  }
}
