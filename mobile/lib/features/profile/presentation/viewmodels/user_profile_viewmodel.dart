import 'package:flutter/foundation.dart';
import 'package:calma_flutter/features/profile/domain/models/user_profile_model.dart';
import 'package:calma_flutter/features/profile/domain/repositories/user_profile_repository.dart';

/// ViewModel para gerenciar o estado do perfil do usuário
class UserProfileViewModel extends ChangeNotifier {
  final UserProfileRepository _repository;

  UserProfileViewModel(this._repository);

  // Estado do perfil
  UserProfileModel? _currentProfile;
  UserProfileModel? get currentProfile => _currentProfile;

  // Estados de carregamento e erro
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Carrega o perfil do usuário
  Future<bool> loadProfile(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('🔄 [UserProfileViewModel] Carregando perfil para usuário: $userId');
      
      final profile = await _repository.getProfileByUserId(userId);
      
      if (profile != null) {
        _currentProfile = profile;
        _isInitialized = true;
        debugPrint('✅ [UserProfileViewModel] Perfil carregado com sucesso');
        notifyListeners();
        return true;
      } else {
        debugPrint('ℹ️ [UserProfileViewModel] Perfil não encontrado');
        _isInitialized = true;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _setError('Erro ao carregar perfil: $e');
      debugPrint('❌ [UserProfileViewModel] Erro ao carregar perfil: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Cria um novo perfil
  Future<bool> createProfile({
    required String userId,
    required String preferredName,
    required String gender,
    required String ageRange,
    required List<String> aiaObjectives,
    required String mentalHealthExperience,
    String? phoneNumber,
    String? fullName,
    String? email,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      debugPrint('🔄 [UserProfileViewModel] Criando perfil para usuário: $userId');

      // Validar dados
      if (!_validateProfileData(
        preferredName: preferredName,
        gender: gender,
        ageRange: ageRange,
        aiaObjectives: aiaObjectives,
        mentalHealthExperience: mentalHealthExperience,
      )) {
        return false;
      }

      final profile = UserProfileModel(
        id: '', // Será gerado pelo banco
        userId: userId,
        preferredName: preferredName.trim(),
        gender: gender,
        ageRange: ageRange,
        aiaObjectives: aiaObjectives,
        mentalHealthExperience: mentalHealthExperience,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        phoneNumber: phoneNumber,
        fullName: fullName,
        email: email,
      );

      final createdProfile = await _repository.createProfile(profile);
      
      if (createdProfile != null) {
        _currentProfile = createdProfile;
        _isInitialized = true;
        debugPrint('✅ [UserProfileViewModel] Perfil criado com sucesso');
        notifyListeners();
        return true;
      } else {
        _setError('Erro ao criar perfil');
        return false;
      }
    } catch (e) {
      _setError('Erro ao criar perfil: $e');
      debugPrint('❌ [UserProfileViewModel] Erro ao criar perfil: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Atualiza o perfil existente
  Future<bool> updateProfile({
    required String preferredName,
    required String gender,
    required String ageRange,
    required List<String> aiaObjectives,
    required String mentalHealthExperience,
  }) async {
    if (_currentProfile == null) {
      _setError('Nenhum perfil carregado para atualizar');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      debugPrint('🔄 [UserProfileViewModel] Atualizando perfil: ${_currentProfile!.id}');

      // Validar dados
      if (!_validateProfileData(
        preferredName: preferredName,
        gender: gender,
        ageRange: ageRange,
        aiaObjectives: aiaObjectives,
        mentalHealthExperience: mentalHealthExperience,
      )) {
        return false;
      }

      final updatedProfile = _currentProfile!.copyWith(
        preferredName: preferredName.trim(),
        gender: gender,
        ageRange: ageRange,
        aiaObjectives: aiaObjectives,
        mentalHealthExperience: mentalHealthExperience,
        updatedAt: DateTime.now(),
        // Manter o e-mail existente
        email: _currentProfile!.email,
      );

      final result = await _repository.updateProfile(updatedProfile);
      
      if (result != null) {
        _currentProfile = result;
        debugPrint('✅ [UserProfileViewModel] Perfil atualizado com sucesso');
        notifyListeners();
        return true;
      } else {
        _setError('Erro ao atualizar perfil');
        return false;
      }
    } catch (e) {
      _setError('Erro ao atualizar perfil: $e');
      debugPrint('❌ [UserProfileViewModel] Erro ao atualizar perfil: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Remove o perfil do usuário
  Future<bool> deleteProfile() async {
    if (_currentProfile == null) {
      _setError('Nenhum perfil carregado para remover');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      debugPrint('🔄 [UserProfileViewModel] Removendo perfil: ${_currentProfile!.id}');
      
      final success = await _repository.deleteProfile(_currentProfile!.userId);
      
      if (success) {
        _currentProfile = null;
        _isInitialized = false;
        debugPrint('✅ [UserProfileViewModel] Perfil removido com sucesso');
        notifyListeners();
        return true;
      } else {
        _setError('Erro ao remover perfil');
        return false;
      }
    } catch (e) {
      _setError('Erro ao remover perfil: $e');
      debugPrint('❌ [UserProfileViewModel] Erro ao remover perfil: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Verifica se o usuário tem perfil
  Future<bool> hasProfile(String userId) async {
    try {
      return await _repository.hasProfile(userId);
    } catch (e) {
      debugPrint('❌ [UserProfileViewModel] Erro ao verificar perfil: $e');
      return false;
    }
  }

  /// Valida os dados do perfil
  bool _validateProfileData({
    required String preferredName,
    required String gender,
    required String ageRange,
    required List<String> aiaObjectives,
    required String mentalHealthExperience,
  }) {
    // Validar nome
    if (preferredName.trim().isEmpty) {
      _setError('Nome é obrigatório');
      return false;
    }

    if (preferredName.trim().length < 2) {
      _setError('Nome deve ter pelo menos 2 caracteres');
      return false;
    }

    // Validar gênero
    if (!UserProfileConstants.genderOptions.contains(gender)) {
      _setError('Gênero inválido');
      return false;
    }

    // Validar faixa etária
    if (!UserProfileConstants.ageRangeOptions.contains(ageRange)) {
      _setError('Faixa etária inválida');
      return false;
    }

    // Validar objetivos
    if (aiaObjectives.isEmpty) {
      _setError('Selecione pelo menos um objetivo');
      return false;
    }

    for (final objective in aiaObjectives) {
      if (!UserProfileConstants.aiaObjectiveOptions.contains(objective)) {
        _setError('Objetivo inválido: $objective');
        return false;
      }
    }

    // Validar experiência com saúde mental
    if (!UserProfileConstants.mentalHealthExperienceOptions.contains(mentalHealthExperience)) {
      _setError('Experiência com saúde mental inválida');
      return false;
    }

    return true;
  }

  /// Define o estado de carregamento
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Define uma mensagem de erro
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Limpa a mensagem de erro
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Limpa todos os dados
  void clear() {
    _currentProfile = null;
    _isLoading = false;
    _errorMessage = null;
    _isInitialized = false;
    notifyListeners();
  }

  /// Obtém uma lista formatada dos objetivos
  String get formattedObjectives {
    if (_currentProfile?.aiaObjectives.isEmpty ?? true) {
      return 'Nenhum objetivo selecionado';
    }
    
    return _currentProfile!.aiaObjectives.join(', ');
  }

  /// Verifica se tem perfil carregado
  bool get hasProfileLoaded => _currentProfile != null;
}
