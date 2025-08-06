import 'package:calma_flutter/core/services/supabase_service.dart';
import 'package:calma_flutter/features/reports/data/models/ai_content_report.dart';

class ReportsRepository {
  /// Busca todas as denúncias de um usuário
  Future<List<AiContentReport>> getUserReports(String userId) async {
    try {
      final response = await SupabaseService.client
          .from('ai_content_reports')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => AiContentReport.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar denúncias: $e');
    }
  }

  /// Busca uma denúncia específica por ID
  Future<AiContentReport?> getReportById(String reportId) async {
    try {
      final response = await SupabaseService.client
          .from('ai_content_reports')
          .select('*')
          .eq('id', reportId)
          .single();

      return AiContentReport.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar denúncia: $e');
    }
  }

  /// Cria uma nova denúncia
  Future<AiContentReport> createReport({
    required String userId,
    required String category,
    required String description,
    required DateTime timestampOfIncident,
  }) async {
    try {
      final response = await SupabaseService.client
          .from('ai_content_reports')
          .insert({
            'user_id': userId,
            'category': category,
            'description': description,
            'timestamp_of_incident': timestampOfIncident.toIso8601String(),
            'status': 'pending',
          })
          .select()
          .single();

      return AiContentReport.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar denúncia: $e');
    }
  }

  /// Busca denúncias com status específico para um usuário
  Future<List<AiContentReport>> getUserReportsByStatus(
    String userId, 
    String status,
  ) async {
    try {
      final response = await SupabaseService.client
          .from('ai_content_reports')
          .select('*')
          .eq('user_id', userId)
          .eq('status', status)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => AiContentReport.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar denúncias por status: $e');
    }
  }

  /// Conta o número de denúncias pendentes de um usuário
  Future<int> getUserPendingReportsCount(String userId) async {
    try {
      final response = await SupabaseService.client
          .from('ai_content_reports')
          .select('id')
          .eq('user_id', userId)
          .eq('status', 'pending');

      return (response as List).length;
    } catch (e) {
      throw Exception('Erro ao contar denúncias pendentes: $e');
    }
  }

  /// Conta o número de denúncias resolvidas de um usuário
  Future<int> getUserResolvedReportsCount(String userId) async {
    try {
      final response = await SupabaseService.client
          .from('ai_content_reports')
          .select('id')
          .eq('user_id', userId)
          .eq('status', 'resolved');

      return (response as List).length;
    } catch (e) {
      throw Exception('Erro ao contar denúncias resolvidas: $e');
    }
  }
}
