import 'package:flutter/material.dart';

class AiContentReport {
  final String id;
  final String userId;
  final String category;
  final String description;
  final DateTime timestampOfIncident;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? adminNotes;
  final String? adminName;

  const AiContentReport({
    required this.id,
    required this.userId,
    required this.category,
    required this.description,
    required this.timestampOfIncident,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.reviewedBy,
    this.reviewedAt,
    this.adminNotes,
    this.adminName,
  });

  factory AiContentReport.fromJson(Map<String, dynamic> json) {
    return AiContentReport(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      timestampOfIncident: DateTime.parse(json['timestamp_of_incident'] as String),
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
      reviewedBy: json['reviewed_by'] as String?,
      reviewedAt: json['reviewed_at'] != null 
          ? DateTime.parse(json['reviewed_at'] as String) 
          : null,
      adminNotes: json['admin_notes'] as String?,
      adminName: json['admin_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category': category,
      'description': description,
      'timestamp_of_incident': timestampOfIncident.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'reviewed_by': reviewedBy,
      'reviewed_at': reviewedAt?.toIso8601String(),
      'admin_notes': adminNotes,
      'admin_name': adminName,
    };
  }

  String get statusDisplayName {
    switch (status) {
      case 'pending':
        return 'Pendente';
      case 'in_review':
        return 'Em análise';
      case 'resolved':
        return 'Resolvido';
      case 'rejected':
        return 'Rejeitado';
      default:
        return 'Desconhecido';
    }
  }

  Color get statusColor {
    switch (status) {
      case 'pending':
        return const Color(0xFFFFA726); // Laranja
      case 'in_review':
        return const Color(0xFF42A5F5); // Azul
      case 'resolved':
        return const Color(0xFF66BB6A); // Verde
      case 'rejected':
        return const Color(0xFFEF5350); // Vermelho
      default:
        return const Color(0xFF9E9E9E); // Cinza
    }
  }

  bool get isResolved => status == 'resolved';
  bool get hasAdminResponse => adminNotes != null && adminNotes!.isNotEmpty;

  String get categoryDisplayName {
    // Se a categoria já está em português, retornar diretamente
    if (!category.contains('_')) {
      return category;
    }
    
    // Mapeamento de traduções para categorias antigas em inglês
    final translations = {
      'inappropriate_content': 'Conteúdo Inadequado',
      'technical_issue': 'Problema Técnico',
      'misinformation': 'Informação Incorreta',
      'harassment': 'Assédio',
      'spam': 'Spam',
      'other': 'Outro',
      'offensive_language': 'Linguagem Ofensiva',
      'privacy_violation': 'Violação de Privacidade',
      'false_information': 'Informação Falsa',
      'inappropriate_behavior': 'Comportamento Inadequado',
      'content_quality': 'Qualidade do Conteúdo',
      'safety_concern': 'Preocupação de Segurança',
    };
    
    // Retornar tradução se disponível
    if (translations.containsKey(category.toLowerCase())) {
      return translations[category.toLowerCase()]!;
    }
    
    // Caso contrário, formatar categoria removendo underlines e capitalizando
    return category
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty 
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : word)
        .join(' ');
  }
}
