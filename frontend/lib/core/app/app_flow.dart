import 'package:flutter/material.dart';
import 'package:frontend/features/intro/screens/intro_screen.dart';
import 'package:frontend/features/auth/screens/google_login_screen.dart';
import 'package:frontend/features/orb/screens/orb_screen.dart';

class AppFlow extends StatefulWidget {
  const AppFlow({Key? key}) : super(key: key);

  @override
  _AppFlowState createState() => _AppFlowState();
}

class _AppFlowState extends State<AppFlow> {
  String _currentState = 'auth';

  void _onIntroComplete() {
    setState(() {
      _currentState = 'auth';
    });
  }

  void _onAuthComplete() {
    setState(() {
      _currentState = 'orb';
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentState) {
      case 'intro':
        return IntroScreen(onIntroComplete: _onIntroComplete);
      case 'auth':
        return GoogleLoginScreen(onLoginSuccess: _onAuthComplete);
      case 'orb':
        return OrbScreen();
      default:
        return Container();
    }
  }
}
