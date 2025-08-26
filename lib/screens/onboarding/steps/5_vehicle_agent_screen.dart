import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../styles.dart';
import 'onboarding_step_layout.dart';

class VehicleAgentScreen extends StatefulWidget {
  const VehicleAgentScreen({Key? key}) : super(key: key);

  @override
  State<VehicleAgentScreen> createState() => _VehicleAgentScreenState();
}

class _VehicleAgentScreenState extends State<VehicleAgentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _plateController = TextEditingController();
  final _nicknameController = TextEditingController();
  String _category = 'Carro';
  String _mainUse = 'Pessoal';
  bool _alerts = true;
  String _alertFrequency = 'Mensal';
  bool _notifyFines = true;

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
                const TextSpan(text: 'Informações '),
                TextSpan(
                  text: 'Veiculares',
                  style: OnboardingStyles.titleStyle.copyWith(
                    color: const Color(0xFF95C5D9),
                  ),
                ),
              ],
            ),
          ).animate().fade(duration: 500.ms).slideX(),
          const SizedBox(height: 10),
          Text(
            'Cadastre seus veículos e preferências de notificação.',
            style: OnboardingStyles.subtitleStyle,
          ).animate().fade(duration: 500.ms).slideX(delay: 200.ms),
          const SizedBox(height: 32),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _plateController,
                  decoration: OnboardingStyles.inputDecoration('Placa (ex: ABC1234)'),
                ).animate().fade(duration: 500.ms).slideX(delay: 400.ms),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _nicknameController,
                  decoration: OnboardingStyles.inputDecoration('Apelido do Veículo (opcional)'),
                ).animate().fade(duration: 500.ms).slideX(delay: 500.ms),
                const SizedBox(height: 22),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: OnboardingStyles.inputDecoration('Categoria'),
                  items: const [
                    DropdownMenuItem(value: 'Carro', child: Text('Carro')),
                    DropdownMenuItem(value: 'Moto', child: Text('Moto')),
                    DropdownMenuItem(value: 'Caminhão', child: Text('Caminhão')),
                  ],
                  onChanged: (v) => setState(() => _category = v ?? 'Carro'),
                ).animate().fade(duration: 500.ms).slideX(delay: 600.ms),
                const SizedBox(height: 22),
                DropdownButtonFormField<String>(
                  value: _mainUse,
                  decoration: OnboardingStyles.inputDecoration('Uso Principal'),
                  items: const [
                    DropdownMenuItem(value: 'Pessoal', child: Text('Pessoal')),
                    DropdownMenuItem(value: 'Trabalho', child: Text('Trabalho')),
                    DropdownMenuItem(value: 'Compartilhado', child: Text('Compartilhado')),
                  ],
                  onChanged: (v) => setState(() => _mainUse = v ?? 'Pessoal'),
                ).animate().fade(duration: 500.ms).slideX(delay: 700.ms),
                const SizedBox(height: 32),
                Text(
                  'Preferências de Alertas',
                  style: OnboardingStyles.subtitleStyle.copyWith(
                    color: const Color(0xFF6B6B6B),
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fade(duration: 500.ms).slideX(delay: 800.ms),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text(
                    'Receber Alertas de Vencimento',
                    style: OnboardingStyles.subtitleStyle,
                  ),
                  value: _alerts,
                  onChanged: (v) => setState(() => _alerts = v),
                  activeColor: const Color(0xFF95C5D9),
                ).animate().fade(duration: 500.ms).slideX(delay: 900.ms),
                const SizedBox(height: 22),
                DropdownButtonFormField<String>(
                  value: _alertFrequency,
                  decoration: OnboardingStyles.inputDecoration('Frequência de Verificação Automática'),
                  items: const [
                    DropdownMenuItem(value: 'Semanal', child: Text('Semanal')),
                    DropdownMenuItem(value: 'Mensal', child: Text('Mensal')),
                    DropdownMenuItem(value: 'Trimestral', child: Text('Trimestral')),
                  ],
                  onChanged: (v) => setState(() => _alertFrequency = v ?? 'Mensal'),
                ).animate().fade(duration: 500.ms).slideX(delay: 1000.ms),
                const SizedBox(height: 22),
                SwitchListTile(
                  title: Text(
                    'Notificar Sobre Multas Novas',
                    style: OnboardingStyles.subtitleStyle,
                  ),
                  value: _notifyFines,
                  onChanged: (v) => setState(() => _notifyFines = v),
                  activeColor: const Color(0xFF95C5D9),
                ).animate().fade(duration: 500.ms).slideX(delay: 1100.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
