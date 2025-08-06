import 'package:flutter/material.dart';
import 'package:calma_flutter/core/services/supabase_service.dart';
import 'package:calma_flutter/features/streak/domain/models/user_streak.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Serviço para gerenciar o streak (sequência de dias) do usuário
class StreakService {
  final SupabaseClient _client = SupabaseService.client;
  int _currentStreak = 0;
  
  /// Retorna o streak atual do usuário
  int get currentStreak => _currentStreak;
  
  /// Verifica e atualiza o streak do usuário com base na data do último login
  Future<void> checkAndUpdateStreak() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      debugPrint('❌ STREAK: Usuário não autenticado');
      return;
    }
    
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Buscar streak atual do usuário
      final response = await _client
          .from('user_streaks')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      // Se não encontrou registro, criar um novo
      if (response == null) {
        debugPrint('🔍 STREAK: Nenhum registro encontrado, criando novo streak');
        await _createNewStreak(userId, today);
        return;
      }
      
      // Processar streak existente
      final streakData = response as Map<String, dynamic>;
      final lastLoginDate = DateTime.parse(streakData['last_login_date']);
      final lastLoginDay = DateTime(lastLoginDate.year, lastLoginDate.month, lastLoginDate.day);
      int currentStreak = streakData['current_streak'] ?? 0;
      
      debugPrint('🔍 STREAK: Streak atual: $currentStreak, último login: ${lastLoginDay.toIso8601String()}');
      
      // Calcular diferença em dias
      final difference = today.difference(lastLoginDay).inDays;
      debugPrint('🔍 STREAK: Diferença em dias: $difference');
      
      if (difference == 0) {
        // Mesmo dia, não faz nada
        debugPrint('✅ STREAK: Mesmo dia, mantendo streak em $currentStreak');
        _currentStreak = currentStreak;
      } else if (difference == 1) {
        // Dia seguinte, incrementa o streak
        currentStreak += 1;
        debugPrint('🔥 STREAK: Dia consecutivo! Incrementando streak para $currentStreak');
        await _updateStreak(userId, currentStreak, today);
      } else {
        // Mais de um dia, reseta o streak
        debugPrint('⚠️ STREAK: Mais de um dia sem login, resetando streak');
        await _updateStreak(userId, 1, today);
      }
      
    } catch (e) {
      debugPrint('❌ STREAK: Erro ao verificar streak: $e');
    }
  }
  
  /// Cria um novo registro de streak para o usuário
  Future<void> _createNewStreak(String userId, DateTime today) async {
    try {
      await _client
          .from('user_streaks')
          .insert({
            'user_id': userId,
            'current_streak': 1,
            'last_login_date': today.toIso8601String(),
          });
      
      _currentStreak = 1;
      debugPrint('✅ STREAK: Novo streak criado para o usuário');
    } catch (e) {
      debugPrint('❌ STREAK: Erro ao criar novo streak: $e');
    }
  }
  
  /// Atualiza o streak do usuário
  Future<void> _updateStreak(String userId, int newStreak, DateTime today) async {
    try {
      await _client
          .from('user_streaks')
          .update({
            'current_streak': newStreak,
            'last_login_date': today.toIso8601String(),
          })
          .eq('user_id', userId);
      
      _currentStreak = newStreak;
      debugPrint('✅ STREAK: Streak atualizado para $newStreak');
    } catch (e) {
      debugPrint('❌ STREAK: Erro ao atualizar streak: $e');
    }
  }
  
  /// Obtém o streak atual do usuário sem atualizá-lo
  Future<int> getCurrentStreakValue() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return 0;
    
    try {
      final response = await _client
          .from('user_streaks')
          .select('current_streak')
          .eq('user_id', userId)
          .maybeSingle();
      
      if (response == null) {
        return 0;
      }
      
      final streakData = response as Map<String, dynamic>;
      return streakData['current_streak'] ?? 0;
    } catch (e) {
      debugPrint('❌ STREAK: Erro ao obter valor do streak: $e');
      return 0;
    }
  }
}
