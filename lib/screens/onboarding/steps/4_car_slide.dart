import 'package:flutter/material.dart';

class CarSlide extends StatelessWidget {
  const CarSlide({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 60, left: 24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Image.asset(
          'assets/car.png',
          width: 400,
          height: 320,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
