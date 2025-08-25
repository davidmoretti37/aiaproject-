import 'package:flutter/material.dart';
import 'onboarding_step_layout.dart';

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

  @override
  Widget build(BuildContext context) {
    return OnboardingStepLayout(
      title: 'Informações Veiculares',
      description: 'Cadastre seus veículos e preferências de notificação.',
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(controller: _plateController, decoration: const InputDecoration(labelText: 'Placa (ex: ABC1234)')),
            TextFormField(controller: _brandModelYearController, decoration: const InputDecoration(labelText: 'Marca/Modelo/Ano')),
            TextFormField(controller: _colorController, decoration: const InputDecoration(labelText: 'Cor')),
            TextFormField(controller: _renavamController, decoration: const InputDecoration(labelText: 'RENAVAM')),
            TextFormField(controller: _nicknameController, decoration: const InputDecoration(labelText: 'Apelido do veículo (opcional)')),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Estado de registro'),
              onChanged: (v) => _state = v,
            ),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Categoria'),
              items: const [
                DropdownMenuItem(value: 'Carro', child: Text('Carro')),
                DropdownMenuItem(value: 'Moto', child: Text('Moto')),
                DropdownMenuItem(value: 'Caminhão', child: Text('Caminhão')),
              ],
              onChanged: (v) => setState(() => _category = v ?? 'Carro'),
            ),
            DropdownButtonFormField<String>(
              value: _mainUse,
              decoration: const InputDecoration(labelText: 'Uso principal'),
              items: const [
                DropdownMenuItem(value: 'Pessoal', child: Text('Pessoal')),
                DropdownMenuItem(value: 'Trabalho', child: Text('Trabalho')),
                DropdownMenuItem(value: 'Compartilhado', child: Text('Compartilhado')),
              ],
              onChanged: (v) => setState(() => _mainUse = v ?? 'Pessoal'),
            ),
            const SizedBox(height: 16),
            const Text('Preferências de Alertas', style: TextStyle(fontWeight: FontWeight.bold)),
            SwitchListTile(
              title: const Text('Receber alertas de vencimento'),
              value: _alerts,
              onChanged: (v) => setState(() => _alerts = v),
            ),
            DropdownButtonFormField<String>(
              value: _alertFrequency,
              decoration: const InputDecoration(labelText: 'Frequência de verificação automática'),
              items: const [
                DropdownMenuItem(value: 'Semanal', child: Text('Semanal')),
                DropdownMenuItem(value: 'Mensal', child: Text('Mensal')),
                DropdownMenuItem(value: 'Trimestral', child: Text('Trimestral')),
              ],
              onChanged: (v) => setState(() => _alertFrequency = v ?? 'Mensal'),
            ),
            SwitchListTile(
              title: const Text('Notificar sobre multas novas'),
              value: _notifyFines,
              onChanged: (v) => setState(() => _notifyFines = v),
            ),
          ],
        ),
      ),
    );
  }
}
