import 'package:flutter/material.dart';
import '../styles.dart';

class CustomSelectField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const CustomSelectField({
    Key? key,
    required this.label,
    required this.value,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: OnboardingStyles.inputDecoration(label),
        child: Text(
          value,
          style: OnboardingStyles.subtitleStyle.copyWith(
            color: const Color(0xFF6B6B6B),
          ),
        ),
      ),
    );
  }
}
