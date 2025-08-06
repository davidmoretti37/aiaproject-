import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:calma_flutter/core/di/injection.dart';
import 'package:calma_flutter/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:calma_flutter/core/services/supabase_service.dart';

/// Serviço para gerenciar convites de psicólogos
///
/// Responsável por enviar convites para psicólogos através da API
class PsychologistInvitationService {
  // URL base do backend - substitua pelo URL real em produção
  // Em desenvolvimento, use o IP da sua máquina para testes
  // Exemplos:
  // - Local: 'http://192.168.1.100:3000' (substitua pelo seu IP local)
  // - Produção: 'https://api.calma.app'
  final String _baseUrl = 'http://192.168.0.73:3000';
  final Dio _dio = Dio();
  final SupabaseClient _supabase;
  
  PsychologistInvitationService(this._supabase);
  
  /// Envia um convite para o psicólogo com o ID fornecido
  /// Registra o convite na tabela psychologists_patients
  Future<bool> sendInvitation(String psychologistId) async {
    try {
      debugPrint('🔄 INVITATION: Enviando convite para psicólogo ID: $psychologistId');
      
      // Obter ID do paciente atual
      final authViewModel = getIt<AuthViewModel>();
      final currentUser = authViewModel.currentUser;
      
      if (currentUser == null) {
        debugPrint('❌ INVITATION: Usuário não autenticado');
        throw Exception('Usuário não autenticado');
      }
      
      // Verificar se já existe um convite pendente ou relação ativa
      final existingRelation = await _supabase
          .from('psychologists_patients')
          .select()
          .eq('patient_id', currentUser.id)
          .or('status.eq.pending,status.eq.active')
          .maybeSingle();
      
      if (existingRelation != null) {
        final status = existingRelation['status'];
        if (status == 'active') {
          throw Exception('Você já está conectado a um psicólogo');
        } else {
          throw Exception('Você já enviou um convite para um psicólogo');
        }
      }
      
      // Criar novo convite na tabela psychologists_patients
      await _supabase
          .from('psychologists_patients')
          .insert({
            'patient_id': currentUser.id,
            'psychologist_id': psychologistId,
            'status': 'pending',
          });
      
      debugPrint('✅ INVITATION: Convite registrado com sucesso');
      return true;
    } catch (e) {
      debugPrint('❌ INVITATION: Exceção: $e');
      rethrow;
    }
  }
  
  /// Envia um convite para o psicólogo com o email fornecido
  /// Mantido para compatibilidade com o código existente
  Future<bool> sendInvitationByEmail(String email) async {
    try {
      debugPrint('🔄 INVITATION: Enviando convite para: $email');
      
      // Obter ID do paciente atual
      final authViewModel = getIt<AuthViewModel>();
      final currentUser = authViewModel.currentUser;
      
      if (currentUser == null) {
        debugPrint('❌ INVITATION: Usuário não autenticado');
        throw Exception('Usuário não autenticado');
      }
      
      // Verificar se já existe um convite pendente ou relação ativa
      final existingRelation = await _supabase
          .from('psychologists_patients')
          .select()
          .eq('patient_id', currentUser.id)
          .or('status.eq.pending,status.eq.active')
          .maybeSingle();
      
      if (existingRelation != null) {
        final status = existingRelation['status'];
        if (status == 'active') {
          throw Exception('Você já está conectado a um psicólogo');
        } else {
          throw Exception('Você já enviou um convite para um psicólogo');
        }
      }
      
      debugPrint('🔄 INVITATION: ID do paciente: ${currentUser.id}');
      
      final url = '$_baseUrl/invite-psychologist';
      
      debugPrint('🔄 INVITATION: Enviando requisição para: $url');
      
      final response = await _dio.post(
        url,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
        data: {
          'email': email,
          'patient_id': currentUser.id,
        },
      );
      
      debugPrint('🔄 INVITATION: Status da resposta: ${response.statusCode}');
      debugPrint('🔄 INVITATION: Corpo da resposta: ${response.data}');
      
      if (response.statusCode == 200) {
        debugPrint('✅ INVITATION: Convite enviado com sucesso');
        return true;
      } else {
        final errorData = response.data;
        final errorMessage = errorData['error'] ?? 'Erro ao enviar convite';
        debugPrint('❌ INVITATION: Erro: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('❌ INVITATION: Exceção: $e');
      
      // Se for um erro de conexão, fornecer uma mensagem mais amigável
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout || 
            e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.unknown) {
          throw Exception('Não foi possível conectar ao servidor. Verifique sua conexão com a internet.');
        }
      }
      
      rethrow;
    }
  }
}
