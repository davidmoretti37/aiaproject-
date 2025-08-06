import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/supabase_service.dart';
import '../../domain/models/call_session_model.dart';

/// Repository para gerenciar dados de sessões de conversa com a AIA
class CallSessionRepository {
  final SupabaseClient _client = SupabaseService.client;

  /// Busca todas as sessões do usuário atual ordenadas por data (mais recentes primeiro)
  Future<List<CallSessionModel>> getUserSessions() async {
    try {
      debugPrint('🔄 CALL_SESSION_REPO: Buscando sessões do usuário...');
      
      final user = _client.auth.currentUser;
      if (user == null) {
        debugPrint('❌ CALL_SESSION_REPO: Usuário não autenticado');
        return [];
      }

      final response = await _client
          .from('call_sessions')
          .select('*')
          .eq('user_id', user.id)
          .order('started_at', ascending: false);

      final List<CallSessionModel> sessions = [];
      
      for (final item in response as List) {
        try {
          final session = CallSessionModel.fromJson(item);
          // Só adiciona sessões que têm mood e summary válidos
          if (session.hasValidData) {
            sessions.add(session);
          }
        } catch (e) {
          debugPrint('⚠️ CALL_SESSION_REPO: Erro ao parsear sessão: $e');
          // Continua processando outras sessões mesmo se uma falhar
        }
      }

      debugPrint('✅ CALL_SESSION_REPO: ${sessions.length} sessões válidas carregadas');
      return sessions;
    } catch (e) {
      debugPrint('❌ CALL_SESSION_REPO: Erro ao buscar sessões: $e');
      return [];
    }
  }

  /// Busca sessões por período específico
  Future<List<CallSessionModel>> getSessionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      debugPrint('🔄 CALL_SESSION_REPO: Buscando sessões entre ${startDate.toIso8601String()} e ${endDate.toIso8601String()}');
      
      final user = _client.auth.currentUser;
      if (user == null) {
        debugPrint('❌ CALL_SESSION_REPO: Usuário não autenticado');
        return [];
      }

      final response = await _client
          .from('call_sessions')
          .select('*')
          .eq('user_id', user.id)
          .gte('started_at', startDate.toIso8601String())
          .lte('started_at', endDate.toIso8601String())
          .order('started_at', ascending: false);

      final List<CallSessionModel> sessions = [];
      
      for (final item in response as List) {
        try {
          final session = CallSessionModel.fromJson(item);
          if (session.hasValidData) {
            sessions.add(session);
          }
        } catch (e) {
          debugPrint('⚠️ CALL_SESSION_REPO: Erro ao parsear sessão: $e');
        }
      }

      debugPrint('✅ CALL_SESSION_REPO: ${sessions.length} sessões encontradas no período');
      return sessions;
    } catch (e) {
      debugPrint('❌ CALL_SESSION_REPO: Erro ao buscar sessões por período: $e');
      return [];
    }
  }

  /// Busca sessões por mood específico
  Future<List<CallSessionModel>> getSessionsByMood(String mood) async {
    try {
      debugPrint('🔄 CALL_SESSION_REPO: Buscando sessões com mood: $mood');
      
      final user = _client.auth.currentUser;
      if (user == null) {
        debugPrint('❌ CALL_SESSION_REPO: Usuário não autenticado');
        return [];
      }

      final response = await _client
          .from('call_sessions')
          .select('*')
          .eq('user_id', user.id)
          .eq('mood', mood.toLowerCase())
          .order('started_at', ascending: false);

      final List<CallSessionModel> sessions = [];
      
      for (final item in response as List) {
        try {
          final session = CallSessionModel.fromJson(item);
          if (session.hasValidData) {
            sessions.add(session);
          }
        } catch (e) {
          debugPrint('⚠️ CALL_SESSION_REPO: Erro ao parsear sessão: $e');
        }
      }

      debugPrint('✅ CALL_SESSION_REPO: ${sessions.length} sessões encontradas com mood $mood');
      return sessions;
    } catch (e) {
      debugPrint('❌ CALL_SESSION_REPO: Erro ao buscar sessões por mood: $e');
      return [];
    }
  }

  /// Busca sessões recentes (últimos 7 dias)
  Future<List<CallSessionModel>> getRecentSessions() async {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    
    return getSessionsByDateRange(
      startDate: sevenDaysAgo,
      endDate: now,
    );
  }

  /// Busca uma sessão específica por ID
  Future<CallSessionModel?> getSessionById(String sessionId) async {
    try {
      debugPrint('🔄 CALL_SESSION_REPO: Buscando sessão por ID: $sessionId');
      
      final user = _client.auth.currentUser;
      if (user == null) {
        debugPrint('❌ CALL_SESSION_REPO: Usuário não autenticado');
        return null;
      }

      final response = await _client
          .from('call_sessions')
          .select('*')
          .eq('id', sessionId)
          .eq('user_id', user.id)
          .single();

      final session = CallSessionModel.fromJson(response);
      debugPrint('✅ CALL_SESSION_REPO: Sessão encontrada: ${session.id}');
      return session;
    } catch (e) {
      debugPrint('❌ CALL_SESSION_REPO: Erro ao buscar sessão por ID: $e');
      return null;
    }
  }

  /// Conta o número de sessões por mood
  Future<Map<String, int>> getMoodDistribution() async {
    try {
      debugPrint('🔄 CALL_SESSION_REPO: Calculando distribuição de moods...');
      
      final sessions = await getUserSessions();
      final Map<String, int> distribution = {
        'feliz': 0,
        'triste': 0,
        'ansioso': 0,
        'neutro': 0,
        'irritado': 0,
      };

      for (final session in sessions) {
        final mood = session.mood?.toLowerCase();
        if (mood != null && distribution.containsKey(mood)) {
          distribution[mood] = distribution[mood]! + 1;
        }
      }

      debugPrint('✅ CALL_SESSION_REPO: Distribuição calculada: $distribution');
      return distribution;
    } catch (e) {
      debugPrint('❌ CALL_SESSION_REPO: Erro ao calcular distribuição de moods: $e');
      return {};
    }
  }

  /// Verifica se há novas sessões desde a última verificação
  Future<bool> hasNewSessions({DateTime? since}) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      final sinceDate = since ?? DateTime.now().subtract(const Duration(minutes: 5));
      
      final response = await _client
          .from('call_sessions')
          .select('id')
          .eq('user_id', user.id)
          .gte('started_at', sinceDate.toIso8601String())
          .limit(1);

      return (response as List).isNotEmpty;
    } catch (e) {
      debugPrint('❌ CALL_SESSION_REPO: Erro ao verificar novas sessões: $e');
      return false;
    }
  }

  /// Busca estatísticas gerais do usuário
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      debugPrint('🔄 CALL_SESSION_REPO: Calculando estatísticas do usuário...');
      
      final sessions = await getUserSessions();
      final moodDistribution = await getMoodDistribution();
      
      final stats = {
        'totalSessions': sessions.length,
        'moodDistribution': moodDistribution,
        'lastSessionDate': sessions.isNotEmpty ? sessions.first.createdAt : null,
        'averageSessionsPerWeek': _calculateWeeklyAverage(sessions),
        'mostCommonMood': _getMostCommonMood(moodDistribution),
      };

      debugPrint('✅ CALL_SESSION_REPO: Estatísticas calculadas: $stats');
      return stats;
    } catch (e) {
      debugPrint('❌ CALL_SESSION_REPO: Erro ao calcular estatísticas: $e');
      return {};
    }
  }

  /// Calcula a média de sessões por semana
  double _calculateWeeklyAverage(List<CallSessionModel> sessions) {
    if (sessions.isEmpty) return 0.0;
    
    final now = DateTime.now();
    final firstSession = sessions.last.createdAt;
    final daysDifference = now.difference(firstSession).inDays;
    final weeks = daysDifference / 7.0;
    
    return weeks > 0 ? sessions.length / weeks : sessions.length.toDouble();
  }

  /// Encontra o mood mais comum
  String? _getMostCommonMood(Map<String, int> distribution) {
    if (distribution.isEmpty) return null;
    
    String? mostCommon;
    int maxCount = 0;
    
    distribution.forEach((mood, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommon = mood;
      }
    });
    
    return mostCommon;
  }
}
