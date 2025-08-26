import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../styles.dart';
import 'onboarding_step_layout.dart';

class TravelAgentScreen extends StatefulWidget {
  const TravelAgentScreen({Key? key}) : super(key: key);

  @override
  State<TravelAgentScreen> createState() => _TravelAgentScreenState();
}

class _TravelAgentScreenState extends State<TravelAgentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _hasFidelityProgram = false;
  final _fidelityProgramNameController = TextEditingController();
  final _fidelityProgramNumberController = TextEditingController();
  final _mainCityController = TextEditingController();
  final _preferredAirportController = TextEditingController();
  final _frequentCitiesController = TextEditingController();
  String _flightClass = 'Economy';
  String _seatPref = 'Corredor';
  String _airline = '';
  String _preferredTime = 'Manhã';
  final _docController = TextEditingController();
  final _countryController = TextEditingController();
  final _emergencyName1Controller = TextEditingController();
  final _emergencyPhone1Controller = TextEditingController();
  bool _showSecondEmergencyContact = false;
  final _emergencyName2Controller = TextEditingController();
  final _emergencyPhone2Controller = TextEditingController();

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
                const TextSpan(text: 'Configurações de '),
                TextSpan(
                  text: 'Viagem',
                  style: OnboardingStyles.titleStyle.copyWith(
                    color: const Color(0xFF95C5D9),
                  ),
                ),
              ],
            ),
          ).animate().fade(duration: 500.ms).slideX(),
          const SizedBox(height: 10),
          Text(
            'Personalize suas preferências de viagem e programas de fidelidade.',
            style: OnboardingStyles.subtitleStyle,
          ).animate().fade(duration: 500.ms).slideX(delay: 200.ms),
          const SizedBox(height: 32),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Programa de Fidelidade',
                      style: OnboardingStyles.subtitleStyle.copyWith(
                        color: const Color(0xFF6B6B6B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: _hasFidelityProgram,
                      onChanged: (value) {
                        setState(() {
                          _hasFidelityProgram = value;
                        });
                      },
                      activeColor: const Color(0xFF95C5D9),
                    ),
                  ],
                ).animate().fade(duration: 500.ms).slideX(delay: 400.ms),
                if (_hasFidelityProgram) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _fidelityProgramNameController,
                    decoration: OnboardingStyles.inputDecoration('Nome do Programa'),
                  ).animate().fade(duration: 500.ms).slideX(delay: 500.ms),
                  const SizedBox(height: 22),
                  TextFormField(
                    controller: _fidelityProgramNumberController,
                    decoration: OnboardingStyles.inputDecoration('Número do Programa'),
                  ).animate().fade(duration: 500.ms).slideX(delay: 600.ms),
                ],
                const SizedBox(height: 32),
                Text(
                  'Aeroportos Preferenciais',
                  style: OnboardingStyles.subtitleStyle.copyWith(
                    color: const Color(0xFF6B6B6B),
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fade(duration: 500.ms).slideX(delay: 700.ms),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _mainCityController,
                  decoration: OnboardingStyles.inputDecoration('Cidade Principal'),
                ).animate().fade(duration: 500.ms).slideX(delay: 800.ms),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _preferredAirportController,
                  decoration: OnboardingStyles.inputDecoration('Aeroporto Preferido (GRU, CGH, VCP)'),
                ).animate().fade(duration: 500.ms).slideX(delay: 900.ms),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _frequentCitiesController,
                  decoration: OnboardingStyles.inputDecoration('Cidades Frequentes (até 5)'),
                ).animate().fade(duration: 500.ms).slideX(delay: 1000.ms),
                const SizedBox(height: 32),
                Text(
                  'Preferências de Voo',
                  style: OnboardingStyles.subtitleStyle.copyWith(
                    color: const Color(0xFF6B6B6B),
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fade(duration: 500.ms).slideX(delay: 1100.ms),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _flightClass,
                  decoration: OnboardingStyles.inputDecoration('Classe Preferida'),
                  items: const [
                    DropdownMenuItem(value: 'Economy', child: Text('Economy')),
                    DropdownMenuItem(value: 'Premium', child: Text('Premium')),
                    DropdownMenuItem(value: 'Business', child: Text('Business')),
                  ],
                  onChanged: (v) => setState(() => _flightClass = v ?? 'Economy'),
                ).animate().fade(duration: 500.ms).slideX(delay: 1200.ms),
                const SizedBox(height: 22),
                DropdownButtonFormField<String>(
                  value: _seatPref,
                  decoration: OnboardingStyles.inputDecoration('Assento Preferido'),
                  items: const [
                    DropdownMenuItem(value: 'Corredor', child: Text('Corredor')),
                    DropdownMenuItem(value: 'Janela', child: Text('Janela')),
                    DropdownMenuItem(value: 'Meio', child: Text('Meio')),
                  ],
                  onChanged: (v) => setState(() => _seatPref = v ?? 'Corredor'),
                ).animate().fade(duration: 500.ms).slideX(delay: 1300.ms),
                const SizedBox(height: 22),
                TextFormField(
                  controller: TextEditingController(text: _airline),
                  decoration: OnboardingStyles.inputDecoration('Companhia Aérea Preferida'),
                ).animate().fade(duration: 500.ms).slideX(delay: 1400.ms),
                const SizedBox(height: 22),
                DropdownButtonFormField<String>(
                  value: _preferredTime,
                  decoration: OnboardingStyles.inputDecoration('Horário Preferencial'),
                  items: const [
                    DropdownMenuItem(value: 'Manhã', child: Text('Manhã')),
                    DropdownMenuItem(value: 'Tarde', child: Text('Tarde')),
                    DropdownMenuItem(value: 'Noite', child: Text('Noite')),
                  ],
                  onChanged: (v) => setState(() => _preferredTime = v ?? 'Manhã'),
                ).animate().fade(duration: 500.ms).slideX(delay: 1500.ms),
                const SizedBox(height: 32),
                Text(
                  'Informações de Booking',
                  style: OnboardingStyles.subtitleStyle.copyWith(
                    color: const Color(0xFF6B6B6B),
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fade(duration: 500.ms).slideX(delay: 1600.ms),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _docController,
                  decoration: OnboardingStyles.inputDecoration('Documento (CPF/Passaporte)'),
                ).animate().fade(duration: 500.ms).slideX(delay: 1700.ms),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _countryController,
                  decoration: OnboardingStyles.inputDecoration('País de Residência'),
                ).animate().fade(duration: 500.ms).slideX(delay: 1800.ms),
                const SizedBox(height: 32),
                Text(
                  'Contatos de Emergência',
                  style: OnboardingStyles.subtitleStyle.copyWith(
                    color: const Color(0xFF6B6B6B),
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fade(duration: 500.ms).slideX(delay: 1900.ms),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emergencyName1Controller,
                  decoration: OnboardingStyles.inputDecoration('Nome do Contato de Emergência'),
                ).animate().fade(duration: 500.ms).slideX(delay: 2000.ms),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _emergencyPhone1Controller,
                  decoration: OnboardingStyles.inputDecoration('Telefone do Contato de Emergência'),
                  keyboardType: TextInputType.phone,
                ).animate().fade(duration: 500.ms).slideX(delay: 2100.ms),
                if (_showSecondEmergencyContact) ...[
                  const SizedBox(height: 22),
                  TextFormField(
                    controller: _emergencyName2Controller,
                    decoration: OnboardingStyles.inputDecoration('Nome do Contato de Emergência 2'),
                  ).animate().fade(duration: 500.ms).slideX(delay: 2200.ms),
                  const SizedBox(height: 22),
                  TextFormField(
                    controller: _emergencyPhone2Controller,
                    decoration: OnboardingStyles.inputDecoration('Telefone do Contato de Emergência 2'),
                    keyboardType: TextInputType.phone,
                  ).animate().fade(duration: 500.ms).slideX(delay: 2300.ms),
                ],
                const SizedBox(height: 22),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showSecondEmergencyContact = true;
                    });
                  },
                  icon: const Icon(Icons.add, color: Color(0xFF95C5D9)),
                  label: Text(
                    'Adicionar Outro Contato',
                    style: OnboardingStyles.subtitleStyle.copyWith(
                      color: const Color(0xFF95C5D9),
                    ),
                  ),
                ).animate().fade(duration: 500.ms).slideX(delay: 2400.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
