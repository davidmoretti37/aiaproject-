import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/models/reminder_model.dart';
import '../../domain/repositories/reminder_repository.dart';

/// ReminderRepositoryImpl - Implementação concreta do repositório de lembretes
///
/// Implementa a interface ReminderRepository usando Supabase como fonte de dados.
/// Segue os princípios da Clean Architecture mantendo a separação entre domínio e dados.
class ReminderRepositoryImpl implements ReminderRepository {
  final SupabaseClient _client = SupabaseService.client;

  @override
  Future<Either<String, List<ReminderModel>>> getReminders() async {
    try {
      debugPrint('🔄 REPOSITORY: Buscando lembretes do usuário...');
      
      final user = _client.auth.currentUser;
      if (user == null) {
        debugPrint('❌ REPOSITORY: Usuário não autenticado');
        return const Left('Usuário não autenticado');
      }

      final response = await _client
          .from('reminders')
          .select('id, user_id, hour, minute, is_active, notification_id, last_triggered, created_at, updated_at')
          .eq('user_id', user.id)
          .order('hour')
          .order('minute');

      final List<ReminderModel> reminders = [];
      
      for (final item in response as List) {
        try {
          final reminder = ReminderModel.fromJson(item);
          reminders.add(reminder);
        } catch (e) {
          debugPrint('⚠️ REPOSITORY: Erro ao parsear lembrete: $e');
          // Continua processando outros lembretes mesmo se um falhar
        }
      }

      debugPrint('✅ REPOSITORY: ${reminders.length} lembretes carregados com sucesso');
      return Right(reminders);
    } catch (e) {
      debugPrint('❌ REPOSITORY: Erro ao buscar lembretes: $e');
      return Left('Erro ao buscar lembretes: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, ReminderModel>> saveReminder(ReminderModel reminder) async {
    try {
      debugPrint('🔄 REPOSITORY: Salvando lembrete ${reminder.toTimeString()}...');
      
      final user = _client.auth.currentUser;
      if (user == null) {
        debugPrint('❌ REPOSITORY: Usuário não autenticado');
        return const Left('Usuário não autenticado');
      }

      // Verificar se já existe um lembrete neste horário para este usuário
      final existingResponse = await _client
          .from('reminders')
          .select('id')
          .eq('user_id', user.id)
          .eq('hour', reminder.hour)
          .eq('minute', reminder.minute);

      if (existingResponse.isNotEmpty && reminder.id == null) {
        debugPrint('⚠️ REPOSITORY: Já existe um lembrete neste horário');
        return const Left('Já existe um lembrete neste horário');
      }

      Map<String, dynamic> response;
      
      if (reminder.id != null) {
        // Atualizar lembrete existente
        debugPrint('🔄 REPOSITORY: Atualizando lembrete existente ${reminder.id}');
        response = await _client
            .from('reminders')
            .update(reminder.toJson())
            .eq('id', reminder.id!)
            .select()
            .single();
      } else {
        // Criar novo lembrete
        debugPrint('🔄 REPOSITORY: Criando novo lembrete');
        final reminderData = reminder.copyWith(userId: user.id).toJson();
        response = await _client
            .from('reminders')
            .insert(reminderData)
            .select()
            .single();
      }

      final savedReminder = ReminderModel.fromJson(response);
      
      // Agendar/atualizar notificação local
      if (savedReminder.isActive) {
        final notificationId = await NotificationService.scheduleDaily(
          hour: savedReminder.hour,
          minute: savedReminder.minute,
          title: 'C\'Alma',
          body: 'Reserve um instante para você. A AIA está te esperando para te guiar em um momento de bem-estar. ',
        );
        
        if (notificationId != null) {
          // Atualizar o notification_id no banco
          await _client
              .from('reminders')
              .update({'notification_id': notificationId})
              .eq('id', savedReminder.id!);
          
          debugPrint('✅ REPOSITORY: Notificação agendada - ID: $notificationId');
        }
      }
      
      debugPrint('✅ REPOSITORY: Lembrete salvo com sucesso - ID: ${savedReminder.id}');
      return Right(savedReminder);
    } catch (e) {
      debugPrint('❌ REPOSITORY: Erro ao salvar lembrete: $e');
      return Left('Erro ao salvar lembrete: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, List<ReminderModel>>> saveReminders(List<TimeOfDay> reminders) async {
    try {
      debugPrint('🔄 REPOSITORY: Salvando ${reminders.length} lembretes em lote...');
      
      final user = _client.auth.currentUser;
      if (user == null) {
        debugPrint('❌ REPOSITORY: Usuário não autenticado');
        return const Left('Usuário não autenticado');
      }

      // Validar limite de lembretes (máximo 3)
      if (reminders.length > 3) {
        debugPrint('⚠️ REPOSITORY: Limite de lembretes excedido');
        return const Left('Máximo de 3 lembretes permitidos');
      }

      // Primeiro, excluir todos os lembretes existentes do usuário
      await _client
          .from('reminders')
          .delete()
          .eq('user_id', user.id);

      if (reminders.isEmpty) {
        debugPrint('✅ REPOSITORY: Todos os lembretes removidos');
        return const Right([]);
      }

      // Preparar dados para inserção em lote
      final List<Map<String, dynamic>> dataToInsert = [];
      
      for (final time in reminders) {
        final reminder = ReminderModel.fromTimeOfDay(
          userId: user.id,
          time: time,
        );
        dataToInsert.add(reminder.toJson());
      }

      // Inserir todos os lembretes de uma vez
      final response = await _client
          .from('reminders')
          .insert(dataToInsert)
          .select();

      final List<ReminderModel> savedReminders = [];
      for (final item in response as List) {
        try {
          final reminder = ReminderModel.fromJson(item);
          savedReminders.add(reminder);
        } catch (e) {
          debugPrint('⚠️ REPOSITORY: Erro ao parsear lembrete salvo: $e');
        }
      }

      // Ordenar por horário
      savedReminders.sort((a, b) {
        if (a.hour != b.hour) return a.hour.compareTo(b.hour);
        return a.minute.compareTo(b.minute);
      });

      debugPrint('✅ REPOSITORY: ${savedReminders.length} lembretes salvos em lote com sucesso');
      return Right(savedReminders);
    } catch (e) {
      debugPrint('❌ REPOSITORY: Erro ao salvar lembretes em lote: $e');
      return Left('Erro ao salvar lembretes: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> deleteReminder(String id) async {
    try {
      debugPrint('🔄 REPOSITORY: Excluindo lembrete $id...');
      
      final user = _client.auth.currentUser;
      if (user == null) {
        debugPrint('❌ REPOSITORY: Usuário não autenticado');
        return const Left('Usuário não autenticado');
      }

      // Buscar o lembrete para obter o notification_id antes de excluir
      final existingResponse = await _client
          .from('reminders')
          .select('notification_id')
          .eq('id', id)
          .eq('user_id', user.id);

      if (existingResponse.isEmpty) {
        debugPrint('⚠️ REPOSITORY: Lembrete não encontrado ou não pertence ao usuário');
        return const Left('Lembrete não encontrado');
      }

      // Cancelar notificação se existir
      final notificationId = existingResponse.first['notification_id'] as int?;
      if (notificationId != null) {
        await NotificationService.cancel(notificationId);
        debugPrint('✅ REPOSITORY: Notificação cancelada - ID: $notificationId');
      }

      await _client
          .from('reminders')
          .delete()
          .eq('id', id)
          .eq('user_id', user.id);

      debugPrint('✅ REPOSITORY: Lembrete excluído com sucesso');
      return const Right(null);
    } catch (e) {
      debugPrint('❌ REPOSITORY: Erro ao excluir lembrete: $e');
      return Left('Erro ao excluir lembrete: ${e.toString()}');
    }
  }

  @override
  Future<Either<String, void>> deleteAllReminders() async {
    try {
      debugPrint('🔄 REPOSITORY: Excluindo todos os lembretes do usuário...');
      
      final user = _client.auth.currentUser;
      if (user == null) {
        debugPrint('❌ REPOSITORY: Usuário não autenticado');
        return const Left('Usuário não autenticado');
      }

      // Cancelar todas as notificações antes de excluir
      await NotificationService.cancelAll();
      debugPrint('✅ REPOSITORY: Todas as notificações canceladas');

      await _client
          .from('reminders')
          .delete()
          .eq('user_id', user.id);

      debugPrint('✅ REPOSITORY: Todos os lembretes excluídos com sucesso');
      return const Right(null);
    } catch (e) {
      debugPrint('❌ REPOSITORY: Erro ao excluir todos os lembretes: $e');
      return Left('Erro ao excluir lembretes: ${e.toString()}');
    }
  }

  /// Método adicional para ativar/desativar um lembrete
  Future<Either<String, ReminderModel>> toggleReminderStatus(String id) async {
    try {
      debugPrint('🔄 REPOSITORY: Alternando status do lembrete $id...');
      
      final user = _client.auth.currentUser;
      if (user == null) {
        debugPrint('❌ REPOSITORY: Usuário não autenticado');
        return const Left('Usuário não autenticado');
      }

      // Buscar o lembrete atual
      final currentResponse = await _client
          .from('reminders')
          .select('*')
          .eq('id', id)
          .eq('user_id', user.id)
          .single();

      final currentReminder = ReminderModel.fromJson(currentResponse);
      
      // Alternar o status
      final updatedReminder = currentReminder.copyWith(
        isActive: !currentReminder.isActive,
      );

      // Atualizar no banco
      final response = await _client
          .from('reminders')
          .update({'is_active': updatedReminder.isActive})
          .eq('id', id)
          .eq('user_id', user.id)
          .select()
          .single();

      final savedReminder = ReminderModel.fromJson(response);
      final status = savedReminder.isActive ? 'ativado' : 'desativado';
      debugPrint('✅ REPOSITORY: Lembrete $status com sucesso');
      return Right(savedReminder);
    } catch (e) {
      debugPrint('❌ REPOSITORY: Erro ao alterar status do lembrete: $e');
      return Left('Erro ao alterar status do lembrete: ${e.toString()}');
    }
  }

  /// Método adicional para atualizar o notification_id de um lembrete
  Future<Either<String, ReminderModel>> updateNotificationId(String id, int notificationId) async {
    try {
      debugPrint('🔄 REPOSITORY: Atualizando notification_id do lembrete $id...');
      
      final user = _client.auth.currentUser;
      if (user == null) {
        debugPrint('❌ REPOSITORY: Usuário não autenticado');
        return const Left('Usuário não autenticado');
      }

      final response = await _client
          .from('reminders')
          .update({'notification_id': notificationId})
          .eq('id', id)
          .eq('user_id', user.id)
          .select()
          .single();

      final updatedReminder = ReminderModel.fromJson(response);
      debugPrint('✅ REPOSITORY: Notification ID atualizado com sucesso');
      return Right(updatedReminder);
    } catch (e) {
      debugPrint('❌ REPOSITORY: Erro ao atualizar notification ID: $e');
      return Left('Erro ao atualizar notification ID: ${e.toString()}');
    }
  }

  /// Método adicional para marcar um lembrete como disparado
  Future<Either<String, ReminderModel>> markAsTriggered(String id) async {
    try {
      debugPrint('🔄 REPOSITORY: Marcando lembrete $id como disparado...');
      
      final user = _client.auth.currentUser;
      if (user == null) {
        debugPrint('❌ REPOSITORY: Usuário não autenticado');
        return const Left('Usuário não autenticado');
      }

      final response = await _client
          .from('reminders')
          .update({'last_triggered': DateTime.now().toIso8601String()})
          .eq('id', id)
          .eq('user_id', user.id)
          .select()
          .single();

      final updatedReminder = ReminderModel.fromJson(response);
      debugPrint('✅ REPOSITORY: Lembrete marcado como disparado');
      return Right(updatedReminder);
    } catch (e) {
      debugPrint('❌ REPOSITORY: Erro ao marcar lembrete como disparado: $e');
      return Left('Erro ao marcar lembrete como disparado: ${e.toString()}');
    }
  }

  /// Método adicional para buscar lembretes ativos que devem disparar
  Future<Either<String, List<ReminderModel>>> getActiveRemindersForTime(int hour, int minute) async {
    try {
      debugPrint('🔄 REPOSITORY: Buscando lembretes ativos para ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}...');
      
      final response = await _client
          .from('reminders')
          .select('*')
          .eq('hour', hour)
          .eq('minute', minute)
          .eq('is_active', true);

      final List<ReminderModel> reminders = [];
      
      for (final item in response as List) {
        try {
          final reminder = ReminderModel.fromJson(item);
          // Verificar se deve disparar hoje
          if (reminder.shouldTriggerToday()) {
            reminders.add(reminder);
          }
        } catch (e) {
          debugPrint('⚠️ REPOSITORY: Erro ao parsear lembrete ativo: $e');
        }
      }

      debugPrint('✅ REPOSITORY: ${reminders.length} lembretes ativos encontrados');
      return Right(reminders);
    } catch (e) {
      debugPrint('❌ REPOSITORY: Erro ao buscar lembretes ativos: $e');
      return Left('Erro ao buscar lembretes ativos: ${e.toString()}');
    }
  }
}
