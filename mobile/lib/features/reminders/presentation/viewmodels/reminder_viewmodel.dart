import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../../../../core/services/notification_service.dart';
import '../../domain/models/reminder_model.dart';
import '../../domain/repositories/reminder_repository.dart';

/// ReminderViewModel - ViewModel para gerenciar os lembretes
///
/// Gerencia o estado dos lembretes usando o ReminderModel atualizado
/// e fornece métodos para interagir com o repositório seguindo Clean Architecture.
class ReminderViewModel extends ChangeNotifier {
  final ReminderRepository _repository;
  
  /// Lista de lembretes
  List<ReminderModel> _reminders = [];
  
  /// Indica se uma operação está em andamento
  bool isLoading = false;
  
  /// Mensagem de erro, se houver
  String? errorMessage;
  
  /// Mensagem de sucesso, se houver
  String? successMessage;
  
  /// Limite máximo de lembretes por usuário
  static const int maxReminders = 3;
  
  /// Construtor do ReminderViewModel
  ReminderViewModel(this._repository) {
    _initializeNotifications();
    _loadReminders();
  }
  
  /// Obtém a lista de lembretes
  List<ReminderModel> get reminders => List.unmodifiable(_reminders);
  
  /// Obtém apenas lembretes ativos
  List<ReminderModel> get activeReminders => 
      _reminders.where((r) => r.isActive).toList();
  
  /// Verifica se pode adicionar mais lembretes
  bool get canAddMoreReminders => _reminders.length < maxReminders;
  
  /// Obtém o número de lembretes restantes
  int get remainingSlots => maxReminders - _reminders.length;
  
  /// Inicializa as notificações e solicita permissões
  Future<void> _initializeNotifications() async {
    try {
      debugPrint('🔔 VIEWMODEL: Verificando permissões de notificação...');
      
      final hasPermissions = await NotificationService.arePermissionsGranted();
      if (!hasPermissions) {
        debugPrint('🔔 VIEWMODEL: Solicitando permissões de notificação...');
        final granted = await NotificationService.requestPermissions();
        
        if (!granted) {
          debugPrint('⚠️ VIEWMODEL: Permissões de notificação negadas');
          // Não bloquear o app, apenas avisar que notificações não funcionarão
        } else {
          debugPrint('✅ VIEWMODEL: Permissões de notificação concedidas');
        }
      } else {
        debugPrint('✅ VIEWMODEL: Permissões de notificação já concedidas');
      }
    } catch (e) {
      debugPrint('❌ VIEWMODEL: Erro ao verificar permissões: $e');
    }
  }
  
  /// Carrega os lembretes do usuário atual
  Future<void> _loadReminders() async {
    try {
      debugPrint('🔄 VIEWMODEL: Carregando lembretes...');
      
      isLoading = true;
      errorMessage = null;
      successMessage = null;
      notifyListeners();
      
      final result = await _repository.getReminders();
      
      result.fold(
        (error) {
          debugPrint('❌ VIEWMODEL: Erro ao carregar lembretes: $error');
          errorMessage = error;
          _reminders = [];
        },
        (reminders) {
          debugPrint('✅ VIEWMODEL: ${reminders.length} lembretes carregados');
          _reminders = reminders;
        },
      );
    } catch (e) {
      debugPrint('❌ VIEWMODEL: Exceção ao carregar lembretes: $e');
      errorMessage = 'Erro inesperado ao carregar lembretes';
      _reminders = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  
  /// Recarrega os lembretes
  Future<void> refreshReminders() async {
    await _loadReminders();
  }
  
  /// Adiciona um novo lembrete
  Future<bool> addReminder(TimeOfDay time) async {
    try {
      if (!canAddMoreReminders) {
        errorMessage = 'Você já atingiu o limite de $maxReminders lembretes';
        notifyListeners();
        return false;
      }
      
      // Verificar se já existe um lembrete neste horário
      final hasExistingReminder = _reminders.any(
        (r) => r.hour == time.hour && r.minute == time.minute,
      );
      
      if (hasExistingReminder) {
        errorMessage = 'Já existe um lembrete neste horário';
        notifyListeners();
        return false;
      }
      
      debugPrint('🔄 VIEWMODEL: Adicionando lembrete ${time.hour}:${time.minute}...');
      
      isLoading = true;
      errorMessage = null;
      successMessage = null;
      notifyListeners();
      
      final newReminder = ReminderModel.fromTimeOfDay(
        userId: 'temp', // O repositório vai definir o userId correto
        time: time,
      );
      
      final result = await _repository.saveReminder(newReminder);
      
      return result.fold(
        (error) {
          debugPrint('❌ VIEWMODEL: Erro ao adicionar lembrete: $error');
          errorMessage = error;
          return false;
        },
        (savedReminder) {
          debugPrint('✅ VIEWMODEL: Lembrete adicionado com sucesso');
          _reminders.add(savedReminder);
          
          // Ordenar por horário
          _reminders.sort((a, b) {
            if (a.hour != b.hour) return a.hour.compareTo(b.hour);
            return a.minute.compareTo(b.minute);
          });
          
          successMessage = 'Lembrete adicionado com sucesso!';
          return true;
        },
      );
    } catch (e) {
      debugPrint('❌ VIEWMODEL: Exceção ao adicionar lembrete: $e');
      errorMessage = 'Erro inesperado ao adicionar lembrete';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  
  /// Atualiza um lembrete existente
  Future<bool> updateReminder(String id, TimeOfDay newTime) async {
    try {
      debugPrint('🔄 VIEWMODEL: Atualizando lembrete $id...');
      
      isLoading = true;
      errorMessage = null;
      successMessage = null;
      notifyListeners();
      
      final reminderIndex = _reminders.indexWhere((r) => r.id == id);
      if (reminderIndex == -1) {
        errorMessage = 'Lembrete não encontrado';
        return false;
      }
      
      // Verificar se já existe outro lembrete neste horário
      final hasExistingReminder = _reminders.any(
        (r) => r.id != id && r.hour == newTime.hour && r.minute == newTime.minute,
      );
      
      if (hasExistingReminder) {
        errorMessage = 'Já existe um lembrete neste horário';
        return false;
      }
      
      final updatedReminder = _reminders[reminderIndex].copyWith(
        hour: newTime.hour,
        minute: newTime.minute,
      );
      
      final result = await _repository.saveReminder(updatedReminder);
      
      return result.fold(
        (error) {
          debugPrint('❌ VIEWMODEL: Erro ao atualizar lembrete: $error');
          errorMessage = error;
          return false;
        },
        (savedReminder) {
          debugPrint('✅ VIEWMODEL: Lembrete atualizado com sucesso');
          _reminders[reminderIndex] = savedReminder;
          
          // Reordenar por horário
          _reminders.sort((a, b) {
            if (a.hour != b.hour) return a.hour.compareTo(b.hour);
            return a.minute.compareTo(b.minute);
          });
          
          successMessage = 'Lembrete atualizado com sucesso!';
          return true;
        },
      );
    } catch (e) {
      debugPrint('❌ VIEWMODEL: Exceção ao atualizar lembrete: $e');
      errorMessage = 'Erro inesperado ao atualizar lembrete';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  
  /// Remove um lembrete
  Future<bool> removeReminder(String id) async {
    try {
      debugPrint('🔄 VIEWMODEL: Removendo lembrete $id...');
      
      isLoading = true;
      errorMessage = null;
      successMessage = null;
      notifyListeners();
      
      final result = await _repository.deleteReminder(id);
      
      return result.fold(
        (error) {
          debugPrint('❌ VIEWMODEL: Erro ao remover lembrete: $error');
          errorMessage = error;
          return false;
        },
        (_) {
          debugPrint('✅ VIEWMODEL: Lembrete removido com sucesso');
          _reminders.removeWhere((r) => r.id == id);
          successMessage = 'Lembrete removido com sucesso!';
          return true;
        },
      );
    } catch (e) {
      debugPrint('❌ VIEWMODEL: Exceção ao remover lembrete: $e');
      errorMessage = 'Erro inesperado ao remover lembrete';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  
  /// Ativa/desativa um lembrete
  Future<bool> toggleReminderStatus(String id) async {
    try {
      debugPrint('🔄 VIEWMODEL: Alternando status do lembrete $id...');
      
      isLoading = true;
      errorMessage = null;
      successMessage = null;
      notifyListeners();
      
      final reminderIndex = _reminders.indexWhere((r) => r.id == id);
      if (reminderIndex == -1) {
        errorMessage = 'Lembrete não encontrado';
        return false;
      }
      
      // Usar o método adicional do repositório se disponível
      // Por enquanto, vamos usar o saveReminder com o status alterado
      final updatedReminder = _reminders[reminderIndex].copyWith(
        isActive: !_reminders[reminderIndex].isActive,
      );
      
      final result = await _repository.saveReminder(updatedReminder);
      
      return result.fold(
        (error) {
          debugPrint('❌ VIEWMODEL: Erro ao alterar status do lembrete: $error');
          errorMessage = error;
          return false;
        },
        (savedReminder) {
          debugPrint('✅ VIEWMODEL: Status do lembrete alterado com sucesso');
          _reminders[reminderIndex] = savedReminder;
          
          final status = savedReminder.isActive ? 'ativado' : 'desativado';
          successMessage = 'Lembrete $status com sucesso!';
          return true;
        },
      );
    } catch (e) {
      debugPrint('❌ VIEWMODEL: Exceção ao alterar status do lembrete: $e');
      errorMessage = 'Erro inesperado ao alterar status do lembrete';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  
  /// Limpa mensagens de erro e sucesso
  void clearMessages() {
    errorMessage = null;
    successMessage = null;
    notifyListeners();
  }
  
  /// Testa o envio de notificação imediata
  Future<bool> testNotification() async {
    try {
      debugPrint('🔔 VIEWMODEL: Enviando notificação de teste...');
      
      isLoading = true;
      errorMessage = null;
      successMessage = null;
      notifyListeners();
      
      // Verificar permissões primeiro
      final hasPermissions = await NotificationService.arePermissionsGranted();
      if (!hasPermissions) {
        debugPrint('⚠️ VIEWMODEL: Sem permissões para notificações');
        final granted = await NotificationService.requestPermissions();
        if (!granted) {
          errorMessage = 'Permissões de notificação negadas. Por favor, verifique as configurações do seu dispositivo.';
          return false;
        }
      }
      
      // Inicializar serviço se necessário
      await NotificationService.initialize();
      
      // Enviar notificação de teste
      final success = await NotificationService.showTestNotification();
      
      if (success) {
        debugPrint('✅ VIEWMODEL: Notificação de teste enviada com sucesso');
        successMessage = 'Notificação de teste enviada com sucesso! Verifique se ela apareceu no seu dispositivo.';
        return true;
      } else {
        debugPrint('⚠️ VIEWMODEL: Falha ao enviar notificação de teste');
        errorMessage = 'Não foi possível enviar a notificação de teste. Verifique as permissões do aplicativo.';
        return false;
      }
    } catch (e) {
      debugPrint('❌ VIEWMODEL: Erro ao enviar notificação de teste: $e');
      
      // Verificar se o erro está relacionado a alarmes exatos
      if (e.toString().contains('exact_alarms_not_permitted')) {
        errorMessage = 'Seu dispositivo não permite alarmes exatos. Os lembretes podem não ser precisos. Verifique as configurações do dispositivo.';
      } else {
        errorMessage = 'Erro ao enviar notificação de teste: $e';
      }
      
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  
  /// Verifica e solicita permissões de notificação
  Future<bool> checkAndRequestPermissions() async {
    try {
      debugPrint('🔔 VIEWMODEL: Verificando permissões de notificação...');
      
      isLoading = true;
      errorMessage = null;
      successMessage = null;
      notifyListeners();
      
      // Inicializar serviço se necessário
      await NotificationService.initialize();
      
      // Verificar permissões atuais
      final hasPermissions = await NotificationService.arePermissionsGranted();
      if (hasPermissions) {
        debugPrint('✅ VIEWMODEL: Permissões de notificação já concedidas');
        
        // Verificar se estamos em um dispositivo Android 12+ para mostrar informações sobre alarmes exatos
        if (Platform.isAndroid) {
          try {
            final deviceInfo = DeviceInfoPlugin();
            final androidInfo = await deviceInfo.androidInfo;
            final sdkInt = androidInfo.version.sdkInt;
            
            if (sdkInt >= 31) {
              successMessage = 'Permissões de notificação concedidas. Nota: Para lembretes precisos, você pode precisar permitir "Alarmes e lembretes" nas configurações do aplicativo.';
            } else {
              successMessage = 'Permissões de notificação concedidas';
            }
          } catch (e) {
            successMessage = 'Permissões de notificação concedidas';
          }
        } else {
          successMessage = 'Permissões de notificação concedidas';
        }
        
        return true;
      }
      
      // Solicitar permissões
      debugPrint('🔔 VIEWMODEL: Solicitando permissões de notificação...');
      final granted = await NotificationService.requestPermissions();
      
      if (granted) {
        debugPrint('✅ VIEWMODEL: Permissões de notificação concedidas');
        successMessage = 'Permissões de notificação concedidas';
        return true;
      } else {
        debugPrint('⚠️ VIEWMODEL: Permissões de notificação negadas');
        errorMessage = 'Permissões de notificação negadas. Por favor, verifique as configurações do seu dispositivo.';
        return false;
      }
    } catch (e) {
      debugPrint('❌ VIEWMODEL: Erro ao verificar permissões: $e');
      errorMessage = 'Erro ao verificar permissões: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  
  /// Abre as configurações de alarmes exatos (Android 12+)
  Future<bool> openExactAlarmSettings() async {
    try {
      debugPrint('🔔 VIEWMODEL: Tentando abrir configurações de alarmes exatos...');
      
      isLoading = true;
      errorMessage = null;
      successMessage = null;
      notifyListeners();
      
      if (!Platform.isAndroid) {
        debugPrint('⚠️ VIEWMODEL: Não é um dispositivo Android');
        errorMessage = 'Esta configuração só está disponível em dispositivos Android 12+';
        return false;
      }
      
      // Verificar versão do Android
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      
      if (sdkInt < 31) {
        debugPrint('⚠️ VIEWMODEL: Versão do Android não requer permissão de alarmes exatos');
        successMessage = 'Seu dispositivo não requer esta permissão';
        return true;
      }
      
      // Tentar abrir configurações
      final success = await NotificationService.openExactAlarmSettings();
      
      if (success) {
        debugPrint('✅ VIEWMODEL: Configurações de alarmes exatos abertas');
        successMessage = 'Por favor, ative a permissão "Alarmes e lembretes" nas configurações';
        return true;
      } else {
        debugPrint('⚠️ VIEWMODEL: Não foi possível abrir configurações automaticamente');
        errorMessage = 'Não foi possível abrir as configurações automaticamente. Por favor, vá para Configurações > Apps > C\'Alma > Permissões > Alarmes e lembretes';
        return false;
      }
    } catch (e) {
      debugPrint('❌ VIEWMODEL: Erro ao abrir configurações de alarmes exatos: $e');
      errorMessage = 'Erro ao abrir configurações: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  
  /// Salva múltiplos lembretes (para uso no onboarding)
  Future<bool> saveMultipleReminders(List<TimeOfDay> times) async {
    try {
      if (times.length > maxReminders) {
        errorMessage = 'Máximo de $maxReminders lembretes permitidos';
        notifyListeners();
        return false;
      }
      
      debugPrint('🔄 VIEWMODEL: Salvando ${times.length} lembretes...');
      
      isLoading = true;
      errorMessage = null;
      successMessage = null;
      notifyListeners();
      
      final result = await _repository.saveReminders(times);
      
      return result.fold(
        (error) {
          debugPrint('❌ VIEWMODEL: Erro ao salvar lembretes: $error');
          errorMessage = error;
          return false;
        },
        (savedReminders) {
          debugPrint('✅ VIEWMODEL: Lembretes salvos com sucesso');
          _reminders = savedReminders;
          successMessage = 'Lembretes salvos com sucesso!';
          return true;
        },
      );
    } catch (e) {
      debugPrint('❌ VIEWMODEL: Exceção ao salvar lembretes: $e');
      errorMessage = 'Erro inesperado ao salvar lembretes';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  
  /// Remove todos os lembretes do usuário
  Future<bool> deleteAllReminders() async {
    try {
      debugPrint('🔄 VIEWMODEL: Removendo todos os lembretes...');
      
      isLoading = true;
      errorMessage = null;
      successMessage = null;
      notifyListeners();
      
      final result = await _repository.deleteAllReminders();
      
      return result.fold(
        (error) {
          debugPrint('❌ VIEWMODEL: Erro ao remover todos os lembretes: $error');
          errorMessage = error;
          return false;
        },
        (_) {
          debugPrint('✅ VIEWMODEL: Todos os lembretes removidos com sucesso');
          _reminders.clear();
          successMessage = 'Todos os lembretes foram removidos!';
          return true;
        },
      );
    } catch (e) {
      debugPrint('❌ VIEWMODEL: Exceção ao remover todos os lembretes: $e');
      errorMessage = 'Erro inesperado ao remover lembretes';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
