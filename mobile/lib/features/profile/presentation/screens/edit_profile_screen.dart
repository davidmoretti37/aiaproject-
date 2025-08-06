import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:calma_flutter/core/di/injection.dart';
import 'package:calma_flutter/features/profile/presentation/viewmodels/user_profile_viewmodel.dart';
import 'package:calma_flutter/features/profile/domain/models/user_profile_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final UserProfileViewModel _profileViewModel;
  
  // Controladores dos campos
  final TextEditingController _nameController = TextEditingController();
  
  // Estados dos campos
  String? _selectedGender;
  String? _selectedAgeRange;
  List<String> _selectedObjectives = [];
  String? _selectedExperience;
  
  // Estados da UI
  bool _isLoading = false;
  bool _hasChanges = false;
  
  // Opções disponíveis (usando as constantes do modelo)
  final List<String> _genderOptions = UserProfileConstants.genderOptions;
  final List<String> _ageRangeOptions = UserProfileConstants.ageRangeOptions;
  final List<String> _objectiveOptions = UserProfileConstants.aiaObjectiveOptions;
  final List<String> _experienceOptions = UserProfileConstants.mentalHealthExperienceOptions;

  @override
  void initState() {
    super.initState();
    _profileViewModel = getIt<UserProfileViewModel>();
    _loadCurrentData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _loadCurrentData() {
    final profile = _profileViewModel.currentProfile;
    if (profile != null) {
      _nameController.text = profile.preferredName;
      _selectedGender = profile.gender;
      _selectedAgeRange = profile.ageRange;
      _selectedObjectives = List.from(profile.aiaObjectives);
      _selectedExperience = profile.mentalHealthExperience;
    }
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_hasChanges) {
      context.pop();
      return;
    }

    // Validar campos obrigatórios
    if (_nameController.text.trim().isEmpty) {
      _showError('Nome é obrigatório');
      return;
    }

    if (_selectedGender == null) {
      _showError('Selecione seu gênero');
      return;
    }

    if (_selectedAgeRange == null) {
      _showError('Selecione sua faixa etária');
      return;
    }

    if (_selectedObjectives.isEmpty) {
      _showError('Selecione pelo menos um objetivo');
      return;
    }

    if (_selectedExperience == null) {
      _showError('Selecione sua experiência com saúde mental');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _profileViewModel.updateProfile(
        preferredName: _nameController.text.trim(),
        gender: _selectedGender!,
        ageRange: _selectedAgeRange!,
        aiaObjectives: _selectedObjectives,
        mentalHealthExperience: _selectedExperience!,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado com sucesso!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      } else if (mounted) {
        _showError(_profileViewModel.errorMessage ?? 'Erro ao atualizar perfil');
      }
    } catch (e) {
      if (mounted) {
        _showError('Erro inesperado: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar alterações?'),
        content: const Text('Você tem alterações não salvas. Deseja sair sem salvar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvoked: (didPop) async {
        if (!didPop && _hasChanges) {
          final shouldPop = await _onWillPop();
          if (shouldPop && mounted) {
            context.pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'Editar Perfil',
            style: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black54),
            onPressed: () async {
              if (_hasChanges) {
                final shouldPop = await _onWillPop();
                if (shouldPop && mounted) {
                  context.pop();
                }
              } else {
                context.pop();
              }
            },
          ),
          actions: [
            if (_hasChanges)
              TextButton(
                onPressed: _isLoading ? null : _saveChanges,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Salvar',
                        style: TextStyle(
                          color: Color(0xFF9C89B8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNameSection(),
              const SizedBox(height: 24),
              _buildGenderSection(),
              const SizedBox(height: 24),
              _buildAgeSection(),
              const SizedBox(height: 24),
              _buildObjectivesSection(),
              const SizedBox(height: 24),
              _buildExperienceSection(),
              const SizedBox(height: 32),
              _buildSaveButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameSection() {
    return _buildSection(
      title: 'Nome Preferido',
      subtitle: 'Como a AIA deve te chamar',
      child: TextField(
        controller: _nameController,
        onChanged: (_) => _onFieldChanged(),
        decoration: InputDecoration(
          hintText: 'Digite seu nome',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSection() {
    return _buildSection(
      title: 'Gênero',
      subtitle: 'Como você se identifica',
      child: Column(
        children: _genderOptions.map((option) {
          final isSelected = _selectedGender == option;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFF9C89B8) : Colors.transparent,
                width: 2,
              ),
            ),
            child: RadioListTile<String>(
              value: option,
              groupValue: _selectedGender,
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
                _onFieldChanged();
              },
              title: Text(option),
              activeColor: const Color(0xFF9C89B8),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAgeSection() {
    return _buildSection(
      title: 'Faixa Etária',
      subtitle: 'Sua idade atual',
      child: Column(
        children: _ageRangeOptions.map((option) {
          final isSelected = _selectedAgeRange == option;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFF9C89B8) : Colors.transparent,
                width: 2,
              ),
            ),
            child: RadioListTile<String>(
              value: option,
              groupValue: _selectedAgeRange,
              onChanged: (value) {
                setState(() {
                  _selectedAgeRange = value;
                });
                _onFieldChanged();
              },
              title: Text('$option anos'),
              activeColor: const Color(0xFF9C89B8),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildObjectivesSection() {
    return _buildSection(
      title: 'Objetivos com a AIA',
      subtitle: 'Selecione todos que se aplicam',
      child: Column(
        children: _objectiveOptions.map((option) {
          final isSelected = _selectedObjectives.contains(option);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFF9C89B8) : Colors.transparent,
                width: 2,
              ),
            ),
            child: CheckboxListTile(
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedObjectives.add(option);
                  } else {
                    _selectedObjectives.remove(option);
                  }
                });
                _onFieldChanged();
              },
              title: Text(option),
              activeColor: const Color(0xFF9C89B8),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExperienceSection() {
    return _buildSection(
      title: 'Experiência com Saúde Mental',
      subtitle: 'Com que frequência você cuida da sua saúde mental',
      child: Column(
        children: _experienceOptions.map((option) {
          final isSelected = _selectedExperience == option;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFF9C89B8) : Colors.transparent,
                width: 2,
              ),
            ),
            child: RadioListTile<String>(
              value: option,
              groupValue: _selectedExperience,
              onChanged: (value) {
                setState(() {
                  _selectedExperience = value;
                });
                _onFieldChanged();
              },
              title: Text(option),
              activeColor: const Color(0xFF9C89B8),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9C89B8),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Salvar Alterações',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
