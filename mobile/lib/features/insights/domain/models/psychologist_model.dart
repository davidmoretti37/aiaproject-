import 'package:flutter/foundation.dart';

/// Modelo para representar os dados de um psicólogo
class PsychologistModel {
  final String id;
  final String crp;
  final String name;
  final String specialization;
  final String email;
  final String? bio;
  final String? phone;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PsychologistModel({
    required this.id,
    required this.crp,
    required this.name,
    required this.specialization,
    required this.email,
    this.bio,
    this.phone,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  /// Cria uma instância a partir de dados JSON do Supabase
  factory PsychologistModel.fromJson(Map<String, dynamic> json) {
    return PsychologistModel(
      id: json['id'] as String,
      crp: json['crp'] as String,
      name: json['name'] as String,
      specialization: json['specialization'] as String,
      email: json['email'] as String,
      bio: json['bio'] as String?,
      phone: json['phone'] as String?,
      status: json['status'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
    );
  }

  /// Converte a instância para JSON para envio ao Supabase
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'id': id,
      'crp': crp,
      'name': name,
      'specialization': specialization,
      'email': email,
    };
    
    if (bio != null) {
      json['bio'] = bio!;
    }
    
    if (phone != null) {
      json['phone'] = phone!;
    }
    
    if (status != null) {
      json['status'] = status!;
    }
    
    if (createdAt != null) {
      json['created_at'] = createdAt!.toIso8601String();
    }
    
    if (updatedAt != null) {
      json['updated_at'] = updatedAt!.toIso8601String();
    }
    
    return json;
  }

  /// Cria uma cópia com campos modificados
  PsychologistModel copyWith({
    String? id,
    String? crp,
    String? name,
    String? specialization,
    String? email,
    String? bio,
    String? phone,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PsychologistModel(
      id: id ?? this.id,
      crp: crp ?? this.crp,
      name: name ?? this.name,
      specialization: specialization ?? this.specialization,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'PsychologistModel(id: $id, crp: $crp, name: $name, specialization: $specialization, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is PsychologistModel &&
      other.id == id &&
      other.crp == crp &&
      other.name == name &&
      other.specialization == specialization &&
      other.email == email;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      crp.hashCode ^
      name.hashCode ^
      specialization.hashCode ^
      email.hashCode;
  }
}
