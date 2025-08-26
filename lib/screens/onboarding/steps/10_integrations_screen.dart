import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../styles.dart';
import 'onboarding_step_layout.dart';

class IntegrationsScreen extends StatefulWidget {
  const IntegrationsScreen({Key? key}) : super(key: key);

  @override
  State<IntegrationsScreen> createState() => _IntegrationsScreenState();
}

class _IntegrationsScreenState extends State<IntegrationsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _googleConnected = false;
  bool _whatsappConnected = false;
  bool _latamConnected = false;
  bool _smilesConnected = false;

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
                const TextSpan(text: 'Tela de '),
                TextSpan(
                  text: 'Integrações',
                  style: OnboardingStyles.titleStyle.copyWith(
                    color: const Color(0xFF95C5D9),
                  ),
                ),
              ],
            ),
          ).animate().fade(duration: 500.ms).slideX(),
          const SizedBox(height: 10),
          Text(
            'Conecte suas contas e serviços para uma experiência completa.',
            style: OnboardingStyles.subtitleStyle,
          ).animate().fade(duration: 500.ms).slideX(delay: 200.ms),
          const SizedBox(height: 32),
          Form(
            key: _formKey,
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(
                    'Google Account (Calendar, Gmail)',
                    style: OnboardingStyles.subtitleStyle,
                  ),
                  value: _googleConnected,
                  onChanged: (v) => setState(() => _googleConnected = v),
                  activeColor: const Color(0xFF95C5D9),
                ).animate().fade(duration: 500.ms).slideX(delay: 400.ms),
                SwitchListTile(
                  title: Text(
                    'WhatsApp Business API',
                    style: OnboardingStyles.subtitleStyle,
                  ),
                  value: _whatsappConnected,
                  onChanged: (v) => setState(() => _whatsappConnected = v),
                  activeColor: const Color(0xFF95C5D9),
                ).animate().fade(duration: 500.ms).slideX(delay: 500.ms),
                SwitchListTile(
                  title: Text(
                    'LATAM Pass',
                    style: OnboardingStyles.subtitleStyle,
                  ),
                  value: _latamConnected,
                  onChanged: (v) => setState(() => _latamConnected = v),
                  activeColor: const Color(0xFF95C5D9),
                ).animate().fade(duration: 500.ms).slideX(delay: 600.ms),
                SwitchListTile(
                  title: Text(
                    'Smiles/GOL',
                    style: OnboardingStyles.subtitleStyle,
                  ),
                  value: _smilesConnected,
                  onChanged: (v) => setState(() => _smilesConnected = v),
                  activeColor: const Color(0xFF95C5D9),
                ).animate().fade(duration: 500.ms).slideX(delay: 700.ms),
                // Adicione mais integrações conforme necessário
              ],
            ),
          ),
        ],
      ),
    );
  }
}
