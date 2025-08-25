import 'package:flutter/material.dart';
import 'onboarding_step_layout.dart';

class CalendarAgentScreen extends StatefulWidget {
  const CalendarAgentScreen({Key? key}) : super(key: key);

  @override
  State<CalendarAgentScreen> createState() => _CalendarAgentScreenState();
}

class _CalendarAgentScreenState extends State<CalendarAgentScreen> {
  final _formKey = GlobalKey<FormState>();
  String _googleAccount = '';
  String _mainCalendar = '';
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
      title: 'Configurações de Agenda',
      description: 'Conecte sua conta Google e defina suas preferências de calendário.',
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Conta Google conectada'),
              onChanged: (v) => _googleAccount = v,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Calendário principal'),
              onChanged: (v) => _mainCalendar = v,
            ),
            const SizedBox(height: 16),
            const Text('Horário de trabalho', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Início: ${_workStart.format(context)}'),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _workStart,
                      );
                      if (picked != null) setState(() => _workStart = picked);
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Fim: ${_workEnd.format(context)}'),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _workEnd,
                      );
                      if (picked != null) setState(() => _workEnd = picked);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final day in ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'])
                  FilterChip(
                    label: Text(day),
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
                  ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _meetingDuration,
              decoration: const InputDecoration(labelText: 'Duração padrão de reuniões'),
              items: const [
                DropdownMenuItem(value: '30min', child: Text('30min')),
                DropdownMenuItem(value: '1h', child: Text('1h')),
              ],
              onChanged: (v) => setState(() => _meetingDuration = v ?? '1h'),
            ),
            DropdownButtonFormField<String>(
              value: _buffer,
              decoration: const InputDecoration(labelText: 'Buffer entre reuniões'),
              items: const [
                DropdownMenuItem(value: '0', child: Text('0')),
                DropdownMenuItem(value: '15min', child: Text('15min')),
                DropdownMenuItem(value: '30min', child: Text('30min')),
              ],
              onChanged: (v) => setState(() => _buffer = v ?? '15min'),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Local de trabalho padrão'),
              onChanged: (v) => _workLocation = v,
            ),
            DropdownButtonFormField<String>(
              value: _virtualPref,
              decoration: const InputDecoration(labelText: 'Preferência para reuniões virtuais'),
              items: const [
                DropdownMenuItem(value: 'Sempre', child: Text('Sempre')),
                DropdownMenuItem(value: 'Às vezes', child: Text('Às vezes')),
                DropdownMenuItem(value: 'Nunca', child: Text('Nunca')),
              ],
              onChanged: (v) => setState(() => _virtualPref = v ?? 'Sempre'),
            ),
            TextFormField(
              controller: _frequentContactsController,
              decoration: const InputDecoration(labelText: 'Contatos frequentes (emails)'),
            ),
          ],
        ),
      ),
    );
  }
}
