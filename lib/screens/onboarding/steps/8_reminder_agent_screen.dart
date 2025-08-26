import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../styles.dart';
import 'onboarding_step_layout.dart';

class ReminderAgentScreen extends StatefulWidget {
  const ReminderAgentScreen({Key? key}) : super(key: key);

  @override
  State<ReminderAgentScreen> createState() => _ReminderAgentScreenState();
}

class _ReminderAgentScreenState extends State<ReminderAgentScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _reminderTypes = [];
  final List<String> _allTypes = ['Push notification', 'Email', 'SMS'];
  String _importantLead = '1 semana';
  String _personalLead = '1 dia';
  String _simpleLead = '30 min';
  final _allowedTimesController = TextEditingController();
  final _categoriesController = TextEditingController();

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
                  text: 'Lembretes',
                  style: OnboardingStyles.titleStyle.copyWith(
                    color: const Color(0xFF95C5D9),
                  ),
                ),
              ],
            ),
          ).animate().fade(duration: 500.ms).slideX(),
          const SizedBox(height: 10),
          Text(
            'Defina como e quando deseja ser lembrado de seus compromissos.',
            style: OnboardingStyles.subtitleStyle,
          ).animate().fade(duration: 500.ms).slideX(delay: 200.ms),
          const SizedBox(height: 32),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tipos de Lembrete Preferidos',
                  style: OnboardingStyles.subtitleStyle.copyWith(
                    color: const Color(0xFF6B6B6B),
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fade(duration: 500.ms).slideX(delay: 400.ms),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: _allTypes.map((type) {
                    return FilterChip(
                      label: Text(
                        type,
                        style: TextStyle(
                          color: _reminderTypes.contains(type) ? Colors.white : Colors.black,
                        ),
                      ),
                      selected: _reminderTypes.contains(type),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _reminderTypes.add(type);
                          } else {
                            _reminderTypes.remove(type);
                          }
                        });
                      },
                      selectedColor: const Color(0xFF95C5D9),
                      backgroundColor: const Color(0xFFEBF2F5),
                      checkmarkColor: Colors.white,
                    );
                  }).toList(),
                ).animate().fade(duration: 500.ms).slideX(delay: 500.ms),
                const SizedBox(height: 32),
                Text(
                  'Antecedência Padrão',
                  style: OnboardingStyles.subtitleStyle.copyWith(
                    color: const Color(0xFF6B6B6B),
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fade(duration: 500.ms).slideX(delay: 600.ms),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _importantLead,
                  decoration: OnboardingStyles.inputDecoration('Eventos Importantes'),
                  items: const [
                    DropdownMenuItem(value: '1 semana', child: Text('1 semana')),
                    DropdownMenuItem(value: '1 dia', child: Text('1 dia')),
                    DropdownMenuItem(value: '1 hora', child: Text('1 hora')),
                  ],
                  onChanged: (v) => setState(() => _importantLead = v ?? '1 semana'),
                ).animate().fade(duration: 500.ms).slideX(delay: 700.ms),
                const SizedBox(height: 22),
                DropdownButtonFormField<String>(
                  value: _personalLead,
                  decoration: OnboardingStyles.inputDecoration('Compromissos Pessoais'),
                  items: const [
                    DropdownMenuItem(value: '1 dia', child: Text('1 dia')),
                    DropdownMenuItem(value: '2 horas', child: Text('2 horas')),
                  ],
                  onChanged: (v) => setState(() => _personalLead = v ?? '1 dia'),
                ).animate().fade(duration: 500.ms).slideX(delay: 800.ms),
                const SizedBox(height: 22),
                DropdownButtonFormField<String>(
                  value: _simpleLead,
                  decoration: OnboardingStyles.inputDecoration('Tarefas Simples'),
                  items: const [
                    DropdownMenuItem(value: '30 min', child: Text('30 min')),
                    DropdownMenuItem(value: '1 hora', child: Text('1 hora')),
                  ],
                  onChanged: (v) => setState(() => _simpleLead = v ?? '30 min'),
                ).animate().fade(duration: 500.ms).slideX(delay: 900.ms),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _allowedTimesController,
                  decoration: OnboardingStyles.inputDecoration('Horários Permitidos para Notificações'),
                ).animate().fade(duration: 500.ms).slideX(delay: 1000.ms),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _categoriesController,
                  decoration: OnboardingStyles.inputDecoration('Categorias Personalizadas'),
                ).animate().fade(duration: 500.ms).slideX(delay: 1100.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
