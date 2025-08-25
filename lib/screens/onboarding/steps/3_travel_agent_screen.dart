import 'package:flutter/material.dart';
import 'onboarding_step_layout.dart';

class TravelAgentScreen extends StatefulWidget {
  const TravelAgentScreen({Key? key}) : super(key: key);

  @override
  State<TravelAgentScreen> createState() => _TravelAgentScreenState();
}

class _TravelAgentScreenState extends State<TravelAgentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _latamController = TextEditingController();
  final _smilesController = TextEditingController();
  final _azulController = TextEditingController();
  final _lifemilesController = TextEditingController();
  final _mainCityController = TextEditingController();
  final _preferredAirportController = TextEditingController();
  final _frequentCitiesController = TextEditingController();
  String _flightClass = 'Economy';
  String _seatPref = 'Corredor';
  String _airline = '';
  String _preferredTime = 'Manhã';
  final _docController = TextEditingController();
  String _title = 'Sr.';
  String _gender = 'M';
  final _countryController = TextEditingController();
  final _emergency1Controller = TextEditingController();
  final _emergency2Controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return OnboardingStepLayout(
      title: 'Configurações de Viagem',
      description: 'Personalize suas preferências de viagem e programas de fidelidade.',
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const Text('Programas de Fidelidade', style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(controller: _latamController, decoration: const InputDecoration(labelText: 'LATAM Pass (número)')),
            TextFormField(controller: _smilesController, decoration: const InputDecoration(labelText: 'Smiles/GOL (número)')),
            TextFormField(controller: _azulController, decoration: const InputDecoration(labelText: 'TudoAzul/Azul (número)')),
            TextFormField(controller: _lifemilesController, decoration: const InputDecoration(labelText: 'LifeMiles/Avianca (número)')),
            const SizedBox(height: 16),
            const Text('Aeroportos Preferenciais', style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(controller: _mainCityController, decoration: const InputDecoration(labelText: 'Cidade principal')),
            TextFormField(controller: _preferredAirportController, decoration: const InputDecoration(labelText: 'Aeroporto preferido (GRU, CGH, VCP)')),
            TextFormField(controller: _frequentCitiesController, decoration: const InputDecoration(labelText: 'Cidades frequentes (até 5)')),
            const SizedBox(height: 16),
            const Text('Preferências de Voo', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              value: _flightClass,
              decoration: const InputDecoration(labelText: 'Classe preferida'),
              items: const [
                DropdownMenuItem(value: 'Economy', child: Text('Economy')),
                DropdownMenuItem(value: 'Premium', child: Text('Premium')),
                DropdownMenuItem(value: 'Business', child: Text('Business')),
              ],
              onChanged: (v) => setState(() => _flightClass = v ?? 'Economy'),
            ),
            DropdownButtonFormField<String>(
              value: _seatPref,
              decoration: const InputDecoration(labelText: 'Assento preferido'),
              items: const [
                DropdownMenuItem(value: 'Corredor', child: Text('Corredor')),
                DropdownMenuItem(value: 'Janela', child: Text('Janela')),
                DropdownMenuItem(value: 'Meio', child: Text('Meio')),
              ],
              onChanged: (v) => setState(() => _seatPref = v ?? 'Corredor'),
            ),
            TextFormField(controller: TextEditingController(text: _airline), decoration: const InputDecoration(labelText: 'Companhia aérea preferida')),
            DropdownButtonFormField<String>(
              value: _preferredTime,
              decoration: const InputDecoration(labelText: 'Horário preferencial'),
              items: const [
                DropdownMenuItem(value: 'Manhã', child: Text('Manhã')),
                DropdownMenuItem(value: 'Tarde', child: Text('Tarde')),
                DropdownMenuItem(value: 'Noite', child: Text('Noite')),
              ],
              onChanged: (v) => setState(() => _preferredTime = v ?? 'Manhã'),
            ),
            const SizedBox(height: 16),
            const Text('Informações de Booking', style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(controller: _docController, decoration: const InputDecoration(labelText: 'Documento (CPF/Passaporte)')),
            DropdownButtonFormField<String>(
              value: _title,
              decoration: const InputDecoration(labelText: 'Título'),
              items: const [
                DropdownMenuItem(value: 'Sr.', child: Text('Sr.')),
                DropdownMenuItem(value: 'Sra.', child: Text('Sra.')),
                DropdownMenuItem(value: 'Dr.', child: Text('Dr.')),
                DropdownMenuItem(value: 'Dra.', child: Text('Dra.')),
              ],
              onChanged: (v) => setState(() => _title = v ?? 'Sr.'),
            ),
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: const InputDecoration(labelText: 'Gênero'),
              items: const [
                DropdownMenuItem(value: 'M', child: Text('Masculino')),
                DropdownMenuItem(value: 'F', child: Text('Feminino')),
              ],
              onChanged: (v) => setState(() => _gender = v ?? 'M'),
            ),
            TextFormField(controller: _countryController, decoration: const InputDecoration(labelText: 'País de residência')),
            const SizedBox(height: 16),
            const Text('Contatos de Emergência', style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(controller: _emergency1Controller, decoration: const InputDecoration(labelText: 'Nome e telefone (1)')),
            TextFormField(controller: _emergency2Controller, decoration: const InputDecoration(labelText: 'Nome e telefone (2)')),
          ],
        ),
      ),
    );
  }
}
