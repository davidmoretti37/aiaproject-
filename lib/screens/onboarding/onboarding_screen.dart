import 'package:flutter/material.dart';
import '../../activate_voice_ai_screen.dart';
import 'onboarding_controller.dart';
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
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Widget> get _steps => [
        const WelcomeScreen(),
        const ProfileScreen(),
        const TravelAgentScreen(),
        const CalendarAgentScreen(),
        const VehicleAgentScreen(),
        const FoodAgentScreen(),
        const GmailAgentScreen(),
        const ReminderAgentScreen(),
        const WhatsAppAgentScreen(),
        const IntegrationsScreen(),
        const PrivacyScreen(),
        const PersonalizationScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F9F9),
              Color(0xFFEBF2F5),
            ],
          ),
        ),
        child: Stack(
          children: [
            IndexedStack(
              index: _controller.currentPage,
              children: _steps,
            ),
            Positioned(
              bottom: 52,
              left: 30,
              right: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF95C5D9),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFFFFFFFF), size: 18),
                      onPressed: () {
                        if (_controller.currentPage == 0) {
                          Navigator.of(context).pop();
                        } else {
                          _controller.previousPage();
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _steps.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: _controller.currentPage == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _controller.currentPage == index
                                  ? const Color(0xFF95C5D9)
                                  : const Color(0xFF95C5D9).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF95C5D9),
                    ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward, color: Color(0xFFFFFFFF), size: 18),
                    onPressed: _controller.currentPage < _steps.length - 1
                        ? _controller.nextPage
                        : () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => ActivateVoiceAIScreen(onActivate: () {}),
                              ),
                            );
                          },
                  ),
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
