import 'package:flutter/material.dart';

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
              const TextSpan(text: 'Privacidade & '),
              TextSpan(
                text: 'Dados',
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
          'Gerencie como seus dados são armazenados, compartilhados e protegidos.',
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
            children: [
              SwitchListTile(
                title: const Text('Armazenar meus dados'),
                value: _storeData,
                onChanged: (v) => setState(() => _storeData = v),
              ),
              const SizedBox(height: 22),
              DropdownButtonFormField<String>(
                value: _retention,
                decoration: _inputDecoration.copyWith(labelText: 'Período de retenção'),
                items: const [
                  DropdownMenuItem(value: '3 meses', child: Text('3 meses')),
                  DropdownMenuItem(value: '6 meses', child: Text('6 meses')),
                  DropdownMenuItem(value: '1 ano', child: Text('1 ano')),
                  DropdownMenuItem(value: 'Indefinido', child: Text('Indefinido')),
                ],
                onChanged: (v) => setState(() => _retention = v ?? '6 meses'),
              ),
              const SizedBox(height: 22),
              SwitchListTile(
                title: const Text('Permitir compartilhamento de informações'),
                value: _shareInfo,
                onChanged: (v) => setState(() => _shareInfo = v),
              ),
              const SizedBox(height: 22),
              SwitchListTile(
                title: const Text('Backup de configurações'),
                value: _backup,
                onChanged: (v) => setState(() => _backup = v),
              ),
              const SizedBox(height: 22),
              CheckboxListTile(
                title: const Text('Li e aceito a política de privacidade'),
                value: _acceptPolicy,
                onChanged: (v) => setState(() => _acceptPolicy = v ?? false),
              ),
              const SizedBox(height: 22),
            ],
          ),
        ),
      ],
    );
  }
}
