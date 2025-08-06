import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:calma_flutter/core/services/supabase_service.dart';
import 'package:calma_flutter/features/auth/presentation/viewmodels/auth_viewmodel.dart';

class PsychologistInvitationCheckerService {
  final SupabaseClient _supabase = SupabaseService.client;
  
  /// Verifica se há convites pendentes para o e-mail fornecido
  Future<List<Map<String, dynamic>>> checkPendingInvitations(String email) async {
    debugPrint('🔄 INVITATION_CHECKER: Verificando convites - INÍCIO');
    debugPrint('🔄 INVITATION_CHECKER: Email: $email');
    
    try {
      debugPrint('🔄 INVITATION_CHECKER: Conectando ao Supabase');
      
      // Verificar se o cliente Supabase está inicializado
      if (_supabase == null) {
        debugPrint('❌ INVITATION_CHECKER: Cliente Supabase é nulo!');
        return [];
      }
      
      debugPrint('🔄 INVITATION_CHECKER: Executando consulta');
      final pendingInvites = await _supabase
          .from('psychologists_patients')
          .select('*, psychologists(*)')
          .eq('patient_email', email)
          .eq('status', 'pending');
      
      debugPrint('✅ INVITATION_CHECKER: Consulta executada com sucesso');
      debugPrint('✅ INVITATION_CHECKER: ${pendingInvites.length} convites pendentes encontrados');
      
      // Log detalhado dos convites encontrados
      for (var i = 0; i < pendingInvites.length; i++) {
        final invite = pendingInvites[i];
        final psychologist = invite['psychologists'];
        debugPrint('✅ INVITATION_CHECKER: Convite $i - ID: ${invite['id']}');
        debugPrint('✅ INVITATION_CHECKER: Convite $i - Psicólogo: ${psychologist['name']}');
      }
      
      return pendingInvites;
    } catch (e, stackTrace) {
      debugPrint('❌ INVITATION_CHECKER: Erro ao verificar convites: $e');
      debugPrint('❌ INVITATION_CHECKER: Stack trace: $stackTrace');
      return [];
    } finally {
      debugPrint('🔄 INVITATION_CHECKER: Verificando convites - FIM');
    }
  }
  
  /// Aceita um convite pendente
  Future<bool> acceptInvitation(String invitationId, String userId) async {
    try {
      debugPrint('🔄 INVITATION_CHECKER: Aceitando convite: $invitationId');
      
      // 1. Obter o ID do psicólogo a partir do convite
      final invitation = await _supabase
          .from('psychologists_patients')
          .select('psychologist_id')
          .eq('id', invitationId)
          .single();
      
      final psychologistId = invitation['psychologist_id'];
      debugPrint('🔄 INVITATION_CHECKER: ID do psicólogo obtido: $psychologistId');
      
      // 2. Atualizar o status do convite e definir o patient_id
      await _supabase
          .from('psychologists_patients')
          .update({
            'status': 'active',
            'patient_id': userId,
            'started_at': DateTime.now().toIso8601String(),
          })
          .eq('id', invitationId);
      
      debugPrint('✅ INVITATION_CHECKER: Convite atualizado com sucesso');
      
      // 3. Atualizar o perfil do usuário com o ID do psicólogo
      await _supabase
          .from('user_profiles')
          .update({
            'psychologist_id': psychologistId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
      
      debugPrint('✅ INVITATION_CHECKER: Perfil do usuário atualizado com o ID do psicólogo');
      return true;
    } catch (e) {
      debugPrint('❌ INVITATION_CHECKER: Erro ao aceitar convite: $e');
      return false;
    }
  }
  
  /// Rejeita um convite pendente
  Future<bool> rejectInvitation(String invitationId) async {
    try {
      debugPrint('🔄 INVITATION_CHECKER: Rejeitando convite: $invitationId');
      
      await _supabase
          .from('psychologists_patients')
          .update({
            'status': 'rejected',
            'ended_at': DateTime.now().toIso8601String(),
          })
          .eq('id', invitationId);
      
      debugPrint('✅ INVITATION_CHECKER: Convite rejeitado com sucesso');
      return true;
    } catch (e) {
      debugPrint('❌ INVITATION_CHECKER: Erro ao rejeitar convite: $e');
      return false;
    }
  }
}
