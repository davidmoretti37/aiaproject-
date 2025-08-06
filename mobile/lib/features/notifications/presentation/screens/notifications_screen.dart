import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:calma_flutter/core/services/supabase_service.dart';
import 'package:calma_flutter/features/reports/data/repositories/reports_repository.dart';
import 'package:calma_flutter/features/reports/data/models/ai_content_report.dart';
import 'package:calma_flutter/features/insights/presentation/screens/pending_invitations_screen.dart';
import 'package:calma_flutter/features/notifications/services/notification_preferences_service.dart';

/// Tela de notificações unificada
/// Mostra convites de psicólogos e respostas de denúncias
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ReportsRepository _reportsRepository = ReportsRepository();
  List<NotificationItem> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    debugPrint('🔄 NOTIFICATIONS: Iniciando carregamento de notificações...');

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final notifications = <NotificationItem>[];

      debugPrint('🔄 NOTIFICATIONS: Lista de notificações inicializada');

      // Carregar convites de psicólogos
      debugPrint('🔄 NOTIFICATIONS: Carregando convites de psicólogos...');
      await _loadPsychologistInvites(notifications);
      debugPrint(
          '🔄 NOTIFICATIONS: Convites carregados. Total atual: ${notifications.length}');

      // Carregar respostas de denúncias
      debugPrint('🔄 NOTIFICATIONS: Carregando respostas de denúncias...');
      await _loadReportResponses(notifications);
      debugPrint(
          '🔄 NOTIFICATIONS: Respostas carregadas. Total final: ${notifications.length}');

      // Ordenar por data (mais recente primeiro)
      notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      debugPrint('🔄 NOTIFICATIONS: Notificações ordenadas por data');

      debugPrint(
          '🔄 NOTIFICATIONS: Lista antes do setState: ${notifications.length} itens');
      for (int i = 0; i < notifications.length; i++) {
        final notification = notifications[i];
        debugPrint(
            '🔄 NOTIFICATIONS: Antes setState [$i] ${notification.type.name}: ${notification.id}');
      }

      setState(() {
        debugPrint('🔄 NOTIFICATIONS: Executando setState...');
        _notifications = notifications;
        _isLoading = false;
        debugPrint(
            '🔄 NOTIFICATIONS: setState executado. _notifications.length: ${_notifications.length}');
      });

      debugPrint('✅ NOTIFICATIONS: Carregamento concluído com sucesso!');
      debugPrint(
          '✅ NOTIFICATIONS: Total de notificações na tela: ${_notifications.length}');

      // Log detalhado das notificações carregadas
      for (int i = 0; i < _notifications.length; i++) {
        final notification = _notifications[i];
        debugPrint(
            '✅ NOTIFICATIONS: Após setState [$i] ${notification.type.name}: ${notification.title}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ NOTIFICATIONS: Erro no carregamento principal: $e');
      debugPrint('❌ NOTIFICATIONS: Stack trace: $stackTrace');

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPsychologistInvites(
      List<NotificationItem> notifications) async {
    try {
      debugPrint('🔍 NOTIFICATIONS: Iniciando carregamento de convites...');

      final currentUser = SupabaseService.client.auth.currentUser;
      debugPrint('🔍 NOTIFICATIONS: Usuário atual: ${currentUser?.id}');
      debugPrint('🔍 NOTIFICATIONS: Email do usuário: ${currentUser?.email}');

      if (currentUser?.email == null) {
        debugPrint('⚠️ NOTIFICATIONS: Usuário não tem email, saindo...');
        return;
      }

      debugPrint('🔍 NOTIFICATIONS: Fazendo query para convites pendentes...');

      // Primeiro, testar query simples sem JOIN
      final pendingInvites = await SupabaseService.client
          .from('psychologists_patients')
          .select('*')
          .eq('patient_email', currentUser!.email!)
          .eq('status', 'pending');

      debugPrint('🔍 NOTIFICATIONS: Query executada com sucesso');
      debugPrint(
          '🔍 NOTIFICATIONS: Número de convites encontrados: ${pendingInvites.length}');
      debugPrint('🔍 NOTIFICATIONS: Dados dos convites: $pendingInvites');

      if (pendingInvites.isEmpty) {
        debugPrint(
            '⚠️ NOTIFICATIONS: Nenhum convite pendente encontrado para ${currentUser.email}');
        return;
      }

      // Agora buscar dados dos psicólogos separadamente
      for (int i = 0; i < pendingInvites.length; i++) {
        final invite = pendingInvites[i];
        debugPrint(
            '🔍 NOTIFICATIONS: [$i] Processando convite: ${invite['id']}');
        debugPrint(
            '🔍 NOTIFICATIONS: [$i] Dados completos do convite: $invite');

        String psychologistName = 'Psicólogo';

        // Tentar buscar dados do psicólogo
        try {
          final psychologistId = invite['psychologist_id'];
          debugPrint('🔍 NOTIFICATIONS: [$i] ID do psicólogo: $psychologistId');

          if (psychologistId != null) {
            debugPrint('🔍 NOTIFICATIONS: [$i] Buscando dados do psicólogo...');
            final psychologistData = await SupabaseService.client
                .from('psychologists')
                .select('name')
                .eq('id', psychologistId)
                .maybeSingle();

            debugPrint(
                '🔍 NOTIFICATIONS: [$i] Dados do psicólogo: $psychologistData');
            psychologistName = psychologistData?['name'] ?? 'Psicólogo';
            debugPrint(
                '🔍 NOTIFICATIONS: [$i] Nome do psicólogo: $psychologistName');
          }
        } catch (e) {
          debugPrint('⚠️ NOTIFICATIONS: [$i] Erro ao buscar psicólogo: $e');
        }

        // Verificar se created_at existe e é válido
        final createdAtStr = invite['created_at'];
        debugPrint('🔍 NOTIFICATIONS: [$i] created_at string: $createdAtStr');

        DateTime timestamp;
        try {
          timestamp = DateTime.parse(createdAtStr);
          debugPrint('🔍 NOTIFICATIONS: [$i] Timestamp parseado: $timestamp');
        } catch (e) {
          debugPrint('⚠️ NOTIFICATIONS: [$i] Erro ao parsear timestamp: $e');
          timestamp = DateTime.now(); // Fallback
        }

        debugPrint('🔍 NOTIFICATIONS: [$i] Criando NotificationItem...');
        final notificationItem = NotificationItem(
          id: 'invite_${invite['id']}',
          type: NotificationType.psychologistInvite,
          title: 'Convite de Psicólogo',
          message: 'Dr(a). $psychologistName convidou você para acompanhamento',
          timestamp: timestamp,
          data: invite,
        );

        debugPrint(
            '🔍 NOTIFICATIONS: [$i] NotificationItem criado: ${notificationItem.id}');
        debugPrint('🔍 NOTIFICATIONS: [$i] Título: ${notificationItem.title}');
        debugPrint(
            '🔍 NOTIFICATIONS: [$i] Mensagem: ${notificationItem.message}');
        debugPrint('🔍 NOTIFICATIONS: [$i] Tipo: ${notificationItem.type}');

        debugPrint(
            '🔍 NOTIFICATIONS: [$i] Adicionando à lista de notificações...');
        notifications.add(notificationItem);
        debugPrint(
            '✅ NOTIFICATIONS: [$i] Convite adicionado! Total na lista: ${notifications.length}');

        // Verificar se realmente foi adicionado
        final lastAdded = notifications.isNotEmpty ? notifications.last : null;
        debugPrint(
            '✅ NOTIFICATIONS: [$i] Último item na lista: ${lastAdded?.id}');
      }

      debugPrint(
          '✅ NOTIFICATIONS: Carregamento de convites concluído. Total: ${pendingInvites.length}');
    } catch (e, stackTrace) {
      debugPrint('❌ NOTIFICATIONS: Erro ao carregar convites: $e');
      debugPrint('❌ NOTIFICATIONS: Stack trace: $stackTrace');
    }
  }

  Future<void> _loadReportResponses(
      List<NotificationItem> notifications) async {
    try {
      debugPrint(
          '🔍 NOTIFICATIONS: Iniciando carregamento de respostas de denúncias...');

      final currentUser = SupabaseService.client.auth.currentUser;
      debugPrint(
          '🔍 NOTIFICATIONS: Usuário atual para denúncias: ${currentUser?.id}');

      if (currentUser == null) {
        debugPrint(
            '⚠️ NOTIFICATIONS: Usuário não autenticado para denúncias, saindo...');
        return;
      }

      debugPrint('🔍 NOTIFICATIONS: Buscando denúncias do usuário...');
      final reports = await _reportsRepository.getUserReports(currentUser.id);

      debugPrint(
          '🔍 NOTIFICATIONS: Total de denúncias encontradas: ${reports.length}');

      // Obter lista de denúncias excluídas
      final dismissedReports =
          await NotificationPreferencesService.getDismissedReports();
      debugPrint(
          '🔍 NOTIFICATIONS: Denúncias excluídas: ${dismissedReports.length}');

      int resolvedCount = 0;
      int withResponseCount = 0;
      int dismissedCount = 0;

      for (final report in reports) {
        debugPrint(
            '🔍 NOTIFICATIONS: Denúncia ${report.id} - Status: ${report.status}, HasResponse: ${report.hasAdminResponse}');

        if (report.status == 'resolved') {
          resolvedCount++;

          if (report.hasAdminResponse) {
            withResponseCount++;

            // Verificar se a denúncia foi excluída
            final isDismissed = dismissedReports.contains(report.id);
            debugPrint(
                '🔍 NOTIFICATIONS: Denúncia ${report.id} excluída: $isDismissed');

            if (isDismissed) {
              dismissedCount++;
              debugPrint(
                  '⚠️ NOTIFICATIONS: Denúncia ${report.id} foi excluída, pulando...');
              continue;
            }

            final notificationItem = NotificationItem(
              id: 'report_${report.id}',
              type: NotificationType.reportResponse,
              title: 'Denúncia Respondida',
              message:
                  'Sua denúncia sobre "${report.categoryDisplayName}" foi respondida',
              timestamp:
                  report.reviewedAt ?? report.updatedAt ?? report.createdAt,
              data: report,
            );

            notifications.add(notificationItem);
            debugPrint(
                '✅ NOTIFICATIONS: Resposta de denúncia adicionada: ${notificationItem.message}');
          }
        }
      }

      debugPrint('✅ NOTIFICATIONS: Carregamento de denúncias concluído.');
      debugPrint(
          '✅ NOTIFICATIONS: Total: ${reports.length}, Resolvidas: $resolvedCount, Com resposta: $withResponseCount, Excluídas: $dismissedCount');
    } catch (e, stackTrace) {
      debugPrint('❌ NOTIFICATIONS: Erro ao carregar respostas: $e');
      debugPrint('❌ NOTIFICATIONS: Stack trace: $stackTrace');
    }
  }

  Future<void> _removeNotification(NotificationItem notification) async {
    try {
      debugPrint(
          '🗑️ NOTIFICATIONS: Removendo notificação: ${notification.id}');

      // Se for uma denúncia, salvar como excluída
      if (notification.type == NotificationType.reportResponse) {
        final report = notification.data as AiContentReport;
        await NotificationPreferencesService.dismissReport(report.id);
        debugPrint(
            '✅ NOTIFICATIONS: Denúncia ${report.id} marcada como excluída');
      }

      // Remover da lista local
      setState(() {
        _notifications.removeWhere((item) => item.id == notification.id);
      });

      debugPrint('✅ NOTIFICATIONS: Notificação removida da lista');
    } catch (e) {
      debugPrint('❌ NOTIFICATIONS: Erro ao remover notificação: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro ao excluir notificação: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Aceitar convite de psicólogo
  Future<void> _acceptInvite(NotificationItem notification) async {
    try {
      debugPrint('🚀 NOTIFICATIONS: ===== INICIANDO ACEITAR CONVITE =====');
      debugPrint('🚀 NOTIFICATIONS: Notification ID: ${notification.id}');

      final inviteData = notification.data as Map<String, dynamic>;
      final inviteId = inviteData['id'];
      final psychologistId = inviteData['psychologist_id'];
      final currentUser = SupabaseService.client.auth.currentUser;

      debugPrint('🔍 NOTIFICATIONS: Dados completos do convite:');
      debugPrint('🔍 NOTIFICATIONS: - inviteId: $inviteId');
      debugPrint('🔍 NOTIFICATIONS: - psychologistId: $psychologistId');
      debugPrint('🔍 NOTIFICATIONS: - currentUser.id: ${currentUser?.id}');
      debugPrint('🔍 NOTIFICATIONS: - currentUser.email: ${currentUser?.email}');
      debugPrint('🔍 NOTIFICATIONS: - inviteData completo: $inviteData');

      if (currentUser?.id == null) {
        debugPrint('❌ NOTIFICATIONS: ERRO - Usuário não autenticado');
        throw Exception('Usuário não autenticado');
      }

      if (inviteId == null) {
        debugPrint('❌ NOTIFICATIONS: ERRO - inviteId é null');
        throw Exception('ID do convite é null');
      }

      if (psychologistId == null) {
        debugPrint('❌ NOTIFICATIONS: ERRO - psychologistId é null');
        throw Exception('ID do psicólogo é null');
      }

      // ETAPA 1: Atualizar psychologists_patients
      debugPrint('📝 NOTIFICATIONS: ETAPA 1 - Atualizando psychologists_patients...');
      
      try {
        final updateData = {
          'status': 'active',
          'patient_id': currentUser!.id,
          'started_at': DateTime.now().toIso8601String(),
        };
        
        debugPrint('📝 NOTIFICATIONS: Dados para atualização: $updateData');
        debugPrint('📝 NOTIFICATIONS: Executando update em psychologists_patients...');
        
        final result1 = await SupabaseService.client
            .from('psychologists_patients')
            .update(updateData)
            .eq('id', inviteId)
            .select();

        debugPrint('✅ NOTIFICATIONS: ETAPA 1 CONCLUÍDA - psychologists_patients atualizado');
        debugPrint('✅ NOTIFICATIONS: Resultado: $result1');
        
      } catch (e1) {
        debugPrint('❌ NOTIFICATIONS: ERRO na ETAPA 1: $e1');
        throw Exception('Erro ao atualizar psychologists_patients: $e1');
      }

      // ETAPA 2: Atualizar user_profiles
      debugPrint('👤 NOTIFICATIONS: ETAPA 2 - Atualizando user_profiles...');
      
      try {
        final profileUpdateData = {
          'psychologist_id': psychologistId,
          'updated_at': DateTime.now().toIso8601String(),
        };
        
        debugPrint('👤 NOTIFICATIONS: Dados para atualização do perfil: $profileUpdateData');
        debugPrint('👤 NOTIFICATIONS: Executando update em user_profiles...');
        
        final result2 = await SupabaseService.client
            .from('user_profiles')
            .update(profileUpdateData)
            .eq('user_id', currentUser.id)
            .select();

        debugPrint('✅ NOTIFICATIONS: ETAPA 2 CONCLUÍDA - user_profiles atualizado');
        debugPrint('✅ NOTIFICATIONS: Resultado: $result2');
        
        if (result2.isEmpty) {
          debugPrint('⚠️ NOTIFICATIONS: AVISO - Nenhuma linha foi atualizada em user_profiles');
          debugPrint('⚠️ NOTIFICATIONS: Isso pode indicar que o user_id não existe na tabela');
          
          // Verificar se o perfil existe
          final existingProfile = await SupabaseService.client
              .from('user_profiles')
              .select('*')
              .eq('user_id', currentUser.id)
              .maybeSingle();
              
          debugPrint('🔍 NOTIFICATIONS: Perfil existente: $existingProfile');
          
          if (existingProfile == null) {
            debugPrint('❌ NOTIFICATIONS: ERRO - Perfil do usuário não existe na tabela user_profiles');
            throw Exception('Perfil do usuário não encontrado');
          }
        }
        
      } catch (e2) {
        debugPrint('❌ NOTIFICATIONS: ERRO na ETAPA 2: $e2');
        throw Exception('Erro ao atualizar user_profiles: $e2');
      }

      // ETAPA 3: Verificar se as atualizações foram bem-sucedidas
      debugPrint('🔍 NOTIFICATIONS: ETAPA 3 - Verificando atualizações...');
      
      try {
        // Verificar psychologists_patients
        final updatedInvite = await SupabaseService.client
            .from('psychologists_patients')
            .select('*')
            .eq('id', inviteId)
            .single();
            
        debugPrint('🔍 NOTIFICATIONS: Convite após atualização: $updatedInvite');
        
        // Verificar user_profiles
        final updatedProfile = await SupabaseService.client
            .from('user_profiles')
            .select('*')
            .eq('user_id', currentUser.id)
            .single();
            
        debugPrint('🔍 NOTIFICATIONS: Perfil após atualização: $updatedProfile');
        
        // Validar se as atualizações foram aplicadas
        if (updatedInvite['status'] != 'active') {
          debugPrint('❌ NOTIFICATIONS: ERRO - Status do convite não foi atualizado para active');
          throw Exception('Status do convite não foi atualizado');
        }
        
        if (updatedProfile['psychologist_id'] != psychologistId) {
          debugPrint('❌ NOTIFICATIONS: ERRO - psychologist_id não foi atualizado no perfil');
          throw Exception('psychologist_id não foi atualizado no perfil');
        }
        
        debugPrint('✅ NOTIFICATIONS: ETAPA 3 CONCLUÍDA - Todas as atualizações verificadas');
        
      } catch (e3) {
        debugPrint('❌ NOTIFICATIONS: ERRO na ETAPA 3: $e3');
        throw Exception('Erro ao verificar atualizações: $e3');
      }

      // ETAPA 4: Atualizar UI
      debugPrint('🎨 NOTIFICATIONS: ETAPA 4 - Atualizando interface...');
      
      setState(() {
        _notifications.removeWhere((item) => item.id == notification.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Convite aceito com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      debugPrint('🎉 NOTIFICATIONS: ===== CONVITE ACEITO COM SUCESSO =====');
      debugPrint('🎉 NOTIFICATIONS: Vinculação completa realizada!');
      
    } catch (e, stackTrace) {
      debugPrint('💥 NOTIFICATIONS: ===== ERRO CRÍTICO =====');
      debugPrint('💥 NOTIFICATIONS: Erro: $e');
      debugPrint('💥 NOTIFICATIONS: Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro ao aceitar convite: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  /// Rejeitar convite de psicólogo
  Future<void> _rejectInvite(NotificationItem notification) async {
    try {
      debugPrint('❌ NOTIFICATIONS: Rejeitando convite: ${notification.id}');

      final inviteData = notification.data as Map<String, dynamic>;
      final inviteId = inviteData['id'];

      // Atualizar status no banco
      await SupabaseService.client
          .from('psychologists_patients')
          .update({'status': 'rejected'}).eq('id', inviteId);

      // Remover da lista local
      setState(() {
        _notifications.removeWhere((item) => item.id == notification.id);
      });

      // Mostrar feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Convite rejeitado'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }

      debugPrint('❌ NOTIFICATIONS: Convite rejeitado com sucesso');
    } catch (e) {
      debugPrint('❌ NOTIFICATIONS: Erro ao rejeitar convite: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro ao rejeitar convite: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _onNotificationTap(NotificationItem notification) {
    switch (notification.type) {
      case NotificationType.psychologistInvite:
        // Navegar para tela de convites
        Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (context) => const PendingInvitationsScreen(),
              ),
            )
            .then((_) => _loadNotifications());
        break;

      case NotificationType.reportResponse:
        // Navegar para detalhes da denúncia
        final report = notification.data as AiContentReport;
        context.pushNamed(
          'report-details',
          pathParameters: {'reportId': report.id},
        ).then((_) => _loadNotifications());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        '🎨 NOTIFICATIONS: Build chamado. _notifications.length: ${_notifications.length}');
    debugPrint('🎨 NOTIFICATIONS: _isLoading: $_isLoading');
    debugPrint('🎨 NOTIFICATIONS: _errorMessage: $_errorMessage');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Notificações',
          style: TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF9C89B8),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar notificações',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadNotifications,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C89B8),
                foregroundColor: Colors.white,
              ),
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma Notificação',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Você não tem notificações pendentes.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      color: const Color(0xFF9C89B8),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildNotificationCard(notification),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Ícone da notificação
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color:
                      _getNotificationColor(notification.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: _getNotificationColor(notification.type),
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // Conteúdo da notificação
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF22223B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTimestamp(notification.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),

              // Botão de excluir apenas para denúncias
              if (notification.type == NotificationType.reportResponse)
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                  onPressed: () => _removeNotification(notification),
                  tooltip: 'Excluir notificação',
                ),
            ],
          ),

          // Botões de ação para convites de psicólogos
          if (notification.type == NotificationType.psychologistInvite) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _acceptInvite(notification),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Aceitar',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _rejectInvite(notification),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Rejeitar',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Área clicável para denúncias (navegar para detalhes)
          if (notification.type == NotificationType.reportResponse)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _onNotificationTap(notification),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Toque para ver detalhes',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.psychologistInvite:
        return Icons.person_add;
      case NotificationType.reportResponse:
        return Icons.reply;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.psychologistInvite:
        return Colors.blue;
      case NotificationType.reportResponse:
        return Colors.green;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Agora';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}min atrás';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h atrás';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  Future<void> _clearAllNotifications() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Notificações'),
        content:
            const Text('Tem certeza que deseja excluir todas as notificações?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir Todas'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _notifications.clear();
      });
    }
  }

  /// Método de debug para testar convites
  Future<void> _debugTestInvites() async {
    try {
      debugPrint('🐛 DEBUG: Testando carregamento de convites...');

      final currentUser = SupabaseService.client.auth.currentUser;
      debugPrint('🐛 DEBUG: Usuário: ${currentUser?.id}');
      debugPrint('🐛 DEBUG: Email: ${currentUser?.email}');

      if (currentUser?.email == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Usuário não tem email'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Testar query direta
      final allInvites = await SupabaseService.client
          .from('psychologists_patients')
          .select('*');

      debugPrint('🐛 DEBUG: Total de convites na tabela: ${allInvites.length}');

      final userInvites = await SupabaseService.client
          .from('psychologists_patients')
          .select('*')
          .eq('patient_email', currentUser!.email!);

      debugPrint('🐛 DEBUG: Convites para este email: ${userInvites.length}');

      final pendingInvites = await SupabaseService.client
          .from('psychologists_patients')
          .select('*')
          .eq('patient_email', currentUser.email!)
          .eq('status', 'pending');

      debugPrint('🐛 DEBUG: Convites pendentes: ${pendingInvites.length}');

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Debug Convites'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email: ${currentUser.email}'),
                Text('Total na tabela: ${allInvites.length}'),
                Text('Para este email: ${userInvites.length}'),
                Text('Pendentes: ${pendingInvites.length}'),
                const SizedBox(height: 16),
                const Text('Dados no console!'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('🐛 DEBUG: Erro: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro no debug: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

/// Modelo para item de notificação
class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final dynamic data;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.data,
  });
}

/// Tipos de notificação
enum NotificationType {
  psychologistInvite,
  reportResponse,
}
