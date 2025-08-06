import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:calma_flutter/features/profile/domain/models/user_profile_model.dart';
import 'package:calma_flutter/features/profile/domain/repositories/user_profile_repository.dart';

/// Implementação do repository de perfil do usuário usando Supabase
class UserProfileRepositoryImpl implements UserProfileRepository {
  final SupabaseClient _supabase;
  static const String _tableName = 'user_profiles';

  UserProfileRepositoryImpl(this._supabase);

  @override
  Future<UserProfileModel?> createProfile(UserProfileModel profile) async {
    try {
      debugPrint('🔄 [UserProfileRepository] Criando perfil para usuário: ${profile.userId}');
      
      final response = await _supabase
          .from(_tableName)
          .insert(profile.toInsertJson())
          .select()
          .single();

      debugPrint('✅ [UserProfileRepository] Perfil criado com sucesso');
      return UserProfileModel.fromJson(response);
    } catch (e) {
      debugPrint('❌ [UserProfileRepository] Erro ao criar perfil: $e');
      return null;
    }
  }

  @override
  Future<UserProfileModel?> getProfileByUserId(String userId) async {
    try {
      debugPrint('🔄 [UserProfileRepository] Buscando perfil para usuário: $userId');
      
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        debugPrint('ℹ️ [UserProfileRepository] Perfil não encontrado para usuário: $userId');
        return null;
      }

      debugPrint('✅ [UserProfileRepository] Perfil encontrado');
      return UserProfileModel.fromJson(response);
    } catch (e) {
      debugPrint('❌ [UserProfileRepository] Erro ao buscar perfil: $e');
      return null;
    }
  }

  @override
  Future<UserProfileModel?> updateProfile(UserProfileModel profile) async {
    try {
      debugPrint('🔄 [UserProfileRepository] Atualizando perfil: ${profile.id}');
      
      // Log do JSON que será enviado para atualização
      final updateJson = profile.toUpdateJson();
      debugPrint('🔄 [UserProfileRepository] JSON para atualização: $updateJson');
      debugPrint('🔄 [UserProfileRepository] psychologistId no JSON: ${updateJson['psychologist_id']}');
      
      final response = await _supabase
          .from(_tableName)
          .update(updateJson)
          .eq('user_id', profile.userId)
          .select()
          .single();

      debugPrint('✅ [UserProfileRepository] Perfil atualizado com sucesso');
      debugPrint('✅ [UserProfileRepository] Resposta do servidor: $response');
      
      final updatedProfile = UserProfileModel.fromJson(response);
      debugPrint('✅ [UserProfileRepository] psychologistId após atualização: ${updatedProfile.psychologistId}');
      
      return updatedProfile;
    } catch (e) {
      debugPrint('❌ [UserProfileRepository] Erro ao atualizar perfil: $e');
      return null;
    }
  }

  @override
  Future<bool> deleteProfile(String userId) async {
    try {
      debugPrint('🔄 [UserProfileRepository] Removendo perfil para usuário: $userId');
      
      await _supabase
          .from(_tableName)
          .delete()
          .eq('user_id', userId);

      debugPrint('✅ [UserProfileRepository] Perfil removido com sucesso');
      return true;
    } catch (e) {
      debugPrint('❌ [UserProfileRepository] Erro ao remover perfil: $e');
      return false;
    }
  }

  @override
  Future<bool> hasProfile(String userId) async {
    try {
      debugPrint('🔄 [UserProfileRepository] Verificando se usuário tem perfil: $userId');
      
      final response = await _supabase
          .from(_tableName)
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      final hasProfile = response != null;
      debugPrint('ℹ️ [UserProfileRepository] Usuário ${hasProfile ? 'tem' : 'não tem'} perfil');
      
      return hasProfile;
    } catch (e) {
      debugPrint('❌ [UserProfileRepository] Erro ao verificar perfil: $e');
      return false;
    }
  }
}
