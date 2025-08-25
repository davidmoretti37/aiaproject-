import 'package:flutter/material.dart';
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
      title: 'Configurações de Lembretes',
      description: 'Defina como e quando deseja ser lembrado de seus compromissos.',
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const Text('Tipos de lembrete preferidos', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: _allTypes.map((type) {
                return FilterChip(
                  label: Text(type),
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
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Antecedência padrão', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              value: _importantLead,
              decoration: const InputDecoration(labelText: 'Eventos importantes'),
              items: const [
                DropdownMenuItem(value: '1 semana', child: Text('1 semana')),
                DropdownMenuItem(value: '1 dia', child: Text('1 dia')),
                DropdownMenuItem(value: '1 hora', child: Text('1 hora')),
              ],
              onChanged: (v) => setState(() => _importantLead = v ?? '1 semana'),
            ),
            DropdownButtonFormField<String>(
              value: _personalLead,
              decoration: const InputDecoration(labelText: 'Compromissos pessoais'),
              items: const [
                DropdownMenuItem(value: '1 dia', child: Text('1 dia')),
                DropdownMenuItem(value: '2 horas', child: Text('2 horas')),
              ],
              onChanged: (v) => setState(() => _personalLead = v ?? '1 dia'),
            ),
            DropdownButtonFormField<String>(
              value: _simpleLead,
              decoration: const InputDecoration(labelText: 'Tarefas simples'),
              items: const [
                DropdownMenuItem(value: '30 min', child: Text('30 min')),
                DropdownMenuItem(value: '1 hora', child: Text('1 hora')),
              ],
              onChanged: (v) => setState(() => _simpleLead = v ?? '30 min'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _allowedTimesController,
              decoration: const InputDecoration(labelText: 'Horários permitidos para notificações'),
            ),
            TextFormField(
              controller: _categoriesController,
              decoration: const InputDecoration(labelText: 'Categorias personalizadas'),
            ),
          ],
        ),
      ),
    );
  }
}
