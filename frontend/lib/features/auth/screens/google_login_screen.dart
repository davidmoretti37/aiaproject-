import 'package:flutter/material.dart';
import 'package:frontend/core/services/google_auth_service.dart';

class GoogleLoginScreen extends StatelessWidget {
  final VoidCallback onLoginSuccess;

  const GoogleLoginScreen({Key? key, required this.onLoginSuccess}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final googleAuthService = GoogleAuthService();
            final user = await googleAuthService.signInWithGoogle();
            if (user != null) {
              onLoginSuccess();
            }
          },
          child: const Text('Sign in with Google'),
        ),
      ),
    );
  }
}
