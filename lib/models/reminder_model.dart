class ReminderModel {
  final String id;
  final String userId;
  final String eventName;
  final DateTime reminderTime;
  final String status;
  final int leadTimeDays;
  final int leadTimeMinutes;
  final int leadTimeSeconds;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReminderModel({
    required this.id,
    required this.userId,
    required this.eventName,
    required this.reminderTime,
    required this.status,
    required this.leadTimeDays,
    required this.leadTimeMinutes,
    required this.leadTimeSeconds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      eventName: json['event_name'] as String,
      reminderTime: DateTime.parse(json['reminder_time'] as String),
      status: json['status'] as String,
      leadTimeDays: json['lead_time_days'] as int? ?? 0,
      leadTimeMinutes: json['lead_time_minutes'] as int? ?? 0,
      leadTimeSeconds: json['lead_time_seconds'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'event_name': eventName,
      'reminder_time': reminderTime.toIso8601String(),
      'status': status,
      'lead_time_days': leadTimeDays,
      'lead_time_minutes': leadTimeMinutes,
      'lead_time_seconds': leadTimeSeconds,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Getters úteis
  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  
  bool get isOverdue {
    return isActive && reminderTime.isBefore(DateTime.now());
  }
  
  bool get isUpcoming {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    return isActive && reminderTime.isAfter(now) && reminderTime.isBefore(tomorrow);
  }

  Duration get timeUntilReminder {
    return reminderTime.difference(DateTime.now());
  }

  String get formattedReminderTime {
    final now = DateTime.now();
    final difference = reminderTime.difference(now);
    
    if (difference.isNegative) {
      final pastDifference = now.difference(reminderTime);
      if (pastDifference.inDays > 0) {
        return '${pastDifference.inDays} days ago';
      } else if (pastDifference.inHours > 0) {
        return '${pastDifference.inHours} hours ago';
      } else {
        return '${pastDifference.inMinutes} minutes ago';
      }
    } else {
      if (difference.inDays > 0) {
        return 'In ${difference.inDays} days';
      } else if (difference.inHours > 0) {
        return 'In ${difference.inHours} hours';
      } else {
        return 'In ${difference.inMinutes} minutes';
      }
    }
  }

  String get formattedDateTime {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reminderDate = DateTime(reminderTime.year, reminderTime.month, reminderTime.day);
    
    if (reminderDate == today) {
      return 'Today at ${_formatTime(reminderTime)}';
    } else if (reminderDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow at ${_formatTime(reminderTime)}';
    } else if (reminderDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday at ${_formatTime(reminderTime)}';
    } else {
      return '${_formatDate(reminderTime)} at ${_formatTime(reminderTime)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    return '$day/$month/$year';
  }

  ReminderModel copyWith({
    String? id,
    String? userId,
    String? eventName,
    DateTime? reminderTime,
    String? status,
    int? leadTimeDays,
    int? leadTimeMinutes,
    int? leadTimeSeconds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventName: eventName ?? this.eventName,
      reminderTime: reminderTime ?? this.reminderTime,
      status: status ?? this.status,
      leadTimeDays: leadTimeDays ?? this.leadTimeDays,
      leadTimeMinutes: leadTimeMinutes ?? this.leadTimeMinutes,
      leadTimeSeconds: leadTimeSeconds ?? this.leadTimeSeconds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
