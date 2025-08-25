import 'package:flutter/material.dart';

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
              const TextSpan(text: 'Configurações de '),
              TextSpan(
                text: 'Viagem',
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
          'Personalize suas preferências de viagem e programas de fidelidade.',
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
              const Text('Programas de Fidelidade', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF6B6B6B))),
              const SizedBox(height: 16),
              TextFormField(controller: _latamController, decoration: _inputDecoration.copyWith(labelText: 'LATAM Pass (número)')),
              const SizedBox(height: 22),
              TextFormField(controller: _smilesController, decoration: _inputDecoration.copyWith(labelText: 'Smiles/GOL (número)')),
              const SizedBox(height: 22),
              TextFormField(controller: _azulController, decoration: _inputDecoration.copyWith(labelText: 'TudoAzul/Azul (número)')),
              const SizedBox(height: 22),
              TextFormField(controller: _lifemilesController, decoration: _inputDecoration.copyWith(labelText: 'LifeMiles/Avianca (número)')),
              const SizedBox(height: 32),
              const Text('Aeroportos Preferenciais', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF6B6B6B))),
              const SizedBox(height: 16),
              TextFormField(controller: _mainCityController, decoration: _inputDecoration.copyWith(labelText: 'Cidade principal')),
              const SizedBox(height: 22),
              TextFormField(controller: _preferredAirportController, decoration: _inputDecoration.copyWith(labelText: 'Aeroporto preferido (GRU, CGH, VCP)')),
              const SizedBox(height: 22),
              TextFormField(controller: _frequentCitiesController, decoration: _inputDecoration.copyWith(labelText: 'Cidades frequentes (até 5)')),
              const SizedBox(height: 32),
              const Text('Preferências de Voo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF6B6B6B))),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _flightClass,
                decoration: _inputDecoration.copyWith(labelText: 'Classe preferida'),
                items: const [
                  DropdownMenuItem(value: 'Economy', child: Text('Economy')),
                  DropdownMenuItem(value: 'Premium', child: Text('Premium')),
                  DropdownMenuItem(value: 'Business', child: Text('Business')),
                ],
                onChanged: (v) => setState(() => _flightClass = v ?? 'Economy'),
              ),
              const SizedBox(height: 22),
              DropdownButtonFormField<String>(
                value: _seatPref,
                decoration: _inputDecoration.copyWith(labelText: 'Assento preferido'),
                items: const [
                  DropdownMenuItem(value: 'Corredor', child: Text('Corredor')),
                  DropdownMenuItem(value: 'Janela', child: Text('Janela')),
                  DropdownMenuItem(value: 'Meio', child: Text('Meio')),
                ],
                onChanged: (v) => setState(() => _seatPref = v ?? 'Corredor'),
              ),
              const SizedBox(height: 22),
              TextFormField(controller: TextEditingController(text: _airline), decoration: _inputDecoration.copyWith(labelText: 'Companhia aérea preferida')),
              const SizedBox(height: 22),
              DropdownButtonFormField<String>(
                value: _preferredTime,
                decoration: _inputDecoration.copyWith(labelText: 'Horário preferencial'),
                items: const [
                  DropdownMenuItem(value: 'Manhã', child: Text('Manhã')),
                  DropdownMenuItem(value: 'Tarde', child: Text('Tarde')),
                  DropdownMenuItem(value: 'Noite', child: Text('Noite')),
                ],
                onChanged: (v) => setState(() => _preferredTime = v ?? 'Manhã'),
              ),
              const SizedBox(height: 32),
              const Text('Informações de Booking', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF6B6B6B))),
              const SizedBox(height: 16),
              TextFormField(controller: _docController, decoration: _inputDecoration.copyWith(labelText: 'Documento (CPF/Passaporte)')),
              const SizedBox(height: 22),
              DropdownButtonFormField<String>(
                value: _title,
                decoration: _inputDecoration.copyWith(labelText: 'Título'),
                items: const [
                  DropdownMenuItem(value: 'Sr.', child: Text('Sr.')),
                  DropdownMenuItem(value: 'Sra.', child: Text('Sra.')),
                  DropdownMenuItem(value: 'Dr.', child: Text('Dr.')),
                  DropdownMenuItem(value: 'Dra.', child: Text('Dra.')),
                ],
                onChanged: (v) => setState(() => _title = v ?? 'Sr.'),
              ),
              const SizedBox(height: 22),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: _inputDecoration.copyWith(labelText: 'Gênero'),
                items: const [
                  DropdownMenuItem(value: 'M', child: Text('Masculino')),
                  DropdownMenuItem(value: 'F', child: Text('Feminino')),
                ],
                onChanged: (v) => setState(() => _gender = v ?? 'M'),
              ),
              const SizedBox(height: 22),
              TextFormField(controller: _countryController, decoration: _inputDecoration.copyWith(labelText: 'País de residência')),
              const SizedBox(height: 32),
              const Text('Contatos de Emergência', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF6B6B6B))),
              const SizedBox(height: 16),
              TextFormField(controller: _emergency1Controller, decoration: _inputDecoration.copyWith(labelText: 'Nome e telefone (1)')),
              const SizedBox(height: 22),
              TextFormField(controller: _emergency2Controller, decoration: _inputDecoration.copyWith(labelText: 'Nome e telefone (2)')),
              const SizedBox(height: 22),
            ],
          ),
        ),
      ],
    );
  }
}
