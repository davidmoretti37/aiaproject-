import 'package:supabase_flutter/supabase_flutter.dart';

/// UserModel - Modelo de dados para representar um usuário autenticado
///
/// Contém informações básicas do usuário e métodos para serialização/deserialização.
class UserModel {
  final String id;
  final String email;
  final String? name;
  final Map<String, dynamic>? metadata;
  final DateTime? lastSignInAt;
  final DateTime createdAt;
  final DateTime? emailConfirmedAt;
  
  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.metadata,
    this.lastSignInAt,
    DateTime? createdAt,
    this.emailConfirmedAt,
  }) : createdAt = createdAt ?? DateTime.now();
  
  /// Criar a partir de um User do Supabase
  factory UserModel.fromSupabaseUser(User user) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      name: user.userMetadata?['name'] as String?,
      metadata: user.userMetadata,
      lastSignInAt: null, // Não temos acesso direto a este campo
      createdAt: DateTime.now(), // Não temos acesso direto a este campo
      emailConfirmedAt: user.emailConfirmedAt != null 
          ? DateTime.parse(user.emailConfirmedAt!) 
          : null,
    );
  }
  
  /// Criar uma cópia com campos atualizados
  UserModel copyWith({
    String? name,
    Map<String, dynamic>? metadata,
    DateTime? lastSignInAt,
    DateTime? emailConfirmedAt,
  }) {
    return UserModel(
      id: id,
      email: email,
      name: name ?? this.name,
      metadata: metadata ?? this.metadata,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
      createdAt: createdAt,
      emailConfirmedAt: emailConfirmedAt ?? this.emailConfirmedAt,
    );
  }
  
  /// Converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'metadata': metadata,
      'lastSignInAt': lastSignInAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'emailConfirmedAt': emailConfirmedAt?.toIso8601String(),
    };
  }
  
  /// Criar a partir de JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      metadata: json['metadata'],
      lastSignInAt: json['lastSignInAt'] != null 
          ? DateTime.parse(json['lastSignInAt']) 
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      emailConfirmedAt: json['emailConfirmedAt'] != null
          ? DateTime.parse(json['emailConfirmedAt'])
          : null,
    );
  }
  
  /// Verifica se o email foi confirmado
  bool get isEmailConfirmed => emailConfirmedAt != null;

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, name: $name, emailConfirmed: $isEmailConfirmed)';
  }
}
