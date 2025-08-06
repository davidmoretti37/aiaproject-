import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:calma_flutter/features/insights/domain/models/psychologist_model.dart';
import 'package:calma_flutter/features/insights/domain/repositories/psychologist_repository.dart';

/// Implementação do repositório de psicólogos usando Supabase
class PsychologistRepositoryImpl implements PsychologistRepository {
  final SupabaseClient _supabase;
  static const String _tableName = 'psychologists';

  PsychologistRepositoryImpl(this._supabase);

  @override
  Future<PsychologistModel?> getPsychologistById(String id) async {
    try {
      debugPrint('🔄 [PsychologistRepository] Buscando psicólogo com ID: $id');
      
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        debugPrint('ℹ️ [PsychologistRepository] Psicólogo não encontrado para ID: $id');
        return null;
      }

      debugPrint('✅ [PsychologistRepository] Psicólogo encontrado');
      return PsychologistModel.fromJson(response);
    } catch (e) {
      debugPrint('❌ [PsychologistRepository] Erro ao buscar psicólogo: $e');
      return null;
    }
  }
  
  @override
  Future<List<PsychologistModel>> searchPsychologists(String query) async {
    try {
      debugPrint('🔄 [PsychologistRepository] Buscando psicólogos com query: $query');
      
      final response = await _supabase
          .from(_tableName)
          .select()
          .or('name.ilike.%$query%,email.ilike.%$query%,crp.ilike.%$query%')
          .order('name', ascending: true);

      debugPrint('✅ [PsychologistRepository] Psicólogos encontrados: ${response.length}');
      return response.map<PsychologistModel>((json) => PsychologistModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ [PsychologistRepository] Erro ao buscar psicólogos: $e');
      return [];
    }
  }

  @override
  Future<List<PsychologistModel>> getAllPsychologists() async {
    try {
      debugPrint('🔄 [PsychologistRepository] Buscando todos os psicólogos');
      
      final response = await _supabase
          .from(_tableName)
          .select()
          .order('name', ascending: true);

      debugPrint('✅ [PsychologistRepository] Psicólogos encontrados: ${response.length}');
      return response.map<PsychologistModel>((json) => PsychologistModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ [PsychologistRepository] Erro ao buscar todos os psicólogos: $e');
      return [];
    }
  }
}
