import 'package:flutter/material.dart';

/// Modelo para representar uma sessão de conversa com a AIA
class CallSessionModel {
  final String id;
  final String userId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int? durationSec;
  final Map<String, dynamic>? conversationData;
  final String? mood;
  final String? summary;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CallSessionModel({
    required this.id,
    required this.userId,
    required this.startedAt,
    this.endedAt,
    this.durationSec,
    this.conversationData,
    this.mood,
    this.summary,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Cria uma instância a partir de dados JSON do Supabase
  factory CallSessionModel.fromJson(Map<String, dynamic> json) {
    return CallSessionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
      endedAt: json['ended_at'] != null 
          ? DateTime.parse(json['ended_at'] as String) 
          : null,
      durationSec: json['duration_sec'] as int?,
      conversationData: json['conversation_data'] as Map<String, dynamic>?,
      mood: json['mood'] as String?,
      summary: json['summary'] as String?,
      createdAt: DateTime.parse(json['started_at'] as String), // Usar started_at como created_at
      updatedAt: DateTime.parse(json['started_at'] as String), // Usar started_at como updated_at
    );
  }

  /// Converte para JSON para envio ao Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'duration_sec': durationSec,
      'conversation_data': conversationData,
      'mood': mood,
      'summary': summary,
    };
  }

  /// Retorna o ícone correspondente ao mood
  IconData getMoodIcon() {
    switch (mood?.toLowerCase()) {
      case 'feliz':
        return Icons.sentiment_very_satisfied;
      case 'triste':
        return Icons.sentiment_very_dissatisfied;
      case 'ansioso':
        return Icons.sentiment_dissatisfied;
      case 'neutro':
        return Icons.sentiment_neutral;
      case 'irritado':
        return Icons.mood_bad;
      default:
        return Icons.sentiment_neutral;
    }
  }

  /// Retorna a cor de fundo do quadrado do mood
  Color getMoodBackgroundColor() {
    switch (mood?.toLowerCase()) {
      case 'feliz':
        return const Color(0xFFE8F5E8); // Verde claro
      case 'triste':
        return const Color(0xFFE3F2FD); // Azul claro
      case 'ansioso':
        return const Color(0xFFFFF3E0); // Laranja claro
      case 'neutro':
        return const Color(0xFFFFF5D3); // Amarelo claro
      case 'irritado':
        return const Color(0xFFFFEBEE); // Vermelho claro
      default:
        return const Color(0xFFE8F5E8); // Verde claro (neutro)
    }
  }

  /// Retorna a cor do ícone do mood
  Color getMoodIconColor() {
    switch (mood?.toLowerCase()) {
      case 'feliz':
        return const Color(0xFF388E3C); // Verde forte
      case 'triste':
        return const Color(0xFF1976D2); // Azul forte
      case 'ansioso':
        return const Color(0xFFFF933B); // Laranja forte
      case 'neutro':
        return const Color(0xFFF5CC00); // Amarelo forte
      case 'irritado':
        return const Color(0xFFD32F2F); // Vermelho forte
      default:
        return const Color(0xFF388E3C); // Verde forte (neutro)
    }
  }

  /// Retorna uma descrição amigável do mood
  String getMoodDescription() {
    switch (mood?.toLowerCase()) {
      case 'feliz':
        return 'Feliz';
      case 'triste':
        return 'Triste';
      case 'ansioso':
        return 'Ansioso';
      case 'neutro':
        return 'Neutro';
      case 'irritado':
        return 'Irritado';
      default:
        return 'Neutro';
    }
  }

  /// Verifica se a sessão tem dados válidos para exibição
  bool get hasValidData => mood != null && summary != null && summary!.isNotEmpty;

  /// Retorna o summary truncado se for muito longo
  String get truncatedSummary {
    if (summary == null || summary!.isEmpty) return 'Sem resumo disponível';
    if (summary!.length <= 150) return summary!;
    return '${summary!.substring(0, 147)}...';
  }

  /// Cria uma cópia com campos modificados
  CallSessionModel copyWith({
    String? id,
    String? userId,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationSec,
    Map<String, dynamic>? conversationData,
    String? mood,
    String? summary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CallSessionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSec: durationSec ?? this.durationSec,
      conversationData: conversationData ?? this.conversationData,
      mood: mood ?? this.mood,
      summary: summary ?? this.summary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'CallSessionModel(id: $id, mood: $mood, summary: ${summary?.substring(0, 50)}...)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CallSessionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
