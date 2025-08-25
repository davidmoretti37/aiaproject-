import 'package:flutter/material.dart';
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
  final _otherLocationsController = TextEditingController();
  final _favTypesController = TextEditingController();
  final _restrictionsController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _budgetController = TextEditingController();
  String _deliveryPref = 'Rapidez';
  final List<String> _platforms = [];
  final List<String> _allPlatforms = ['iFood', 'Uber Eats', 'Rappi'];

  @override
  Widget build(BuildContext context) {
    return OnboardingStepLayout(
      title: 'Preferências Alimentares',
      description: 'Personalize suas preferências de comida e entrega.',
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(controller: _mainLocationController, decoration: const InputDecoration(labelText: 'Localização principal')),
            const SizedBox(height: 16),
            const Text('Localizações frequentes', style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(controller: _homeController, decoration: const InputDecoration(labelText: 'Casa')),
            TextFormField(controller: _workController, decoration: const InputDecoration(labelText: 'Trabalho')),
            TextFormField(controller: _otherLocationsController, decoration: const InputDecoration(labelText: 'Outros (até 3)')),
            const SizedBox(height: 16),
            const Text('Preferências Culinárias', style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(controller: _favTypesController, decoration: const InputDecoration(labelText: 'Tipos favoritos (Italiana, Japonesa, etc.)')),
            TextFormField(controller: _restrictionsController, decoration: const InputDecoration(labelText: 'Restrições alimentares')),
            TextFormField(controller: _allergiesController, decoration: const InputDecoration(labelText: 'Alergias')),
            const SizedBox(height: 16),
            const Text('Configurações de Pedido', style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(controller: _budgetController, decoration: const InputDecoration(labelText: 'Orçamento típico por pessoa')),
            DropdownButtonFormField<String>(
              value: _deliveryPref,
              decoration: const InputDecoration(labelText: 'Preferência de entrega'),
              items: const [
                DropdownMenuItem(value: 'Rapidez', child: Text('Rapidez')),
                DropdownMenuItem(value: 'Qualidade', child: Text('Qualidade')),
              ],
              onChanged: (v) => setState(() => _deliveryPref = v ?? 'Rapidez'),
            ),
            const SizedBox(height: 16),
            const Text('Plataformas preferenciais', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: _allPlatforms.map((platform) {
                return FilterChip(
                  label: Text(platform),
                  selected: _platforms.contains(platform),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _platforms.add(platform);
                      } else {
                        _platforms.remove(platform);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
