import 'package:flutter/material.dart';

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
                text: 'Lembretes',
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
          'Defina como e quando deseja ser lembrado de seus compromissos.',
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
              const Text('Tipos de lembrete preferidos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF6B6B6B))),
              const SizedBox(height: 16),
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
              const SizedBox(height: 32),
              const Text('Antecedência padrão', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF6B6B6B))),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _importantLead,
                decoration: _inputDecoration.copyWith(labelText: 'Eventos importantes'),
                items: const [
                  DropdownMenuItem(value: '1 semana', child: Text('1 semana')),
                  DropdownMenuItem(value: '1 dia', child: Text('1 dia')),
                  DropdownMenuItem(value: '1 hora', child: Text('1 hora')),
                ],
                onChanged: (v) => setState(() => _importantLead = v ?? '1 semana'),
              ),
              const SizedBox(height: 22),
              DropdownButtonFormField<String>(
                value: _personalLead,
                decoration: _inputDecoration.copyWith(labelText: 'Compromissos pessoais'),
                items: const [
                  DropdownMenuItem(value: '1 dia', child: Text('1 dia')),
                  DropdownMenuItem(value: '2 horas', child: Text('2 horas')),
                ],
                onChanged: (v) => setState(() => _personalLead = v ?? '1 dia'),
              ),
              const SizedBox(height: 22),
              DropdownButtonFormField<String>(
                value: _simpleLead,
                decoration: _inputDecoration.copyWith(labelText: 'Tarefas simples'),
                items: const [
                  DropdownMenuItem(value: '30 min', child: Text('30 min')),
                  DropdownMenuItem(value: '1 hora', child: Text('1 hora')),
                ],
                onChanged: (v) => setState(() => _simpleLead = v ?? '30 min'),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _allowedTimesController,
                decoration: _inputDecoration.copyWith(labelText: 'Horários permitidos para notificações'),
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: _categoriesController,
                decoration: _inputDecoration.copyWith(labelText: 'Categorias personalizadas'),
              ),
              const SizedBox(height: 22),
            ],
          ),
        ),
      ],
    );
  }
}
