import 'package:flutter/material.dart';

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

  InputDecoration get _inputDecoration => InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF95C5D9), width: 1.5),
        ),
        labelStyle: const TextStyle(
          color: Color(0xFFB0B0B0),
          fontWeight: FontWeight.w500,
          fontSize: 14,
          letterSpacing: 0.2,
        ),
        floatingLabelStyle: const TextStyle(
          color: Color(0xFF95C5D9),
          fontWeight: FontWeight.w600,
          fontSize: 14,
          letterSpacing: 0.2,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 90, left: 24, right: 24, bottom: 0),
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B6B6B),
            ),
            children: [
              const TextSpan(text: 'Preferências '),
              TextSpan(
                text: 'Alimentares',
                style: TextStyle(
                  color: Color(0xFF95C5D9),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Personalize suas preferências de comida e entrega.',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFFB0B0B0),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 32),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(controller: _mainLocationController, decoration: _inputDecoration.copyWith(labelText: 'Localização principal')),
              const SizedBox(height: 32),
              const Text('Localizações frequentes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF6B6B6B))),
              const SizedBox(height: 16),
              TextFormField(controller: _homeController, decoration: _inputDecoration.copyWith(labelText: 'Casa')),
              const SizedBox(height: 22),
              TextFormField(controller: _workController, decoration: _inputDecoration.copyWith(labelText: 'Trabalho')),
              const SizedBox(height: 22),
              TextFormField(controller: _otherLocationsController, decoration: _inputDecoration.copyWith(labelText: 'Outros (até 3)')),
              const SizedBox(height: 32),
              const Text('Preferências Culinárias', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF6B6B6B))),
              const SizedBox(height: 16),
              TextFormField(controller: _favTypesController, decoration: _inputDecoration.copyWith(labelText: 'Tipos favoritos (Italiana, Japonesa, etc.)')),
              const SizedBox(height: 22),
              TextFormField(controller: _restrictionsController, decoration: _inputDecoration.copyWith(labelText: 'Restrições alimentares')),
              const SizedBox(height: 22),
              TextFormField(controller: _allergiesController, decoration: _inputDecoration.copyWith(labelText: 'Alergias')),
              const SizedBox(height: 32),
              const Text('Configurações de Pedido', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF6B6B6B))),
              const SizedBox(height: 16),
              TextFormField(controller: _budgetController, decoration: _inputDecoration.copyWith(labelText: 'Orçamento típico por pessoa')),
              const SizedBox(height: 22),
              DropdownButtonFormField<String>(
                value: _deliveryPref,
                decoration: _inputDecoration.copyWith(labelText: 'Preferência de entrega'),
                items: const [
                  DropdownMenuItem(value: 'Rapidez', child: Text('Rapidez')),
                  DropdownMenuItem(value: 'Qualidade', child: Text('Qualidade')),
                ],
                onChanged: (v) => setState(() => _deliveryPref = v ?? 'Rapidez'),
              ),
              const SizedBox(height: 32),
              const Text('Plataformas preferenciais', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF6B6B6B))),
              const SizedBox(height: 16),
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
              const SizedBox(height: 22),
            ],
          ),
        ),
      ],
    );
  }
}
