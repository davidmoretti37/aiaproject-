import 'package:flutter/material.dart';
import '../shared/app_icon_widget.dart';

/// Tela de splash nativa que aparece logo ao abrir o app
class NativeSplashScreen extends StatelessWidget {
  const NativeSplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppIconWidget(size: 150),
            const SizedBox(height: 30),
            Text(
              'AIA',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
