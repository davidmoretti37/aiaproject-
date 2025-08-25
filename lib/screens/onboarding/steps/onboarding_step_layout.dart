import 'package:flutter/material.dart';

class OnboardingStepLayout extends StatelessWidget {
  final String title;
  final String? description;
  final Widget child;

  const OnboardingStepLayout({
    Key? key,
    required this.title,
    this.description,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: 12),
            Text(
              description!,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
              ),
            ),
          ],
          const SizedBox(height: 32),
          Expanded(child: child),
        ],
      ),
    );
  }
}
