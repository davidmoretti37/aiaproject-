import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class AiaDatabaseService {
  static final AiaDatabaseService _instance = AiaDatabaseService._internal();
  factory AiaDatabaseService() => _instance;
  AiaDatabaseService._internal();

  SupabaseClient get client => SupabaseConfig.client;

  // Conversations
  Future<Map<String, dynamic>?> createConversation({
    required String userMessage,
    String? sessionId,
    String? userId,
    Map<String, dynamic>? context,
  }) async {
    try {
      final response = await client.from('conversations').insert({
        'user_message': userMessage,
        'session_id': sessionId,
        'user_id': userId,
        'context': context ?? {},
        'status': 'active',
        'started_at': DateTime.now().toIso8601String(),
      }).select().single();

      return response;
    } catch (e) {
      print('Erro ao criar conversa: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getConversations({
    String? userId,
    String? sessionId,
    int limit = 50,
  }) async {
    try {
      var query = client.from('conversations').select('*');
      
      if (userId != null) {
        query = query.eq('user_id', userId);
      }
      
      if (sessionId != null) {
        query = query.eq('session_id', sessionId);
      }
      
      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erro ao buscar conversas: $e');
      return [];
    }
  }

  Future<bool> updateConversationResponse({
    required String conversationId,
    required String aiResponse,
  }) async {
    try {
      await client.from('conversations').update({
        'ai_response': aiResponse,
        'agent_response': aiResponse,
        'completed_at': DateTime.now().toIso8601String(),
        'status': 'completed',
      }).eq('id', conversationId);

      return true;
    } catch (e) {
      print('Erro ao atualizar conversa: $e');
      return false;
    }
  }

  // User Profiles
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await client
          .from('user_profiles')
          .select('*')
          .eq('id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      print('Erro ao buscar perfil do usuário: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createUserProfile({
    required String userId,
    Map<String, dynamic>? voicePreferences,
  }) async {
    try {
      final response = await client.from('user_profiles').insert({
        'id': userId,
        'voice_preferences': voicePreferences ?? {},
      }).select().single();

      return response;
    } catch (e) {
      print('Erro ao criar perfil do usuário: $e');
      return null;
    }
  }

  Future<bool> updateUserProfile({
    required String userId,
    Map<String, dynamic>? voicePreferences,
  }) async {
    try {
      await client.from('user_profiles').update({
        'voice_preferences': voicePreferences ?? {},
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      return true;
    } catch (e) {
      print('Erro ao atualizar perfil do usuário: $e');
      return false;
    }
  }

  // Reminders
  Future<Map<String, dynamic>?> createReminder({
    required String userId,
    required String eventName,
    required DateTime reminderTime,
    int leadTimeDays = 0,
    int leadTimeMinutes = 0,
    int leadTimeSeconds = 0,
  }) async {
    try {
      final response = await client.from('reminders').insert({
        'user_id': userId,
        'event_name': eventName,
        'reminder_time': reminderTime.toIso8601String(),
        'lead_time_days': leadTimeDays,
        'lead_time_minutes': leadTimeMinutes,
        'lead_time_seconds': leadTimeSeconds,
        'status': 'active',
      }).select().single();

      return response;
    } catch (e) {
      print('Erro ao criar lembrete: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getReminders({
    String? userId,
    String status = 'active',
    int limit = 100,
  }) async {
    try {
      var query = client.from('reminders').select('*');
      
      if (userId != null) {
        query = query.eq('user_id', userId);
      }
      
      final response = await query
          .eq('status', status)
          .order('reminder_time', ascending: true)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erro ao buscar lembretes: $e');
      return [];
    }
  }

  Future<bool> updateReminderStatus({
    required String reminderId,
    required String status,
  }) async {
    try {
      await client.from('reminders').update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', reminderId);

      return true;
    } catch (e) {
      print('Erro ao atualizar status do lembrete: $e');
      return false;
    }
  }

  // Agents
  Future<List<Map<String, dynamic>>> getAgents({
    String status = 'active',
    int limit = 50,
  }) async {
    try {
      final response = await client
          .from('agents')
          .select('*')
          .eq('status', status)
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erro ao buscar agentes: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getAgentByType(String agentType) async {
    try {
      final response = await client
          .from('agents')
          .select('*')
          .eq('type', agentType)
          .eq('status', 'active')
          .maybeSingle();

      return response;
    } catch (e) {
      print('Erro ao buscar agente por tipo: $e');
      return null;
    }
  }

  // Agent Sessions
  Future<Map<String, dynamic>?> createAgentSession({
    required String agentId,
    required String conversationId,
    String? userId,
    Map<String, dynamic>? sessionData,
  }) async {
    try {
      final response = await client.from('agent_sessions').insert({
        'agent_id': agentId,
        'conversation_id': conversationId,
        'user_id': userId,
        'session_data': sessionData ?? {},
        'status': 'active',
        'started_at': DateTime.now().toIso8601String(),
      }).select().single();

      return response;
    } catch (e) {
      print('Erro ao criar sessão do agente: $e');
      return null;
    }
  }

  // Tool Executions
  Future<Map<String, dynamic>?> createToolExecution({
    required String conversationId,
    required String agentType,
    required String toolName,
    Map<String, dynamic>? inputData,
    String? agentId,
    String? agentSessionId,
  }) async {
    try {
      final response = await client.from('tool_executions').insert({
        'conversation_id': conversationId,
        'agent_type': agentType,
        'tool_name': toolName,
        'input_data': inputData ?? {},
        'agent_id': agentId,
        'agent_session_id': agentSessionId,
        'status': 'pending',
        'started_at': DateTime.now().toIso8601String(),
      }).select().single();

      return response;
    } catch (e) {
      print('Erro ao criar execução de ferramenta: $e');
      return null;
    }
  }

  Future<bool> updateToolExecution({
    required String executionId,
    Map<String, dynamic>? outputData,
    String status = 'completed',
    String? errorMessage,
  }) async {
    try {
      final updateData = {
        'output_data': outputData ?? {},
        'status': status,
        'completed_at': DateTime.now().toIso8601String(),
      };

      if (errorMessage != null) {
        updateData['error_message'] = errorMessage;
      }

      await client.from('tool_executions').update(updateData).eq('id', executionId);

      return true;
    } catch (e) {
      print('Erro ao atualizar execução de ferramenta: $e');
      return false;
    }
  }

  // Logs
  Future<bool> createLog({
    String? conversationId,
    String? userId,
    required String component,
    required String level,
    required String message,
    Map<String, dynamic>? context,
  }) async {
    try {
      await client.from('aia_logs').insert({
        'conversation_id': conversationId,
        'user_id': userId,
        'component': component,
        'level': level,
        'message': message,
        'context': context ?? {},
      });

      return true;
    } catch (e) {
      print('Erro ao criar log: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getLogs({
    String? conversationId,
    String? userId,
    String? level,
    int limit = 100,
  }) async {
    try {
      var query = client.from('aia_logs').select('*');
      
      if (conversationId != null) {
        query = query.eq('conversation_id', conversationId);
      }
      
      if (userId != null) {
        query = query.eq('user_id', userId);
      }
      
      if (level != null) {
        query = query.eq('level', level);
      }
      
      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erro ao buscar logs: $e');
      return [];
    }
  }

  // Utility methods
  Future<bool> testConnection() async {
    try {
      await client.from('conversations').select('id').limit(1);
      return true;
    } catch (e) {
      print('Erro ao testar conexão: $e');
      return false;
    }
  }

  Future<Map<String, int>> getDatabaseStats() async {
    try {
      final stats = <String, int>{};
      
      final tables = [
        'conversations',
        'user_profiles',
        'reminders',
        'agents',
        'agent_sessions',
        'tool_executions',
        'aia_logs'
      ];
      
      for (final table in tables) {
        try {
          final response = await client
              .from(table)
              .select('id', const FetchOptions(count: CountOption.exact))
              .limit(1);
          stats[table] = response.count ?? 0;
        } catch (e) {
          stats[table] = -1; // Indica erro
        }
      }
      
      return stats;
    } catch (e) {
      print('Erro ao obter estatísticas do banco: $e');
      return {};
    }
  }
}
