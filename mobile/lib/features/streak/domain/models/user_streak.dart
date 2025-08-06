import 'package:flutter/foundation.dart';

/// Modelo que representa o streak (sequência de dias) de um usuário
class UserStreak {
  final String userId;
  final int currentStreak;
  final DateTime lastLoginDate;
  final DateTime createdAt;
  
  UserStreak({
    required this.userId,
    required this.currentStreak,
    required this.lastLoginDate,
    required this.createdAt,
  });
  
  /// Cria um modelo a partir de um mapa JSON
  factory UserStreak.fromJson(Map<String, dynamic> json) {
    return UserStreak(
      userId: json['user_id'],
      currentStreak: json['current_streak'] ?? 0,
      lastLoginDate: DateTime.parse(json['last_login_date']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
  
  /// Converte o modelo para um mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'current_streak': currentStreak,
      'last_login_date': lastLoginDate.toIso8601String(),
    };
  }
  
  /// Cria uma cópia do modelo com valores atualizados
  UserStreak copyWith({
    String? userId,
    int? currentStreak,
    DateTime? lastLoginDate,
    DateTime? createdAt,
  }) {
    return UserStreak(
      userId: userId ?? this.userId,
      currentStreak: currentStreak ?? this.currentStreak,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  @override
  String toString() {
    return 'UserStreak(userId: $userId, currentStreak: $currentStreak, lastLoginDate: $lastLoginDate)';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is UserStreak &&
        other.userId == userId &&
        other.currentStreak == currentStreak &&
        other.lastLoginDate == lastLoginDate;
  }
  
  @override
  int get hashCode {
    return userId.hashCode ^ currentStreak.hashCode ^ lastLoginDate.hashCode;
  }
}
