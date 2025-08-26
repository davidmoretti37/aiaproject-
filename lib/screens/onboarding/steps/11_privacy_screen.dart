import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../styles.dart';
import 'onboarding_step_layout.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _storeData = true;
  String _retention = '6 meses';
  bool _shareInfo = false;
  bool _backup = true;
  bool _acceptPolicy = false;

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
                const TextSpan(text: 'Privacidade & '),
                TextSpan(
                  text: 'Dados',
                  style: OnboardingStyles.titleStyle.copyWith(
                    color: const Color(0xFF95C5D9),
                  ),
                ),
              ],
            ),
          ).animate().fade(duration: 500.ms).slideX(),
          const SizedBox(height: 10),
          Text(
            'Gerencie como seus dados são armazenados, compartilhados e protegidos.',
            style: OnboardingStyles.subtitleStyle,
          ).animate().fade(duration: 500.ms).slideX(delay: 200.ms),
          const SizedBox(height: 32),
          Form(
            key: _formKey,
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(
                    'Armazenar Meus Dados',
                    style: OnboardingStyles.subtitleStyle,
                  ),
                  value: _storeData,
                  onChanged: (v) => setState(() => _storeData = v),
                  activeColor: const Color(0xFF95C5D9),
                  inactiveTrackColor: const Color(0xFFEBF2F5),
                ).animate().fade(duration: 500.ms).slideX(delay: 400.ms),
                const SizedBox(height: 22),
                DropdownButtonFormField<String>(
                  value: _retention,
                  decoration: OnboardingStyles.inputDecoration('Período de Retenção'),
                  items: const [
                    DropdownMenuItem(value: '3 meses', child: Text('3 meses')),
                    DropdownMenuItem(value: '6 meses', child: Text('6 meses')),
                    DropdownMenuItem(value: '1 ano', child: Text('1 ano')),
                    DropdownMenuItem(value: 'Indefinido', child: Text('Indefinido')),
                  ],
                  onChanged: (v) => setState(() => _retention = v ?? '6 meses'),
                ).animate().fade(duration: 500.ms).slideX(delay: 500.ms),
                const SizedBox(height: 22),
                SwitchListTile(
                  title: Text(
                    'Permitir Compartilhamento de Informações',
                    style: OnboardingStyles.subtitleStyle,
                  ),
                  value: _shareInfo,
                  onChanged: (v) => setState(() => _shareInfo = v),
                  activeColor: const Color(0xFF95C5D9),
                  inactiveTrackColor: const Color(0xFFEBF2F5),
                ).animate().fade(duration: 500.ms).slideX(delay: 600.ms),
                const SizedBox(height: 22),
                SwitchListTile(
                  title: Text(
                    'Backup de Configurações',
                    style: OnboardingStyles.subtitleStyle,
                  ),
                  value: _backup,
                  onChanged: (v) => setState(() => _backup = v),
                  activeColor: const Color(0xFF95C5D9),
                  inactiveTrackColor: const Color(0xFFEBF2F5),
                ).animate().fade(duration: 500.ms).slideX(delay: 700.ms),
                const SizedBox(height: 22),
                CheckboxListTile(
                  title: Text(
                    'Li e Aceito a Política de Privacidade',
                    style: OnboardingStyles.subtitleStyle,
                  ),
                  value: _acceptPolicy,
                  onChanged: (v) => setState(() => _acceptPolicy = v ?? false),
                  activeColor: const Color(0xFF95C5D9),
                ).animate().fade(duration: 500.ms).slideX(delay: 800.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
