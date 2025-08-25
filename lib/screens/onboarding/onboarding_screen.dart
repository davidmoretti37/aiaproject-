import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'onboarding_controller.dart';

// Importar os placeholders das etapas
import 'steps/1_welcome_screen.dart';
import 'steps/2_profile_screen.dart';
import 'steps/3_travel_agent_screen.dart';
import 'steps/4_calendar_agent_screen.dart';
import 'steps/5_vehicle_agent_screen.dart';
import 'steps/6_food_agent_screen.dart';
import 'steps/7_gmail_agent_screen.dart';
import 'steps/8_reminder_agent_screen.dart';
import 'steps/9_whatsapp_agent_screen.dart';
import 'steps/10_integrations_screen.dart';
import 'steps/11_privacy_screen.dart';
import 'steps/12_personalization_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final OnboardingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OnboardingController();
    _controller.pageController.addListener(() {
      final page = _controller.pageController.page?.round() ?? 0;
      if (_controller.currentPage != page) {
        setState(() {
          _controller.currentPage = page;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.pageController.dispose();
    super.dispose();
  }

  List<Widget> get _steps => const [
    WelcomeScreen(),
    ProfileScreen(),
    TravelAgentScreen(),
    CalendarAgentScreen(),
    VehicleAgentScreen(),
    FoodAgentScreen(),
    GmailAgentScreen(),
    ReminderAgentScreen(),
    WhatsAppAgentScreen(),
    IntegrationsScreen(),
    PrivacyScreen(),
    PersonalizationScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller.pageController,
                children: _steps,
                physics: const ClampingScrollPhysics(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: SmoothPageIndicator(
                controller: _controller.pageController,
                count: _steps.length,
                effect: const ExpandingDotsEffect(
                  dotHeight: 12,
                  dotWidth: 12,
                  activeDotColor: Color(0xFF8B8B8B),
                  dotColor: Color(0xFFE0E0E0),
                  spacing: 8,
                  expansionFactor: 2.2,
                ),
                onDotClicked: (index) {
                  _controller.jumpToPage(index);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_controller.currentPage > 0)
                    ElevatedButton(
                      onPressed: _controller.previousPage,
                      child: const Text('Voltar'),
                    )
                  else
                    const SizedBox(width: 80),
                  ElevatedButton(
                    onPressed: _controller.currentPage < _steps.length - 1
                        ? _controller.nextPage
                        : null,
                    child: const Text('Avançar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
