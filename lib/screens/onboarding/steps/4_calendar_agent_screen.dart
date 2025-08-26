import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../styles.dart';
import 'onboarding_step_layout.dart';

class CalendarAgentScreen extends StatefulWidget {
  const CalendarAgentScreen({Key? key}) : super(key: key);

  @override
  State<CalendarAgentScreen> createState() => _CalendarAgentScreenState();
}

class _CalendarAgentScreenState extends State<CalendarAgentScreen> {
  final _formKey = GlobalKey<FormState>();
  TimeOfDay _workStart = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _workEnd = const TimeOfDay(hour: 18, minute: 0);
  List<String> _workDays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex'];
  String _meetingDuration = '1h';
  String _buffer = '15min';
  String _workLocation = '';
  String _virtualPref = 'Sempre';
  final _frequentContactsController = TextEditingController();

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
                  text: 'Agenda',
                  style: OnboardingStyles.titleStyle.copyWith(
                    color: const Color(0xFF95C5D9),
                  ),
                ),
              ],
            ),
          ).animate().fade(duration: 500.ms).slideX(),
          const SizedBox(height: 10),
          Text(
            'Conecte sua conta Google e defina suas preferências de calendário.',
            style: OnboardingStyles.subtitleStyle,
          ).animate().fade(duration: 500.ms).slideX(delay: 200.ms),
          const SizedBox(height: 32),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jornada de Trabalho',
                  style: OnboardingStyles.subtitleStyle.copyWith(
                    color: const Color(0xFF6B6B6B),
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fade(duration: 500.ms).slideX(delay: 400.ms),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _workStart,
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.light().copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Color(0xFF95C5D9),
                                    onPrimary: Colors.white,
                                    surface: Colors.white,
                                    onSurface: Colors.black,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) setState(() => _workStart = picked);
                        },
                        child: InputDecorator(
                          decoration: OnboardingStyles.inputDecoration('Início'),
                          child: Text(_workStart.format(context)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _workEnd,
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.light().copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Color(0xFF95C5D9),
                                    onPrimary: Colors.white,
                                    surface: Colors.white,
                                    onSurface: Colors.black,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) setState(() => _workEnd = picked);
                        },
                        child: InputDecorator(
                          decoration: OnboardingStyles.inputDecoration('Fim'),
                          child: Text(_workEnd.format(context)),
                        ),
                      ),
                    ),
                  ],
                ).animate().fade(duration: 500.ms).slideX(delay: 500.ms),
                const SizedBox(height: 22),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final day in ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'])
                      FilterChip(
                        label: Text(
                          day,
                          style: TextStyle(
                            fontSize: 12,
                            color: _workDays.contains(day) ? Colors.white : Colors.black,
                          ),
                        ),
                        selected: _workDays.contains(day),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _workDays.add(day);
                            } else {
                              _workDays.remove(day);
                            }
                          });
                        },
                        selectedColor: const Color(0xFF95C5D9),
                        backgroundColor: const Color(0xFFEBF2F5),
                        checkmarkColor: Colors.white,
                      ),
                  ],
                ).animate().fade(duration: 500.ms).slideX(delay: 600.ms),
                const SizedBox(height: 32),
                Text(
                  'Preferências de Reunião',
                  style: OnboardingStyles.subtitleStyle.copyWith(
                    color: const Color(0xFF6B6B6B),
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fade(duration: 500.ms).slideX(delay: 700.ms),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _meetingDuration,
                  decoration: OnboardingStyles.inputDecoration('Duração Padrão'),
                  items: const [
                    DropdownMenuItem(value: '30min', child: Text('30min')),
                    DropdownMenuItem(value: '1h', child: Text('1h')),
                  ],
                  onChanged: (v) => setState(() => _meetingDuration = v ?? '1h'),
                ).animate().fade(duration: 500.ms).slideX(delay: 800.ms),
                const SizedBox(height: 22),
                DropdownButtonFormField<String>(
                  value: _buffer,
                  decoration: OnboardingStyles.inputDecoration('Buffer Entre Reuniões'),
                  items: const [
                    DropdownMenuItem(value: '0', child: Text('0')),
                    DropdownMenuItem(value: '15min', child: Text('15min')),
                    DropdownMenuItem(value: '30min', child: Text('30min')),
                  ],
                  onChanged: (v) => setState(() => _buffer = v ?? '15min'),
                ).animate().fade(duration: 500.ms).slideX(delay: 900.ms),
                const SizedBox(height: 22),
                TextFormField(
                  decoration: OnboardingStyles.inputDecoration('Local de Trabalho Padrão'),
                  onChanged: (v) => _workLocation = v,
                ).animate().fade(duration: 500.ms).slideX(delay: 1000.ms),
                const SizedBox(height: 22),
                DropdownButtonFormField<String>(
                  value: _virtualPref,
                  decoration: OnboardingStyles.inputDecoration('Preferência para Reuniões Virtuais'),
                  items: const [
                    DropdownMenuItem(value: 'Sempre', child: Text('Sempre')),
                    DropdownMenuItem(value: 'Às vezes', child: Text('Às vezes')),
                    DropdownMenuItem(value: 'Nunca', child: Text('Nunca')),
                  ],
                  onChanged: (v) => setState(() => _virtualPref = v ?? 'Sempre'),
                ).animate().fade(duration: 500.ms).slideX(delay: 1100.ms),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _frequentContactsController,
                  decoration: OnboardingStyles.inputDecoration('Contatos Frequentes (emails)'),
                ).animate().fade(duration: 500.ms).slideX(delay: 1200.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
