import 'package:flutter/material.dart';

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
                text: 'Agenda',
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
          'Conecte sua conta Google e defina suas preferências de calendário.',
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
              TextFormField(
                decoration: _inputDecoration.copyWith(labelText: 'Conta Google conectada'),
                onChanged: (v) => _googleAccount = v,
              ),
              const SizedBox(height: 22),
              TextFormField(
                decoration: _inputDecoration.copyWith(labelText: 'Calendário principal'),
                onChanged: (v) => _mainCalendar = v,
              ),
              const SizedBox(height: 32),
              const Text('Horário de trabalho', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF6B6B6B))),
              const SizedBox(height: 16),
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
              const SizedBox(height: 22),
              DropdownButtonFormField<String>(
                value: _meetingDuration,
                decoration: _inputDecoration.copyWith(labelText: 'Duração padrão de reuniões'),
                items: const [
                  DropdownMenuItem(value: '30min', child: Text('30min')),
                  DropdownMenuItem(value: '1h', child: Text('1h')),
                ],
                onChanged: (v) => setState(() => _meetingDuration = v ?? '1h'),
              ),
              const SizedBox(height: 22),
              DropdownButtonFormField<String>(
                value: _buffer,
                decoration: _inputDecoration.copyWith(labelText: 'Buffer entre reuniões'),
                items: const [
                  DropdownMenuItem(value: '0', child: Text('0')),
                  DropdownMenuItem(value: '15min', child: Text('15min')),
                  DropdownMenuItem(value: '30min', child: Text('30min')),
                ],
                onChanged: (v) => setState(() => _buffer = v ?? '15min'),
              ),
              const SizedBox(height: 22),
              TextFormField(
                decoration: _inputDecoration.copyWith(labelText: 'Local de trabalho padrão'),
                onChanged: (v) => _workLocation = v,
              ),
              const SizedBox(height: 22),
              DropdownButtonFormField<String>(
                value: _virtualPref,
                decoration: _inputDecoration.copyWith(labelText: 'Preferência para reuniões virtuais'),
                items: const [
                  DropdownMenuItem(value: 'Sempre', child: Text('Sempre')),
                  DropdownMenuItem(value: 'Às vezes', child: Text('Às vezes')),
                  DropdownMenuItem(value: 'Nunca', child: Text('Nunca')),
                ],
                onChanged: (v) => setState(() => _virtualPref = v ?? 'Sempre'),
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: _frequentContactsController,
                decoration: _inputDecoration.copyWith(labelText: 'Contatos frequentes (emails)'),
              ),
              const SizedBox(height: 22),
            ],
          ),
        ),
      ],
    );
  }
}
