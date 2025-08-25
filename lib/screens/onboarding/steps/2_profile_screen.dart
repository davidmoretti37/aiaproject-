import 'package:flutter/material.dart';

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
  final _genderController = TextEditingController();

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
        // Título estilizado
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B6B6B),
            ),
            children: [
              const TextSpan(text: 'Queremos te '),
              TextSpan(
                text: 'Conhecer',
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
          'Preencha com seus dados para personalizar a sua experiência no AIA',
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
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration.copyWith(labelText: 'Nome Completo'),
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: _emailController,
                decoration: _inputDecoration.copyWith(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: _phoneController,
                decoration: _inputDecoration.copyWith(labelText: 'Telefone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 22),
              TextFormField(
                readOnly: true,
                decoration: _inputDecoration.copyWith(
                  labelText: 'Data de Nascimento',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today, color: Color(0xFF95C5D9)),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime(2000, 1, 1),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData(
                              colorScheme: const ColorScheme.light(
                                primary: Color(0xFF95C5D9),
                                onPrimary: Colors.white,
                                surface: Color(0xFFF9FAFB),
                                onSurface: Color(0xFF222222),
                              ),
                              dialogBackgroundColor: Color(0xFFF9FAFB),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() {
                          _birthDate = picked;
                        });
                      }
                    },
                  ),
                ),
                controller: TextEditingController(
                  text: _birthDate == null
                      ? ''
                      : '${_birthDate!.day.toString().padLeft(2, '0')}/${_birthDate!.month.toString().padLeft(2, '0')}/${_birthDate!.year}',
                ),
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: _genderController,
                decoration: _inputDecoration.copyWith(labelText: 'Gênero'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
