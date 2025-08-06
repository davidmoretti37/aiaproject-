import 'package:flutter/material.dart';

/// ReminderModel - Modelo de dados para representar um lembrete
///
/// Alinhado com a estrutura da tabela reminders do Supabase.
/// Usa campos separados de hora e minuto para melhor performance e validação.
class ReminderModel {
  /// ID único do lembrete
  final String? id;
  
  /// ID do usuário ao qual o lembrete pertence
  final String userId;
  
  /// Hora do lembrete (0-23)
  final int hour;
  
  /// Minuto do lembrete (0-59)
  final int minute;
  
  /// Se o lembrete está ativo
  final bool isActive;
  
  /// ID da notificação local para cancelamento
  final int? notificationId;
  
  /// Última vez que o lembrete foi disparado
  final DateTime? lastTriggered;
  
  /// Data de criação do lembrete
  final DateTime? createdAt;
  
  /// Data de atualização do lembrete
  final DateTime? updatedAt;
  
  /// Construtor do ReminderModel
  ReminderModel({
    this.id,
    required this.userId,
    required this.hour,
    required this.minute,
    this.isActive = true,
    this.notificationId,
    this.lastTriggered,
    this.createdAt,
    this.updatedAt,
  }) : assert(hour >= 0 && hour <= 23, 'Hora deve estar entre 0 e 23'),
       assert(minute >= 0 && minute <= 59, 'Minuto deve estar entre 0 e 59');
  
  /// Criar uma cópia com campos atualizados
  ReminderModel copyWith({
    String? id,
    String? userId,
    int? hour,
    int? minute,
    bool? isActive,
    int? notificationId,
    DateTime? lastTriggered,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      isActive: isActive ?? this.isActive,
      notificationId: notificationId ?? this.notificationId,
      lastTriggered: lastTriggered ?? this.lastTriggered,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// Converter para JSON (formato do Supabase)
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'user_id': userId,
      'hour': hour,
      'minute': minute,
      'is_active': isActive,
    };
    
    // Só incluir campos opcionais se não forem nulos
    if (id != null) json['id'] = id;
    if (notificationId != null) json['notification_id'] = notificationId;
    if (lastTriggered != null) json['last_triggered'] = lastTriggered!.toIso8601String();
    if (createdAt != null) json['created_at'] = createdAt!.toIso8601String();
    if (updatedAt != null) json['updated_at'] = updatedAt!.toIso8601String();
    
    return json;
  }
  
  /// Criar a partir de JSON (formato do Supabase)
  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'],
      userId: json['user_id'],
      hour: json['hour'],
      minute: json['minute'],
      isActive: json['is_active'] ?? true,
      notificationId: json['notification_id'],
      lastTriggered: json['last_triggered'] != null 
          ? DateTime.parse(json['last_triggered']) 
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }
  
  /// Converter para TimeOfDay (para uso na UI)
  TimeOfDay toTimeOfDay() {
    return TimeOfDay(hour: hour, minute: minute);
  }
  
  /// Criar a partir de TimeOfDay
  factory ReminderModel.fromTimeOfDay({
    String? id,
    required String userId,
    required TimeOfDay time,
    bool isActive = true,
    int? notificationId,
    DateTime? lastTriggered,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    // Garantir que userId não seja nulo
    if (userId.isEmpty) {
      throw ArgumentError('userId não pode ser vazio');
    }
    
    return ReminderModel(
      id: id,
      userId: userId,
      hour: time.hour,
      minute: time.minute,
      isActive: isActive,
      notificationId: notificationId,
      lastTriggered: lastTriggered,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
  
  /// Converter para string no formato "HH:MM" (para exibição)
  String toTimeString() {
    final hourStr = hour.toString().padLeft(2, '0');
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr';
  }
  
  /// Verificar se o lembrete deve disparar hoje
  bool shouldTriggerToday() {
    if (!isActive) return false;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Se nunca disparou ou última vez foi em outro dia
    if (lastTriggered == null) return true;
    
    final lastTriggerDate = DateTime(
      lastTriggered!.year,
      lastTriggered!.month,
      lastTriggered!.day,
    );
    
    return lastTriggerDate.isBefore(today);
  }
  
  /// Verificar se já passou do horário hoje
  bool hasPassedTimeToday() {
    final now = DateTime.now();
    final reminderTime = DateTime(now.year, now.month, now.day, hour, minute);
    return now.isAfter(reminderTime);
  }
  
  @override
  String toString() {
    return 'ReminderModel(id: $id, userId: $userId, time: ${toTimeString()}, isActive: $isActive)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReminderModel &&
        other.id == id &&
        other.userId == userId &&
        other.hour == hour &&
        other.minute == minute &&
        other.isActive == isActive;
  }
  
  @override
  int get hashCode {
    return Object.hash(id, userId, hour, minute, isActive);
  }
}
