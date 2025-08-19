import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reminder_model.dart';
import 'integrated_auth_service.dart';

class ReminderService {
  static final _supabase = Supabase.instance.client;
  static const String backendUrl = 'http://localhost:8000';

  // Buscar todos os reminders do usuário logado
  static Future<List<ReminderModel>> getUserReminders() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não está logado');
      }

      final response = await _supabase
          .from('reminders')
          .select('*')
          .eq('user_id', user.id)
          .order('reminder_time', ascending: true);

      return (response as List)
          .map((reminder) => ReminderModel.fromJson(reminder))
          .toList();
    } catch (e) {
      print('❌ Erro ao buscar reminders: $e');
      throw Exception('Falha ao carregar reminders: $e');
    }
  }

  // Buscar reminders por status
  static Future<List<ReminderModel>> getRemindersByStatus(String status) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não está logado');
      }

      final response = await _supabase
          .from('reminders')
          .select('*')
          .eq('user_id', user.id)
          .eq('status', status)
          .order('reminder_time', ascending: true);

      return (response as List)
          .map((reminder) => ReminderModel.fromJson(reminder))
          .toList();
    } catch (e) {
      print('❌ Erro ao buscar reminders por status: $e');
      throw Exception('Falha ao carregar reminders: $e');
    }
  }

  // Criar novo reminder
  static Future<ReminderModel> createReminder({
    required String eventName,
    required DateTime reminderTime,
    int leadTimeDays = 0,
    int leadTimeMinutes = 0,
    int leadTimeSeconds = 0,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não está logado');
      }

      final response = await _supabase
          .from('reminders')
          .insert({
            'user_id': user.id,
            'event_name': eventName,
            'reminder_time': reminderTime.toIso8601String(),
            'lead_time_days': leadTimeDays,
            'lead_time_minutes': leadTimeMinutes,
            'lead_time_seconds': leadTimeSeconds,
            'status': 'active',
          })
          .select()
          .single();

      return ReminderModel.fromJson(response);
    } catch (e) {
      print('❌ Erro ao criar reminder: $e');
      throw Exception('Falha ao criar reminder: $e');
    }
  }

  // Atualizar status do reminder
  static Future<void> updateReminderStatus(String reminderId, String status) async {
    try {
      await _supabase
          .from('reminders')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', reminderId);
    } catch (e) {
      print('❌ Erro ao atualizar status do reminder: $e');
      throw Exception('Falha ao atualizar reminder: $e');
    }
  }

  // Deletar reminder
  static Future<void> deleteReminder(String reminderId) async {
    try {
      await _supabase
          .from('reminders')
          .delete()
          .eq('id', reminderId);
    } catch (e) {
      print('❌ Erro ao deletar reminder: $e');
      throw Exception('Falha ao deletar reminder: $e');
    }
  }

  // Buscar reminders próximos (próximas 24 horas)
  static Future<List<ReminderModel>> getUpcomingReminders() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não está logado');
      }

      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));

      final response = await _supabase
          .from('reminders')
          .select('*')
          .eq('user_id', user.id)
          .eq('status', 'active')
          .gte('reminder_time', now.toIso8601String())
          .lte('reminder_time', tomorrow.toIso8601String())
          .order('reminder_time', ascending: true);

      return (response as List)
          .map((reminder) => ReminderModel.fromJson(reminder))
          .toList();
    } catch (e) {
      print('❌ Erro ao buscar reminders próximos: $e');
      throw Exception('Falha ao carregar reminders próximos: $e');
    }
  }

  // Buscar reminders vencidos
  static Future<List<ReminderModel>> getOverdueReminders() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não está logado');
      }

      final now = DateTime.now();

      final response = await _supabase
          .from('reminders')
          .select('*')
          .eq('user_id', user.id)
          .eq('status', 'active')
          .lt('reminder_time', now.toIso8601String())
          .order('reminder_time', ascending: false);

      return (response as List)
          .map((reminder) => ReminderModel.fromJson(reminder))
          .toList();
    } catch (e) {
      print('❌ Erro ao buscar reminders vencidos: $e');
      throw Exception('Falha ao carregar reminders vencidos: $e');
    }
  }

  // === MÉTODOS DE INTEGRAÇÃO COM BACKEND AIA ===
  
  /// Cria um lembrete via backend AIA (linguagem natural)
  static Future<bool> createReminderViaAI({
    required String eventName,
    String timeExpression = "em 1 hora",
  }) async {
    try {
      if (!IntegratedAuthService.isSignedIn()) {
        throw Exception('Usuário não está logado');
      }

      final userId = IntegratedAuthService.getUserId();
      if (userId == null) {
        throw Exception('Não foi possível obter ID do usuário');
      }

      print('🤖 Criando lembrete via AIA: "$eventName" $timeExpression');

      // Usar o endpoint de chat para criar lembrete via AIA
      final message = 'Me lembre de $eventName $timeExpression';
      
      final response = await http.post(
        Uri.parse('$backendUrl/chat'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': message,
          'user_id': userId,
          'session_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          print('✅ Lembrete criado com sucesso via AIA!');
          print('   Resposta: ${data['response']}');
          return true;
        } else {
          print('❌ Falha ao criar lembrete: ${data['response']}');
          return false;
        }
      } else {
        print('❌ Erro HTTP ao criar lembrete: ${response.statusCode}');
        return false;
      }
      
    } catch (e) {
      print('❌ Erro ao criar lembrete via AIA: $e');
      return false;
    }
  }

  /// Lista lembretes via comando de chat AIA
  static Future<String?> listRemindersViaAI() async {
    try {
      if (!IntegratedAuthService.isSignedIn()) {
        throw Exception('Usuário não está logado');
      }

      final userId = IntegratedAuthService.getUserId();
      if (userId == null) {
        throw Exception('Não foi possível obter ID do usuário');
      }

      print('📋 Listando lembretes via AIA');

      final response = await http.post(
        Uri.parse('$backendUrl/chat'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': 'Lista meus lembretes ativos',
          'user_id': userId,
          'session_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'];
      }
      
      return null;
    } catch (e) {
      print('❌ Erro ao listar lembretes via AIA: $e');
      return null;
    }
  }

  /// Testa conexão com o backend AIA
  static Future<bool> testBackendConnection() async {
    try {
      final response = await http.get(Uri.parse('$backendUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Erro ao testar conexão com backend: $e');
      return false;
    }
  }

}
