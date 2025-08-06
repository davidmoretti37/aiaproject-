import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../models/reminder_model.dart';

/// ReminderRepository - Interface para o repositório de lembretes
///
/// Define os métodos para interagir com a tabela de lembretes no Supabase.
abstract class ReminderRepository {
  /// Obtém todos os lembretes do usuário atual
  Future<Either<String, List<ReminderModel>>> getReminders();
  
  /// Salva um lembrete
  /// 
  /// Se o lembrete já existir (id não nulo), atualiza o existente.
  /// Se o lembrete não existir (id nulo), cria um novo.
  Future<Either<String, ReminderModel>> saveReminder(ReminderModel reminder);
  
  /// Salva múltiplos lembretes de uma vez
  /// 
  /// Útil para salvar todos os lembretes configurados na tela de onboarding.
  Future<Either<String, List<ReminderModel>>> saveReminders(List<TimeOfDay> reminders);
  
  /// Exclui um lembrete pelo ID
  Future<Either<String, void>> deleteReminder(String id);
  
  /// Exclui todos os lembretes do usuário atual
  Future<Either<String, void>> deleteAllReminders();
}
