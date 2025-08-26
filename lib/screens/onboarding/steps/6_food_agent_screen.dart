import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import '../styles.dart';
import 'onboarding_step_layout.dart';

class FoodAgentScreen extends StatefulWidget {
  const FoodAgentScreen({Key? key}) : super(key: key);

  @override
  State<FoodAgentScreen> createState() => _FoodAgentScreenState();
}

class _FoodAgentScreenState extends State<FoodAgentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mainLocationController = TextEditingController();
  final _homeController = TextEditingController();
  final _workController = TextEditingController();
  final _otherLocationController = TextEditingController();
  final _favTypesController = TextEditingController();
  final _restrictionsController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _budgetController = TextEditingController();
  String _deliveryPref = 'Rapidez';
  final List<String> _preferences = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _mainLocationController.text =
            '${position.latitude}, ${position.longitude}';
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingStepLayout(
      child: ListView(
        padding: const EdgeInsets.only(top: 90, left: 24, right: 24, bottom: 150),
        children: [
          RichText(
            text: TextSpan(
              style: OnboardingStyles.titleStyle,
              children: [
                const TextSpan(text: 'Preferências '),
                TextSpan(
                  text: 'Alimentares',
                  style: OnboardingStyles.titleStyle.copyWith(
                    color: const Color(0xFF95C5D9),
                  ),
                ),
              ],
            ),
          ).animate().fade(duration: 500.ms).slideX(),
          const SizedBox(height: 10),
          Text(
            'Personalize suas preferências de comida e entrega.',
            style: OnboardingStyles.subtitleStyle,
          ).animate().fade(duration: 500.ms).slideX(delay: 200.ms),
          const SizedBox(height: 32),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _mainLocationController,
                  decoration: OnboardingStyles.inputDecoration('Localização Principal'),
                ).animate().fade(duration: 500.ms).slideX(delay: 400.ms),
                const SizedBox(height: 32),
                Text(
                  'Localizações Frequentes',
                  style: OnboardingStyles.subtitleStyle.copyWith(
                    color: const Color(0xFF6B6B6B),
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fade(duration: 500.ms).slideX(delay: 500.ms),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _homeController,
                  decoration: OnboardingStyles.inputDecoration('Casa'),
                ).animate().fade(duration: 500.ms).slideX(delay: 600.ms),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _workController,
                  decoration: OnboardingStyles.inputDecoration('Trabalho'),
                ).animate().fade(duration: 500.ms).slideX(delay: 700.ms),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _otherLocationController,
                  decoration: OnboardingStyles.inputDecoration('Outro'),
                ).animate().fade(duration: 500.ms).slideX(delay: 800.ms),
                const SizedBox(height: 32),
                Text(
                  'Preferências Culinárias',
                  style: OnboardingStyles.subtitleStyle.copyWith(
                    color: const Color(0xFF6B6B6B),
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fade(duration: 500.ms).slideX(delay: 900.ms),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _favTypesController,
                  decoration: OnboardingStyles.inputDecoration('Tipos Favoritos (Italiana, Japonesa, etc.)'),
                  onFieldSubmitted: (value) {
                    setState(() {
                      _preferences.add(value);
                      _favTypesController.clear();
                    });
                  },
                ).animate().fade(duration: 500.ms).slideX(delay: 1000.ms),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _preferences
                      .map((preference) => Chip(
                            label: Text(preference),
                            onDeleted: () {
                              setState(() {
                                _preferences.remove(preference);
                              });
                            },
                          ))
                      .toList(),
                ).animate().fade(duration: 500.ms).slideX(delay: 1100.ms),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _restrictionsController,
                  decoration: OnboardingStyles.inputDecoration('Restrições Alimentares'),
                ).animate().fade(duration: 500.ms).slideX(delay: 1200.ms),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _allergiesController,
                  decoration: OnboardingStyles.inputDecoration('Alergias'),
                ).animate().fade(duration: 500.ms).slideX(delay: 1300.ms),
                const SizedBox(height: 32),
                Text(
                  'Configurações de Pedido',
                  style: OnboardingStyles.subtitleStyle.copyWith(
                    color: const Color(0xFF6B6B6B),
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fade(duration: 500.ms).slideX(delay: 1400.ms),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _budgetController,
                  decoration: OnboardingStyles.inputDecoration('Orçamento Típico por Pessoa'),
                ).animate().fade(duration: 500.ms).slideX(delay: 1500.ms),
                const SizedBox(height: 22),
                DropdownButtonFormField<String>(
                  value: _deliveryPref,
                  decoration: OnboardingStyles.inputDecoration('Preferência de Entrega'),
                  items: const [
                    DropdownMenuItem(value: 'Rapidez', child: Text('Rapidez')),
                    DropdownMenuItem(value: 'Qualidade', child: Text('Qualidade')),
                  ],
                  onChanged: (v) => setState(() => _deliveryPref = v ?? 'Rapidez'),
                ).animate().fade(duration: 500.ms).slideX(delay: 1600.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
