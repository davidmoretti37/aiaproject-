import 'package:calma_flutter/features/profile/domain/models/user_profile_model.dart';

/// Repository interface para operações de perfil do usuário
abstract class UserProfileRepository {
  /// Cria um novo perfil de usuário
  /// 
  /// [profile] - Dados do perfil a serem salvos
  /// Retorna o perfil criado com ID gerado ou null em caso de erro
  Future<UserProfileModel?> createProfile(UserProfileModel profile);

  /// Busca o perfil do usuário pelo ID do usuário
  /// 
  /// [userId] - ID do usuário autenticado
  /// Retorna o perfil encontrado ou null se não existir
  Future<UserProfileModel?> getProfileByUserId(String userId);

  /// Atualiza o perfil do usuário
  /// 
  /// [profile] - Dados atualizados do perfil
  /// Retorna o perfil atualizado ou null em caso de erro
  Future<UserProfileModel?> updateProfile(UserProfileModel profile);

  /// Remove o perfil do usuário
  /// 
  /// [userId] - ID do usuário
  /// Retorna true se removido com sucesso, false caso contrário
  Future<bool> deleteProfile(String userId);

  /// Verifica se o usuário já possui um perfil
  /// 
  /// [userId] - ID do usuário
  /// Retorna true se o perfil existe, false caso contrário
  Future<bool> hasProfile(String userId);
}
