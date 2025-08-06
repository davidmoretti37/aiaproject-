import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:calma_flutter/core/services/supabase_service.dart';
import 'package:calma_flutter/core/services/notification_service.dart';
import 'package:calma_flutter/core/services/deep_link_service.dart';

/// Serviço para monitorar denúncias e enviar notificações quando admin responder
class ReportsNotificationService {
  static ReportsNotificationService? _instance;
  static ReportsNotificationService get instance => _instance ??= ReportsNotificationService._();
  
  ReportsNotificationService._();
  
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  StreamSubscription<List<Map<String, dynamic>>>? _subscription;
  bool _isListening = false;
  String? _currentUserId;
  Set<String> _notifiedReports = {}; // Para evitar notificações duplicadas
  
  /// Iniciar monitoramento de denúncias para o usuário atual
  Future<void> startListening(String userId) async {
    try {
      debugPrint('🔔 REPORTS_NOTIFICATION: Iniciando monitoramento para usuário: $userId');
      
      // Parar monitoramento anterior se existir
      await stopListening();
      
      _currentUserId = userId;
      
      // Inicializar serviço de notificações se necessário
      await NotificationService.initialize();
      
      // Criar subscription para mudanças na tabela ai_content_reports
      _subscription = SupabaseService.client
          .from('ai_content_reports')
          .stream(primaryKey: ['id'])
          .eq('user_id', userId)
          .listen(
            _onReportsChanged,
            onError: _onError,
          );
      
      _isListening = true;
      debugPrint('✅ REPORTS_NOTIFICATION: Monitoramento iniciado com sucesso');
      
    } catch (e) {
      debugPrint('❌ REPORTS_NOTIFICATION: Erro ao iniciar monitoramento: $e');
    }
  }
  
  /// Parar monitoramento
  Future<void> stopListening() async {
    try {
      debugPrint('🔔 REPORTS_NOTIFICATION: Parando monitoramento...');
      
      await _subscription?.cancel();
      _subscription = null;
      _isListening = false;
      _currentUserId = null;
      
      debugPrint('✅ REPORTS_NOTIFICATION: Monitoramento parado');
      
    } catch (e) {
      debugPrint('❌ REPORTS_NOTIFICATION: Erro ao parar monitoramento: $e');
    }
  }
  
  /// Callback quando há mudanças nas denúncias
  void _onReportsChanged(List<Map<String, dynamic>> data) {
    try {
      debugPrint('🔔 REPORTS_NOTIFICATION: Mudanças detectadas: ${data.length} registros');
      
      for (final report in data) {
        _checkForNewResponse(report);
      }
      
    } catch (e) {
      debugPrint('❌ REPORTS_NOTIFICATION: Erro ao processar mudanças: $e');
    }
  }
  
  /// Verificar se há nova resposta do admin
  void _checkForNewResponse(Map<String, dynamic> reportData) {
    try {
      final reportId = reportData['id'] as String?;
      final status = reportData['status'] as String?;
      final adminNotes = reportData['admin_notes'] as String?;
      final reviewedAt = reportData['reviewed_at'] as String?;
      final category = reportData['category'] as String?;
      
      debugPrint('🔔 REPORTS_NOTIFICATION: Verificando denúncia $reportId');
      debugPrint('🔔 REPORTS_NOTIFICATION: Status: $status');
      debugPrint('🔔 REPORTS_NOTIFICATION: Admin Notes: ${adminNotes?.isNotEmpty == true ? "Presente" : "Ausente"}');
      debugPrint('🔔 REPORTS_NOTIFICATION: Reviewed At: ${reviewedAt != null ? "Presente" : "Ausente"}');
      
      // Verificar se a denúncia foi respondida (status resolved OU in_review com resposta)
      final hasResponse = adminNotes != null && adminNotes.isNotEmpty;
      final isResolved = status == 'resolved';
      final isInReview = status == 'in_review';
      
      if ((isResolved || isInReview) && hasResponse) {
        // Verificar se já enviamos notificação para esta denúncia
        if (_notifiedReports.contains(reportId)) {
          debugPrint('⚠️ REPORTS_NOTIFICATION: Notificação já enviada para denúncia $reportId');
          return;
        }
        
        debugPrint('✅ REPORTS_NOTIFICATION: Nova resposta detectada para denúncia $reportId');
        debugPrint('✅ REPORTS_NOTIFICATION: Enviando notificação...');
        
        // Marcar como notificado antes de enviar
        _notifiedReports.add(reportId!);
        
        _sendNotification(reportId, category ?? 'Denúncia', adminNotes);
      } else {
        debugPrint('⚠️ REPORTS_NOTIFICATION: Condições não atendidas para denúncia $reportId');
        debugPrint('⚠️ REPORTS_NOTIFICATION: isResolved: $isResolved, isInReview: $isInReview, hasResponse: $hasResponse');
      }
      
    } catch (e) {
      debugPrint('❌ REPORTS_NOTIFICATION: Erro ao verificar resposta: $e');
    }
  }
  
  /// Enviar notificação sobre resposta da denúncia
  Future<void> _sendNotification(String reportId, String category, String adminResponse) async {
    try {
      debugPrint('🔔 REPORTS_NOTIFICATION: Enviando notificação para denúncia $reportId');
      
      // Verificar permissões
      final hasPermissions = await NotificationService.arePermissionsGranted();
      if (!hasPermissions) {
        debugPrint('⚠️ REPORTS_NOTIFICATION: Sem permissões de notificação');
        final granted = await NotificationService.requestPermissions();
        if (!granted) {
          debugPrint('❌ REPORTS_NOTIFICATION: Permissões negadas');
          return;
        }
      }
      
      // Configurar detalhes da notificação
      final notificationDetails = _getReportNotificationDetails();
      
      // Gerar ID único
      final notificationId = DateTime.now().millisecondsSinceEpoch % 100000;
      
      // Título e corpo da notificação
      final title = 'Resposta da sua denúncia';
      final body = 'Sua denúncia sobre "$category" foi respondida pela nossa equipe.';
      
      // Payload para deep link
      final payload = 'report_response:$reportId';
      
      // Enviar notificação
      await _notifications.show(
        notificationId,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
      
      debugPrint('✅ REPORTS_NOTIFICATION: Notificação enviada - ID: $notificationId');
      
    } catch (e) {
      debugPrint('❌ REPORTS_NOTIFICATION: Erro ao enviar notificação: $e');
    }
  }
  
  /// Configurar detalhes específicos para notificações de denúncias
  static NotificationDetails _getReportNotificationDetails() {
    // Configurações Android
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'reports_channel',
      'Denúncias',
      channelDescription: 'Notificações sobre respostas às suas denúncias',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF9C89B8), // Cor roxa do app
      ledColor: Color(0xFF9C89B8),
      ledOnMs: 1000,
      ledOffMs: 500,
    );
    
    // Configurações iOS
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
      badgeNumber: 1,
    );
    
    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }
  
  /// Callback para erros na stream
  void _onError(Object error) {
    debugPrint('❌ REPORTS_NOTIFICATION: Erro na stream: $error');
    
    // Tentar reconectar após um delay
    Future.delayed(const Duration(seconds: 5), () {
      if (_currentUserId != null && !_isListening) {
        debugPrint('🔄 REPORTS_NOTIFICATION: Tentando reconectar...');
        startListening(_currentUserId!);
      }
    });
  }
  
  /// Verificar se está monitorando
  bool get isListening => _isListening;
  
  /// Obter ID do usuário atual
  String? get currentUserId => _currentUserId;
  
  /// Processar deep link de notificação
  static Future<void> handleNotificationTap(String payload) async {
    try {
      debugPrint('🔔 REPORTS_NOTIFICATION: Processando tap na notificação: $payload');
      
      if (payload.startsWith('report_response:')) {
        final reportId = payload.substring('report_response:'.length);
        debugPrint('🔔 REPORTS_NOTIFICATION: Navegando para denúncia: $reportId');
        
        // TODO: Implementar navegação para detalhes da denúncia
        // Por enquanto, apenas loggar o ID da denúncia
        debugPrint('🔔 REPORTS_NOTIFICATION: Deveria navegar para denúncia: $reportId');
      }
      
    } catch (e) {
      debugPrint('❌ REPORTS_NOTIFICATION: Erro ao processar tap: $e');
    }
  }
  
  /// Testar notificação de denúncia
  static Future<void> sendTestNotification() async {
    try {
      debugPrint('🔔 REPORTS_NOTIFICATION: Enviando notificação de teste...');
      
      // Inicializar serviço se necessário
      await NotificationService.initialize();
      
      // Verificar permissões
      final hasPermissions = await NotificationService.arePermissionsGranted();
      if (!hasPermissions) {
        final granted = await NotificationService.requestPermissions();
        if (!granted) {
          debugPrint('❌ REPORTS_NOTIFICATION: Permissões negadas');
          return;
        }
      }
      
      final notificationDetails = _getReportNotificationDetails();
      final notificationId = DateTime.now().millisecondsSinceEpoch % 100000;
      
      await _notifications.show(
        notificationId,
        'Resposta da sua denúncia',
        'Sua denúncia sobre "Conteúdo Inadequado" foi respondida pela nossa equipe.',
        notificationDetails,
        payload: 'report_response:test_id',
      );
      
      debugPrint('✅ REPORTS_NOTIFICATION: Notificação de teste enviada');
      
    } catch (e) {
      debugPrint('❌ REPORTS_NOTIFICATION: Erro ao enviar teste: $e');
    }
  }
}
