import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../styles.dart';
import 'onboarding_step_layout.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  final List<String> _images = [
    'assets/airplane.png',
    'assets/calendar.png',
    'assets/car.png',
    'assets/email.png',
    'assets/food.png',
    'assets/messages.png',
    'assets/reminders.png',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < _images.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingStepLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 100),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: OnboardingStyles.titleStyle,
                    children: [
                      const TextSpan(text: 'Bem Vindo ao '),
                      TextSpan(
                        text: 'AIA',
                        style: OnboardingStyles.titleStyle.copyWith(
                          color: const Color(0xFF95C5D9),
                        ),
                      ),
                    ],
                  ),
                ).animate().fade(duration: 500.ms).slideX(),
                const SizedBox(height: 8),
                Text(
                  'Seu assistente inteligente para organizar sua vida, viagens, agenda, veículos, alimentação, e muito mais.',
                  style: OnboardingStyles.subtitleStyle,
                ).animate().fade(duration: 500.ms).slideX(delay: 200.ms),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 150, left: 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  height: 350,
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      return Image.asset(_images[index], fit: BoxFit.contain)
                          .animate(
                            onPlay: (controller) => controller.repeat(),
                          )
                          .moveY(
                            begin: -10,
                            end: 10,
                            duration: const Duration(seconds: 2),
                            curve: Curves.easeInOut,
                          )
                          .then()
                          .moveY(
                            begin: 10,
                            end: -10,
                            duration: const Duration(seconds: 2),
                            curve: Curves.easeInOut,
                          );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
