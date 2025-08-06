import 'package:calma_flutter/features/insights/domain/models/psychologist_model.dart';

/// Interface para o repositório de psicólogos
abstract class PsychologistRepository {
  /// Busca um psicólogo pelo ID
  Future<PsychologistModel?> getPsychologistById(String id);
  
  /// Busca psicólogos por nome, email ou CRP
  Future<List<PsychologistModel>> searchPsychologists(String query);
  
  /// Obtém todos os psicólogos cadastrados
  Future<List<PsychologistModel>> getAllPsychologists();
}
