import 'package:flutter/material.dart';

/// Modelo para representar os insights de uma sessão de conversa
class SessionInsightModel {
  final int id;
  final String sessionId;
  final DateTime createdAt;
  final List<String> topics;
  final String? aiAdvice;
  final String? longSummary;

  const SessionInsightModel({
    required this.id,
    required this.sessionId,
    required this.createdAt,
    required this.topics,
    this.aiAdvice,
    this.longSummary,
  });

  /// Cria uma instância a partir de dados JSON do Supabase
  factory SessionInsightModel.fromJson(Map<String, dynamic> json) {
    return SessionInsightModel(
      id: json['id'] as int,
      sessionId: json['session_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      topics: (json['topics'] as List<dynamic>?)?.cast<String>() ?? [],
      aiAdvice: json['ai_advice'] as String?,
      longSummary: json['long_summary'] as String?,
    );
  }

  /// Converte para JSON para envio ao Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'created_at': createdAt.toIso8601String(),
      'topics': topics,
      'ai_advice': aiAdvice,
      'long_summary': longSummary,
    };
  }

  /// Cria uma cópia com campos modificados
  SessionInsightModel copyWith({
    int? id,
    String? sessionId,
    DateTime? createdAt,
    List<String>? topics,
    String? aiAdvice,
    String? longSummary,
  }) {
    return SessionInsightModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      createdAt: createdAt ?? this.createdAt,
      topics: topics ?? this.topics,
      aiAdvice: aiAdvice ?? this.aiAdvice,
      longSummary: longSummary ?? this.longSummary,
    );
  }

  @override
  String toString() {
    return 'SessionInsightModel(id: $id, sessionId: $sessionId, topics: ${topics.length} items)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SessionInsightModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
