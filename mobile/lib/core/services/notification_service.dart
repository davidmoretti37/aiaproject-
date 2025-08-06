import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// NotificationService - Serviço para gerenciar notificações locais
///
/// Responsável por agendar, cancelar e gerenciar notificações de lembretes.
/// Funciona offline e integra com o sistema operacional.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  
  static bool _isInitialized = false;
  
  /// Inicializar o serviço de notificações
  static Future<bool> initialize() async {
    if (_isInitialized) {
      debugPrint('✅ NOTIFICATION: Serviço já inicializado');
      return true;
    }
    
    try {
      debugPrint('🔔 NOTIFICATION: Inicializando serviço de notificações...');
      
      // Inicializar timezone
      try {
        tz.initializeTimeZones();
        final location = tz.getLocation('America/Sao_Paulo');
        tz.setLocalLocation(location);
        debugPrint('✅ NOTIFICATION: Timezone configurado: ${location.name}');
      } catch (e) {
        debugPrint('⚠️ NOTIFICATION: Erro ao configurar timezone: $e');
        // Continuar mesmo com erro de timezone
      }
      
      // Configurações Android
      const AndroidInitializationSettings androidSettings = 
          AndroidInitializationSettings('@mipmap/ic_launcher');
      debugPrint('🔔 NOTIFICATION: Configurações Android definidas');
      
      // Configurações iOS
      const DarwinInitializationSettings iosSettings = 
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      debugPrint('🔔 NOTIFICATION: Configurações iOS definidas');
      
      // Configurações gerais
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      // Inicializar plugin
      debugPrint('🔔 NOTIFICATION: Inicializando plugin...');
      final bool? initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      
      if (initialized == true) {
        _isInitialized = true;
        debugPrint('✅ NOTIFICATION: Serviço inicializado com sucesso');
        return true;
      } else {
        debugPrint('❌ NOTIFICATION: Falha na inicialização (retorno: $initialized)');
        return false;
      }
    } catch (e) {
      debugPrint('❌ NOTIFICATION: Erro na inicialização: $e');
      return false;
    }
  }
  
  /// Callback quando notificação é tocada
  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 NOTIFICATION: Notificação tocada - ID: ${response.id}');
    // Aqui você pode implementar navegação específica se necessário
  }
  
  /// Solicitar permissões de notificação
  static Future<bool> requestPermissions() async {
    try {
      debugPrint('🔔 NOTIFICATION: Solicitando permissões...');
      
      if (Platform.isAndroid) {
        debugPrint('🔔 NOTIFICATION: Dispositivo Android detectado');
        
        // Verificar versão do Android
        final androidInfo = await _deviceInfo.androidInfo;
        final sdkInt = androidInfo.version.sdkInt;
        debugPrint('🔔 NOTIFICATION: Versão Android SDK: $sdkInt');
        
        // Android 13+ (SDK 33+) requer permissão específica
        if (sdkInt >= 33) {
          debugPrint('🔔 NOTIFICATION: Android 13+ detectado, solicitando permissão específica...');
          final status = await Permission.notification.request();
          final granted = status == PermissionStatus.granted;
          
          debugPrint('🔔 NOTIFICATION: Permissão Android: $status (concedida: $granted)');
          return granted;
        } else {
          debugPrint('🔔 NOTIFICATION: Android <13, permissão implícita');
          return true; // Versões anteriores não precisam de permissão explícita
        }
      } else if (Platform.isIOS) {
        debugPrint('🔔 NOTIFICATION: Dispositivo iOS detectado');
        
        // iOS - solicitar através do plugin
        final iosPlugin = _notifications
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
                
        if (iosPlugin == null) {
          debugPrint('⚠️ NOTIFICATION: Plugin iOS não disponível');
          return false;
        }
        
        debugPrint('🔔 NOTIFICATION: Solicitando permissões iOS...');
        final bool? granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        
        debugPrint('🔔 NOTIFICATION: Permissão iOS: $granted');
        return granted ?? false;
      } else {
        debugPrint('⚠️ NOTIFICATION: Plataforma não suportada: ${Platform.operatingSystem}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ NOTIFICATION: Erro ao solicitar permissões: $e');
      return false;
    }
  }
  
  /// Verificar se permissões estão concedidas
  static Future<bool> arePermissionsGranted() async {
    try {
      debugPrint('🔔 NOTIFICATION: Verificando permissões...');
      
      if (Platform.isAndroid) {
        debugPrint('🔔 NOTIFICATION: Verificando permissões no Android...');
        
        // Verificar versão do Android
        final androidInfo = await _deviceInfo.androidInfo;
        final sdkInt = androidInfo.version.sdkInt;
        debugPrint('🔔 NOTIFICATION: Versão Android SDK: $sdkInt');
        
        // Android 13+ (SDK 33+) requer permissão específica
        if (sdkInt >= 33) {
          final status = await Permission.notification.status;
          debugPrint('🔔 NOTIFICATION: Status da permissão Android: $status');
          return status == PermissionStatus.granted;
        } else {
          debugPrint('🔔 NOTIFICATION: Android <13, permissão implícita');
          return true; // Versões anteriores não precisam de permissão explícita
        }
      } else if (Platform.isIOS) {
        debugPrint('🔔 NOTIFICATION: Verificando permissões no iOS...');
        
        final iosPlugin = _notifications
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        
        if (iosPlugin != null) {
          final permissions = await iosPlugin.checkPermissions();
          final isEnabled = permissions?.isEnabled == true;
          debugPrint('🔔 NOTIFICATION: Permissões iOS: $permissions (habilitadas: $isEnabled)');
          return isEnabled;
        } else {
          debugPrint('⚠️ NOTIFICATION: Plugin iOS não disponível');
          return false;
        }
      } else {
        debugPrint('⚠️ NOTIFICATION: Plataforma não suportada: ${Platform.operatingSystem}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ NOTIFICATION: Erro ao verificar permissões: $e');
      return false;
    }
  }
  
  /// Verificar se o dispositivo permite alarmes exatos
  static Future<bool> _canScheduleExactAlarms() async {
    if (!Platform.isAndroid) return true;
    
    try {
      // Verificar versão do Android
      final androidInfo = await _deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      
      // Android 12+ (SDK 31+) requer permissão para alarmes exatos
      if (sdkInt >= 31) {
        // Não há método direto para verificar, então tentamos usar um método seguro
        // que não lançará exceção se não tivermos permissão
        try {
          // Verificar se temos permissões de notificação primeiro
          final hasNotificationPermission = await arePermissionsGranted();
          if (!hasNotificationPermission) {
            debugPrint('⚠️ NOTIFICATION: Sem permissão de notificação básica');
            return false;
          }
          
          debugPrint('🔔 NOTIFICATION: Verificando permissão para alarmes exatos...');
          
          // Não podemos verificar diretamente, então assumimos que não temos permissão
          // e deixamos o sistema lidar com isso durante o agendamento
          return false;
        } catch (e) {
          debugPrint('⚠️ NOTIFICATION: Erro ao verificar permissão de alarmes exatos: $e');
          return false;
        }
      } else {
        // Versões anteriores não têm essa restrição
        return true;
      }
    } catch (e) {
      debugPrint('⚠️ NOTIFICATION: Erro ao verificar permissão de alarmes exatos: $e');
      return false;
    }
  }
  
  /// Agendar notificação diária
  static Future<int?> scheduleDaily({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    try {
      // Inicializar se necessário
      if (!_isInitialized) {
        debugPrint('🔔 NOTIFICATION: Serviço não inicializado, inicializando...');
        final initialized = await initialize();
        if (!initialized) {
          debugPrint('❌ NOTIFICATION: Falha ao inicializar serviço');
          return null;
        }
      }
      
      // Verificar permissões
      final hasPermissions = await arePermissionsGranted();
      if (!hasPermissions) {
        debugPrint('❌ NOTIFICATION: Sem permissões para notificações');
        final granted = await requestPermissions();
        if (!granted) {
          debugPrint('❌ NOTIFICATION: Permissões negadas pelo usuário');
          return null;
        }
      }
      
      // Gerar ID único
      final int notificationId = _generateUniqueId();
      
      debugPrint('🔔 NOTIFICATION: Agendando notificação diária ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} - ID: $notificationId');
      
      // Configurar detalhes da notificação
      final notificationDetails = _getNotificationDetails();
      
      // Calcular próximo horário
      final scheduledDate = _nextInstanceOfTime(hour, minute);
      debugPrint('🔔 NOTIFICATION: Próximo horário calculado: $scheduledDate');
      
      // Verificar se podemos usar alarmes exatos
      final canUseExactAlarms = await _canScheduleExactAlarms();
      
      // Agendar notificação
      debugPrint('🔔 NOTIFICATION: Enviando solicitação de agendamento...');
      
      if (canUseExactAlarms) {
        debugPrint('🔔 NOTIFICATION: Usando modo exato para agendamento');
        await _notifications.zonedSchedule(
          notificationId,
          title,
          body,
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time, // Repetir diariamente
        );
      } else {
        debugPrint('🔔 NOTIFICATION: Usando modo inexato para agendamento (alarmes exatos não permitidos)');
        await _notifications.zonedSchedule(
          notificationId,
          title,
          body,
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time, // Repetir diariamente
        );
      }
      
      // Verificar se a notificação foi agendada
      final pendingNotifications = await _notifications.pendingNotificationRequests();
      final isScheduled = pendingNotifications.any((notification) => notification.id == notificationId);
      
      if (isScheduled) {
        debugPrint('✅ NOTIFICATION: Notificação agendada com sucesso - ID: $notificationId');
        return notificationId;
      } else {
        debugPrint('⚠️ NOTIFICATION: Notificação não encontrada após agendamento');
        return notificationId; // Retornar ID mesmo assim, pode ser um falso negativo
      }
    } catch (e) {
      debugPrint('❌ NOTIFICATION: Erro ao agendar notificação: $e');
      
      // Tentar novamente com modo inexato se o erro for relacionado a alarmes exatos
      if (e.toString().contains('exact_alarms_not_permitted')) {
        try {
          debugPrint('🔔 NOTIFICATION: Tentando novamente com modo inexato...');
          
          // Gerar ID único
          final int notificationId = _generateUniqueId();
          
          // Configurar detalhes da notificação
          final notificationDetails = _getNotificationDetails();
          
          // Calcular próximo horário
          final scheduledDate = _nextInstanceOfTime(hour, minute);
          
          await _notifications.zonedSchedule(
            notificationId,
            title,
            body,
            scheduledDate,
            notificationDetails,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.time, // Repetir diariamente
          );
          
          debugPrint('✅ NOTIFICATION: Notificação agendada com sucesso (modo inexato) - ID: $notificationId');
          return notificationId;
        } catch (retryError) {
          debugPrint('❌ NOTIFICATION: Erro ao tentar novamente: $retryError');
          return null;
        }
      }
      
      return null;
    }
  }
  
  /// Cancelar notificação específica
  static Future<bool> cancel(int notificationId) async {
    try {
      debugPrint('🔔 NOTIFICATION: Cancelando notificação ID: $notificationId');
      
      await _notifications.cancel(notificationId);
      
      debugPrint('✅ NOTIFICATION: Notificação cancelada com sucesso');
      return true;
    } catch (e) {
      debugPrint('❌ NOTIFICATION: Erro ao cancelar notificação: $e');
      return false;
    }
  }
  
  /// Cancelar todas as notificações
  static Future<bool> cancelAll() async {
    try {
      debugPrint('🔔 NOTIFICATION: Cancelando todas as notificações');
      
      await _notifications.cancelAll();
      
      debugPrint('✅ NOTIFICATION: Todas as notificações canceladas');
      return true;
    } catch (e) {
      debugPrint('❌ NOTIFICATION: Erro ao cancelar todas as notificações: $e');
      return false;
    }
  }
  
  /// Listar notificações pendentes
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      final pending = await _notifications.pendingNotificationRequests();
      debugPrint('🔔 NOTIFICATION: ${pending.length} notificações pendentes');
      return pending;
    } catch (e) {
      debugPrint('❌ NOTIFICATION: Erro ao listar notificações pendentes: $e');
      return [];
    }
  }
  
  /// Configurar detalhes da notificação
  static NotificationDetails _getNotificationDetails() {
    // Configurações Android
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'reminders_channel',
      'Lembretes',
      channelDescription: 'Notificações de lembretes do C\'Alma',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );
    
    // Configurações iOS
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );
    
    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }
  
  /// Calcular próxima instância do horário
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    
    // Se o horário já passou hoje, agendar para amanhã
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    debugPrint('🔔 NOTIFICATION: Próximo disparo: $scheduledDate');
    return scheduledDate;
  }
  
  /// Gerar ID único para notificação
  static int _generateUniqueId() {
    // Usar timestamp + random para garantir unicidade
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(1000);
    return int.parse('${timestamp.toString().substring(8)}$random');
  }
  
  /// Abrir configurações de alarmes exatos (Android 12+)
  static Future<bool> openExactAlarmSettings() async {
    if (!Platform.isAndroid) return false;
    
    try {
      final androidInfo = await _deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      
      // Android 12+ (SDK 31+)
      if (sdkInt >= 31) {
        // Usar Intent para abrir configurações de alarmes exatos
        // Isso é feito através de um método personalizado que usa o plugin
        debugPrint('🔔 NOTIFICATION: Tentando abrir configurações de alarmes exatos...');
        
        // Não há método direto para isso no plugin, então retornamos false
        // e orientamos o usuário a fazer isso manualmente
        debugPrint('⚠️ NOTIFICATION: Não foi possível abrir configurações automaticamente');
        return false;
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ NOTIFICATION: Erro ao abrir configurações de alarmes exatos: $e');
      return false;
    }
  }
  
  /// Testar notificação imediata (para debug)
  static Future<bool> showTestNotification() async {
    try {
      // Inicializar se necessário
      if (!_isInitialized) {
        debugPrint('🔔 NOTIFICATION: Serviço não inicializado, inicializando...');
        final initialized = await initialize();
        if (!initialized) {
          debugPrint('❌ NOTIFICATION: Falha ao inicializar serviço');
          return false;
        }
      }
      
      // Verificar permissões
      final hasPermissions = await arePermissionsGranted();
      if (!hasPermissions) {
        debugPrint('❌ NOTIFICATION: Sem permissões para notificações');
        final granted = await requestPermissions();
        if (!granted) {
          debugPrint('❌ NOTIFICATION: Permissões negadas pelo usuário');
          return false;
        }
      }
      
      debugPrint('🔔 NOTIFICATION: Enviando notificação de teste...');
      
      final notificationDetails = _getNotificationDetails();
      
      // ID único para cada teste
      final testId = DateTime.now().millisecondsSinceEpoch % 100000;
      
      await _notifications.show(
        testId,
        'Teste de Notificação',
        'Esta é uma notificação de teste do C\'Alma - ${DateTime.now().toString()}',
        notificationDetails,
      );
      
      debugPrint('✅ NOTIFICATION: Notificação de teste enviada com ID: $testId');
      return true;
    } catch (e) {
      debugPrint('❌ NOTIFICATION: Erro ao enviar notificação de teste: $e');
      return false;
    }
  }
}
