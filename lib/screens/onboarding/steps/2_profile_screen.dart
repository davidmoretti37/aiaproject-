import 'package:flutter/material.dart';
import 'onboarding_step_layout.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _birthDate;
  String _timezone = 'America/Sao_Paulo';
  String _language = 'PT';

  @override
  Widget build(BuildContext context) {
    return OnboardingStepLayout(
      title: 'Perfil Básico',
      description: 'Preencha suas informações essenciais para personalizar sua experiência.',
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome completo'),
              validator: (v) => v == null || v.isEmpty ? 'Informe seu nome' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email principal'),
              keyboardType: TextInputType.emailAddress,
              validator: (v) => v == null || v.isEmpty ? 'Informe seu email' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Telefone'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_birthDate == null
                  ? 'Data de nascimento'
                  : 'Data de nascimento: ${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime(2000, 1, 1),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _birthDate = picked);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _timezone,
              decoration: const InputDecoration(labelText: 'Fuso horário preferido'),
              items: const [
                DropdownMenuItem(value: 'America/Sao_Paulo', child: Text('America/Sao_Paulo')),
                DropdownMenuItem(value: 'America/New_York', child: Text('America/New_York')),
                DropdownMenuItem(value: 'Europe/Lisbon', child: Text('Europe/Lisbon')),
                DropdownMenuItem(value: 'Asia/Tokyo', child: Text('Asia/Tokyo')),
              ],
              onChanged: (v) => setState(() => _timezone = v ?? 'America/Sao_Paulo'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _language,
              decoration: const InputDecoration(labelText: 'Idioma preferido'),
              items: const [
                DropdownMenuItem(value: 'PT', child: Text('Português')),
                DropdownMenuItem(value: 'EN', child: Text('Inglês')),
              ],
              onChanged: (v) => setState(() => _language = v ?? 'PT'),
            ),
          ],
        ),
      ),
    );
  }
}
