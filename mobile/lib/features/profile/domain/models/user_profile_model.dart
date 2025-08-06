import 'dart:typed_data';

class UserProfileModel {
  final String id;
  final String userId;
  final String preferredName;
  final String gender;
  final String ageRange;
  final List<String> aiaObjectives;
  final String mentalHealthExperience;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? profilePhotoPath; // Caminho para a foto no Storage
  
  // Não armazenado no banco, apenas para uso temporário na memória
  final Uint8List? profilePhotoCache;
  
  // Campos adicionais
  final String? phoneNumber;
  final String? fullName;
  final String? psychologistId; // ID do psicólogo vinculado
  final String? companyId; // ID da empresa
  final String? email; // Email do usuário
  final String? employeeStatus; // Status do funcionário

  const UserProfileModel({
    required this.id,
    required this.userId,
    required this.preferredName,
    required this.gender,
    required this.ageRange,
    required this.aiaObjectives,
    required this.mentalHealthExperience,
    required this.createdAt,
    required this.updatedAt,
    this.profilePhotoPath,
    this.profilePhotoCache,
    this.phoneNumber,
    this.fullName,
    this.psychologistId,
    this.companyId,
    this.email,
    this.employeeStatus,
  });

  /// Cria uma instância a partir de dados JSON do Supabase
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      preferredName: json['preferred_name'] as String,
      gender: json['gender'] as String,
      ageRange: json['age_range'] as String,
      aiaObjectives: List<String>.from(json['aia_objectives'] as List),
      mentalHealthExperience: json['mental_health_experience'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      profilePhotoPath: json['profile_photo'] as String?,
      phoneNumber: json['phone_number'] as String?,
      fullName: json['full_name'] as String?,
      psychologistId: json['psychologist_id'] as String?,
      companyId: json['company_id'] as String?,
      email: json['email'] as String?,
      employeeStatus: json['employee_status'] as String?,
    );
  }

  /// Converte a instância para JSON para envio ao Supabase
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'id': id,
      'user_id': userId,
      'preferred_name': preferredName,
      'gender': gender,
      'age_range': ageRange,
      'aia_objectives': aiaObjectives,
      'mental_health_experience': mentalHealthExperience,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    
    if (profilePhotoPath != null) {
      json['profile_photo'] = profilePhotoPath!;
    }
    
    if (phoneNumber != null) {
      json['phone_number'] = phoneNumber!;
    }
    
    if (fullName != null) {
      json['full_name'] = fullName!;
    }
    
    if (psychologistId != null) {
      json['psychologist_id'] = psychologistId!;
    }
    
    if (companyId != null) {
      json['company_id'] = companyId!;
    }
    
    if (email != null) {
      json['email'] = email!;
    }
    
    if (employeeStatus != null) {
      json['employee_status'] = employeeStatus!;
    }
    
    return json;
  }

  /// Converte para JSON para inserção (sem id, created_at, updated_at)
  Map<String, dynamic> toInsertJson() {
    final Map<String, dynamic> json = {
      'user_id': userId,
      'preferred_name': preferredName,
      'gender': gender,
      'age_range': ageRange,
      'aia_objectives': aiaObjectives,
      'mental_health_experience': mentalHealthExperience,
    };
    
    if (profilePhotoPath != null) {
      json['profile_photo'] = profilePhotoPath!;
    }
    
    if (phoneNumber != null) {
      json['phone_number'] = phoneNumber!;
    }
    
    if (fullName != null) {
      json['full_name'] = fullName!;
    }
    
    if (psychologistId != null) {
      json['psychologist_id'] = psychologistId!;
    }
    
    if (companyId != null) {
      json['company_id'] = companyId!;
    }
    
    if (email != null) {
      json['email'] = email!;
    }
    
    if (employeeStatus != null) {
      json['employee_status'] = employeeStatus!;
    }
    
    return json;
  }

  /// Converte para JSON para atualização (sem id, user_id, created_at)
  Map<String, dynamic> toUpdateJson() {
    final Map<String, dynamic> json = {
      'preferred_name': preferredName,
      'gender': gender,
      'age_range': ageRange,
      'aia_objectives': aiaObjectives,
      'mental_health_experience': mentalHealthExperience,
      'updated_at': DateTime.now().toIso8601String(),
      'psychologist_id': psychologistId, // Incluir explicitamente, mesmo se for null
    };
    
    if (profilePhotoPath != null) {
      json['profile_photo'] = profilePhotoPath!;
    }
    
    if (phoneNumber != null) {
      json['phone_number'] = phoneNumber!;
    }
    
    if (fullName != null) {
      json['full_name'] = fullName!;
    }
    
    // Removido a condição para psychologistId, pois já está incluído acima
    
    if (companyId != null) {
      json['company_id'] = companyId!;
    }
    
    if (email != null) {
      json['email'] = email!;
    }
    
    if (employeeStatus != null) {
      json['employee_status'] = employeeStatus!;
    }
    
    return json;
  }

  /// Cria uma cópia com campos modificados
  UserProfileModel copyWith({
    String? id,
    String? userId,
    String? preferredName,
    String? gender,
    String? ageRange,
    List<String>? aiaObjectives,
    String? mentalHealthExperience,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? profilePhotoPath,
    Uint8List? profilePhotoCache,
    String? phoneNumber,
    String? fullName,
    String? psychologistId,
    String? companyId,
    String? email,
    String? employeeStatus,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      preferredName: preferredName ?? this.preferredName,
      gender: gender ?? this.gender,
      ageRange: ageRange ?? this.ageRange,
      aiaObjectives: aiaObjectives ?? this.aiaObjectives,
      mentalHealthExperience: mentalHealthExperience ?? this.mentalHealthExperience,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      profilePhotoCache: profilePhotoCache ?? this.profilePhotoCache,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      psychologistId: psychologistId ?? this.psychologistId,
      companyId: companyId ?? this.companyId,
      email: email ?? this.email,
      employeeStatus: employeeStatus ?? this.employeeStatus,
    );
  }

  @override
  String toString() {
    return 'UserProfileModel(id: $id, userId: $userId, preferredName: $preferredName, gender: $gender, ageRange: $ageRange, aiaObjectives: $aiaObjectives, mentalHealthExperience: $mentalHealthExperience, psychologistId: $psychologistId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is UserProfileModel &&
      other.id == id &&
      other.userId == userId &&
      other.preferredName == preferredName &&
      other.gender == gender &&
      other.ageRange == ageRange &&
      other.aiaObjectives.toString() == aiaObjectives.toString() &&
      other.mentalHealthExperience == mentalHealthExperience &&
      other.psychologistId == psychologistId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      userId.hashCode ^
      preferredName.hashCode ^
      gender.hashCode ^
      ageRange.hashCode ^
      aiaObjectives.hashCode ^
      mentalHealthExperience.hashCode ^
      (psychologistId?.hashCode ?? 0);
  }
}

/// Constantes para validação e opções
class UserProfileConstants {
  static const List<String> genderOptions = [
    'Masculino',
    'Feminino',
    'Não binário',
  ];

  static const List<String> ageRangeOptions = [
    '18-24',
    '25-34',
    '35-44',
    '45-54',
    '55+',
  ];

  static const List<String> aiaObjectiveOptions = [
    'Acompanhar a minha vida',
    'Libertar emoções',
    'Melhorar o bem-estar mental',
    'Processar os meus pensamentos',
    'Praticar auto-reflexão',
  ];

  static const List<String> mentalHealthExperienceOptions = [
    'Diariamente',
    'Já tentei',
    'Nunca fiz',
  ];
}
