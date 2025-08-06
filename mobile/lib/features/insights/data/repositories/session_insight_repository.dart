import 'package:calma_flutter/core/di/injection.dart';
import 'package:calma_flutter/core/services/supabase_service.dart';
import 'package:calma_flutter/features/insights/domain/models/session_insight_model.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repositório para acessar os insights de sessões no Supabase
class SessionInsightRepository {
  final String _tableName = 'session_insights';
  
  /// Busca insights por ID da sessão
  Future<SessionInsightModel?> getInsightBySessionId(String sessionId) async {
    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .select()
          .eq('session_id', sessionId)
          .single();
      
      if (response != null) {
        return SessionInsightModel.fromJson(response);
      }
      
      return null;
    } catch (e) {
      debugPrint('Erro ao buscar insight: $e');
      // Se não encontrar, retornamos null em vez de lançar exceção
      if (e is PostgrestException && e.code == 'PGRST116') {
        return null;
      }
      rethrow;
    }
  }

  /// Cria um novo insight para uma sessão
  Future<SessionInsightModel> createInsight({
    required String sessionId,
    required List<String> topics,
    String? reflections,
    String? longSummary,
  }) async {
    try {
      final data = {
        'session_id': sessionId,
        'topics': topics,
        'reflections': reflections,
        'long_summary': longSummary,
      };
      
      final response = await SupabaseService.client
          .from(_tableName)
          .insert(data)
          .select()
          .single();
      
      return SessionInsightModel.fromJson(response);
    } catch (e) {
      debugPrint('Erro ao criar insight: $e');
      rethrow;
    }
  }

  /// Atualiza um insight existente
  Future<SessionInsightModel> updateInsight(SessionInsightModel insight) async {
    try {
      final response = await SupabaseService.client
          .from(_tableName)
          .update(insight.toJson())
          .eq('id', insight.id)
          .select()
          .single();
      
      return SessionInsightModel.fromJson(response);
    } catch (e) {
      debugPrint('Erro ao atualizar insight: $e');
      rethrow;
    }
  }

  /// Exclui um insight e sua sessão correspondente
  Future<void> deleteInsightAndSession(String sessionId) async {
    try {
      // Inicia uma transação para excluir tanto o insight quanto a sessão
      await SupabaseService.client.rpc('delete_insight_and_session', params: {
        'session_id_param': sessionId,
      });
    } catch (e) {
      debugPrint('Erro ao excluir insight e sessão: $e');
      
      // Fallback: tenta excluir individualmente se a função RPC falhar
      try {
        // Primeiro exclui o insight
        await SupabaseService.client
            .from(_tableName)
            .delete()
            .eq('session_id', sessionId);
        
        // Depois exclui a sessão
        await SupabaseService.client
            .from('call_sessions')
            .delete()
            .eq('id', sessionId);
      } catch (fallbackError) {
        debugPrint('Erro no fallback de exclusão: $fallbackError');
        rethrow;
      }
    }
  }
}
