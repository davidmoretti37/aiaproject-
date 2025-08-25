import 'package:flutter/material.dart';

class VehicleAgentScreen extends StatefulWidget {
  const VehicleAgentScreen({Key? key}) : super(key: key);

  @override
  State<VehicleAgentScreen> createState() => _VehicleAgentScreenState();
}

class _VehicleAgentScreenState extends State<VehicleAgentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _plateController = TextEditingController();
  final _brandModelYearController = TextEditingController();
  final _colorController = TextEditingController();
  final _renavamController = TextEditingController();
  final _nicknameController = TextEditingController();
  String _state = '';
  String _category = 'Carro';
  String _mainUse = 'Pessoal';
  bool _alerts = true;
  String _alertFrequency = 'Mensal';
  bool _notifyFines = true;

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
              const TextSpan(text: 'Informações '),
              TextSpan(
                text: 'Veiculares',
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
          'Cadastre seus veículos e preferências de notificação.',
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
              TextFormField(controller: _plateController, decoration: _inputDecoration.copyWith(labelText: 'Placa (ex: ABC1234)')),
              const SizedBox(height: 22),
              TextFormField(controller: _brandModelYearController, decoration: _inputDecoration.copyWith(labelText: 'Marca/Modelo/Ano')),
              const SizedBox(height: 22),
              TextFormField(controller: _colorController, decoration: _inputDecoration.copyWith(labelText: 'Cor')),
              const SizedBox(height: 22),
              TextFormField(controller: _renavamController, decoration: _inputDecoration.copyWith(labelText: 'RENAVAM')),
              const SizedBox(height: 22),
              TextFormField(controller: _nicknameController, decoration: _inputDecoration.copyWith(labelText: 'Apelido do veículo (opcional)')),
              const SizedBox(height: 22),
              TextFormField(
                decoration: _inputDecoration.copyWith(labelText: 'Estado de registro'),
                onChanged: (v) => _state = v,
              ),
              const SizedBox(height: 22),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: _inputDecoration.copyWith(labelText: 'Categoria'),
                items: const [
                  DropdownMenuItem(value: 'Carro', child: Text('Carro')),
                  DropdownMenuItem(value: 'Moto', child: Text('Moto')),
                  DropdownMenuItem(value: 'Caminhão', child: Text('Caminhão')),
                ],
                onChanged: (v) => setState(() => _category = v ?? 'Carro'),
              ),
              const SizedBox(height: 22),
              DropdownButtonFormField<String>(
                value: _mainUse,
                decoration: _inputDecoration.copyWith(labelText: 'Uso principal'),
                items: const [
                  DropdownMenuItem(value: 'Pessoal', child: Text('Pessoal')),
                  DropdownMenuItem(value: 'Trabalho', child: Text('Trabalho')),
                  DropdownMenuItem(value: 'Compartilhado', child: Text('Compartilhado')),
                ],
                onChanged: (v) => setState(() => _mainUse = v ?? 'Pessoal'),
              ),
              const SizedBox(height: 32),
              const Text('Preferências de Alertas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF6B6B6B))),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Receber alertas de vencimento'),
                value: _alerts,
                onChanged: (v) => setState(() => _alerts = v),
              ),
              const SizedBox(height: 22),
              DropdownButtonFormField<String>(
                value: _alertFrequency,
                decoration: _inputDecoration.copyWith(labelText: 'Frequência de verificação automática'),
                items: const [
                  DropdownMenuItem(value: 'Semanal', child: Text('Semanal')),
                  DropdownMenuItem(value: 'Mensal', child: Text('Mensal')),
                  DropdownMenuItem(value: 'Trimestral', child: Text('Trimestral')),
                ],
                onChanged: (v) => setState(() => _alertFrequency = v ?? 'Mensal'),
              ),
              const SizedBox(height: 22),
              SwitchListTile(
                title: const Text('Notificar sobre multas novas'),
                value: _notifyFines,
                onChanged: (v) => setState(() => _notifyFines = v),
              ),
              const SizedBox(height: 22),
            ],
          ),
        ),
      ],
    );
  }
}
