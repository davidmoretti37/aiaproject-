import 'dart:async';
import 'package:flutter/material.dart';

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
          duration: const Duration(milliseconds: 800),
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
    return Column(
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
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B6B6B),
                  ),
                  children: [
                    const TextSpan(text: 'Bem Vindo ao '),
                    TextSpan(
                      text: 'AIA',
                      style: TextStyle(
                        color: Color(0xFF95C5D9),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Seu assistente inteligente para organizar sua vida, viagens, agenda, veículos, alimentação, e muito mais.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFFB0B0B0),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 60, left: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: 320,
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return Image.asset(
                      _images[index],
                      fit: BoxFit.contain,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
