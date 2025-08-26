import 'package:flutter/material.dart';

class ImageSlide extends StatelessWidget {
  final String imagePath;
  const ImageSlide({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 60, left: 24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Image.asset(
          imagePath,
          width: 400,
          height: 320,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
