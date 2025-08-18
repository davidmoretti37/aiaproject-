import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/reminder_model.dart';

class ReminderService {
  static final _supabase = Supabase.instance.client;

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
}
