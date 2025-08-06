import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Serviço para gerenciar preferências de notificações
/// Salva localmente quais notificações foram excluídas pelo usuário
class NotificationPreferencesService {
  static const String _dismissedReportsKey = 'dismissed_reports';
  
  /// Marcar uma denúncia como excluída
  static Future<void> dismissReport(String reportId) async {
    try {
      debugPrint('📱 PREFS: Marcando denúncia como excluída: $reportId');
      
      final prefs = await SharedPreferences.getInstance();
      final dismissedReports = prefs.getStringList(_dismissedReportsKey) ?? [];
      
      if (!dismissedReports.contains(reportId)) {
        dismissedReports.add(reportId);
        await prefs.setStringList(_dismissedReportsKey, dismissedReports);
        debugPrint('✅ PREFS: Denúncia $reportId marcada como excluída');
      } else {
        debugPrint('⚠️ PREFS: Denúncia $reportId já estava excluída');
      }
      
    } catch (e) {
      debugPrint('❌ PREFS: Erro ao marcar denúncia como excluída: $e');
    }
  }
  
  /// Verificar se uma denúncia foi excluída
  static Future<bool> isReportDismissed(String reportId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dismissedReports = prefs.getStringList(_dismissedReportsKey) ?? [];
      final isDismissed = dismissedReports.contains(reportId);
      
      debugPrint('🔍 PREFS: Denúncia $reportId excluída: $isDismissed');
      return isDismissed;
      
    } catch (e) {
      debugPrint('❌ PREFS: Erro ao verificar denúncia excluída: $e');
      return false;
    }
  }
  
  /// Obter lista de denúncias excluídas
  static Future<List<String>> getDismissedReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dismissedReports = prefs.getStringList(_dismissedReportsKey) ?? [];
      
      debugPrint('📱 PREFS: ${dismissedReports.length} denúncias excluídas');
      return dismissedReports;
      
    } catch (e) {
      debugPrint('❌ PREFS: Erro ao obter denúncias excluídas: $e');
      return [];
    }
  }
  
  /// Limpar todas as denúncias excluídas (para debug/reset)
  static Future<void> clearDismissedReports() async {
    try {
      debugPrint('🗑️ PREFS: Limpando todas as denúncias excluídas');
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_dismissedReportsKey);
      
      debugPrint('✅ PREFS: Denúncias excluídas limpas');
      
    } catch (e) {
      debugPrint('❌ PREFS: Erro ao limpar denúncias excluídas: $e');
    }
  }
  
  /// Remover uma denúncia específica da lista de excluídas
  static Future<void> undismissReport(String reportId) async {
    try {
      debugPrint('🔄 PREFS: Removendo denúncia da lista de excluídas: $reportId');
      
      final prefs = await SharedPreferences.getInstance();
      final dismissedReports = prefs.getStringList(_dismissedReportsKey) ?? [];
      
      if (dismissedReports.contains(reportId)) {
        dismissedReports.remove(reportId);
        await prefs.setStringList(_dismissedReportsKey, dismissedReports);
        debugPrint('✅ PREFS: Denúncia $reportId removida da lista de excluídas');
      } else {
        debugPrint('⚠️ PREFS: Denúncia $reportId não estava na lista de excluídas');
      }
      
    } catch (e) {
      debugPrint('❌ PREFS: Erro ao remover denúncia da lista de excluídas: $e');
    }
  }
}
