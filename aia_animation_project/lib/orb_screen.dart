import 'package:flutter/material.dart';
import 'orb_all_in_one.dart';

class OrbScreen extends StatelessWidget {
  const OrbScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: MagnetWrapper(
          child: ModularAnimatedOrb(
            controller: OrbController(),
          ),
        ),
      ),
    );
  }
}
