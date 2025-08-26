import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../styles.dart';
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
  final _genderController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return OnboardingStepLayout(
      child: ListView(
        padding: const EdgeInsets.only(top: 90, left: 24, right: 24, bottom: 150),
        children: [
          // Título estilizado
          RichText(
            text: TextSpan(
              style: OnboardingStyles.titleStyle,
              children: [
                const TextSpan(text: 'Queremos te '),
                TextSpan(
                  text: 'Conhecer',
                  style: OnboardingStyles.titleStyle.copyWith(
                    color: const Color(0xFF95C5D9),
                  ),
                ),
              ],
            ),
          ).animate().fade(duration: 500.ms).slideX(),
          const SizedBox(height: 10),
          Text(
            'Preencha com seus dados para personalizar a sua experiência no AIA',
            style: OnboardingStyles.subtitleStyle,
          ).animate().fade(duration: 500.ms).slideX(delay: 200.ms),
          const SizedBox(height: 32),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: OnboardingStyles.inputDecoration('Nome Completo'),
                ).animate().fade(duration: 500.ms).slideX(delay: 400.ms),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _emailController,
                  decoration: OnboardingStyles.inputDecoration('E-mail'),
                  keyboardType: TextInputType.emailAddress,
                ).animate().fade(duration: 500.ms).slideX(delay: 500.ms),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _phoneController,
                  decoration: OnboardingStyles.inputDecoration('Telefone'),
                  keyboardType: TextInputType.phone,
                ).animate().fade(duration: 500.ms).slideX(delay: 600.ms),
                const SizedBox(height: 22),
                TextFormField(
                  readOnly: true,
                  decoration: OnboardingStyles.inputDecoration('Data de Nascimento').copyWith(
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
                                dialogBackgroundColor: const Color(0xFFF9FAFB),
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
                ).animate().fade(duration: 500.ms).slideX(delay: 700.ms),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _genderController,
                  decoration: OnboardingStyles.inputDecoration('Gênero'),
                ).animate().fade(duration: 500.ms).slideX(delay: 800.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
