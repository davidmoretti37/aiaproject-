import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:calma_flutter/core/constants/app_colors.dart';
import 'package:calma_flutter/core/di/injection.dart';
import 'package:calma_flutter/features/aia/presentation/components/particle_circle_icon.dart';
import 'package:calma_flutter/features/streak/services/streak_service.dart';
import 'package:calma_flutter/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:calma_flutter/features/insights/services/psychologist_invitation_checker_service.dart';
import 'package:calma_flutter/features/insights/presentation/screens/pending_invitations_screen.dart';
import 'package:calma_flutter/core/services/supabase_service.dart';
import 'package:calma_flutter/features/reports/data/repositories/reports_repository.dart';
import 'package:calma_flutter/features/reports/data/models/ai_content_report.dart';
import 'package:calma_flutter/features/notifications/services/notification_preferences_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  String formattedDate = '';
  bool isLocaleInitialized = false;
  int _currentStreak = 0;
  int _notificationCount = 0;
  int _reportsNotificationCount = 0;
  late StreakService _streakService;
  late AuthViewModel _authViewModel;
  late PsychologistInvitationCheckerService _invitationCheckerService;
  late ReportsRepository _reportsRepository;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    _initializeStreak();
    _initializeServices();
    _checkPendingInvitations();
    _checkReportResponses();
    
    // Registrar o observer para eventos de ciclo de vida
    WidgetsBinding.instance.addObserver(this);
  }
  
  @override
  void dispose() {
    // Remover o observer quando a tela for descartada
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Verificar convites pendentes quando o app volta ao primeiro plano
    if (state == AppLifecycleState.resumed) {
      debugPrint('🔔 HOME: App voltou ao primeiro plano, verificando convites pendentes');
      _checkPendingInvitations();
    }
  }
  
  void _initializeServices() {
    debugPrint('🔄 HOME: Iniciando inicialização de serviços');
    try {
      _authViewModel = getIt<AuthViewModel>();
      debugPrint('✅ HOME: AuthViewModel inicializado: ${_authViewModel.hashCode}');
      
      _invitationCheckerService = getIt<PsychologistInvitationCheckerService>();
      debugPrint('✅ HOME: InvitationCheckerService inicializado: ${_invitationCheckerService.hashCode}');
      
      _reportsRepository = ReportsRepository();
      debugPrint('✅ HOME: ReportsRepository inicializado');
    } catch (e, stackTrace) {
      debugPrint('❌ HOME: Erro ao inicializar serviços: $e');
      debugPrint('❌ HOME: Stack trace: $stackTrace');
    }
    debugPrint('🔄 HOME: Finalizada inicialização de serviços');
  }
  
  Future<void> _checkPendingInvitations() async {
    debugPrint('🔄 HOME: Verificando convites pendentes...');
    
    final currentUser = _authViewModel.currentUser;
    if (currentUser == null || currentUser.email == null) {
      debugPrint('⚠️ HOME: Usuário não autenticado ou sem email');
      return;
    }
    
    final email = currentUser.email!;
    debugPrint('🔄 HOME: Verificando convites para email: $email');
    
    try {
      // Verificar diretamente no Supabase para garantir que estamos obtendo os dados mais recentes
      final supabase = SupabaseService.client;
      final pendingInvites = await supabase
          .from('psychologists_patients')
          .select('*, psychologists(*)')
          .eq('patient_email', email)
          .eq('status', 'pending');
      
      debugPrint('✅ HOME: ${pendingInvites.length} convites pendentes encontrados');
      debugPrint('✅ HOME: Convites: $pendingInvites');
      
      setState(() {
        _notificationCount = pendingInvites.length;
      });
      
      // Removido o Snackbar automático conforme solicitado pelo usuário
      debugPrint('✅ HOME: Contador de notificações atualizado: $_notificationCount');
    } catch (e) {
      debugPrint('❌ HOME: Erro ao verificar convites pendentes: $e');
    }
  }

  /// Verificar denúncias com respostas não visualizadas
  Future<void> _checkReportResponses() async {
    debugPrint('🔄 HOME: Verificando respostas de denúncias...');
    
    final currentUser = _authViewModel.currentUser;
    if (currentUser == null) {
      debugPrint('⚠️ HOME: Usuário não autenticado');
      return;
    }
    
    try {
      final reports = await _reportsRepository.getUserReports(currentUser.id);
      debugPrint('🔄 HOME: Total de denúncias do usuário: ${reports.length}');
      
      // Obter lista de denúncias excluídas (NOVA FUNCIONALIDADE)
      final dismissedReports = await NotificationPreferencesService.getDismissedReports();
      debugPrint('🔄 HOME: Denúncias excluídas: ${dismissedReports.length}');
      debugPrint('🔄 HOME: IDs das denúncias excluídas: $dismissedReports');
      
      int resolvedCount = 0;
      int withResponseCount = 0;
      int dismissedCount = 0;
      int finalCount = 0;
      
      // Filtrar denúncias com resposta E não excluídas
      final reportsWithResponse = <AiContentReport>[];
      
      for (final report in reports) {
        debugPrint('🔄 HOME: Analisando denúncia ${report.id} - Status: ${report.status}, HasResponse: ${report.hasAdminResponse}');
        
        if (report.status == 'resolved') {
          resolvedCount++;
          
          if (report.hasAdminResponse) {
            withResponseCount++;
            
            // Verificar se a denúncia foi excluída (NOVA VERIFICAÇÃO)
            final isDismissed = dismissedReports.contains(report.id);
            debugPrint('🔄 HOME: Denúncia ${report.id} foi excluída: $isDismissed');
            
            if (isDismissed) {
              dismissedCount++;
              debugPrint('⚠️ HOME: Denúncia ${report.id} foi excluída, pulando...');
              continue; // Pular denúncias excluídas
            }
            
            // Adicionar apenas denúncias não excluídas
            reportsWithResponse.add(report);
            finalCount++;
            debugPrint('✅ HOME: Denúncia ${report.id} adicionada ao contador');
          }
        }
      }
      
      debugPrint('✅ HOME: Estatísticas de denúncias:');
      debugPrint('✅ HOME: - Total: ${reports.length}');
      debugPrint('✅ HOME: - Resolvidas: $resolvedCount');
      debugPrint('✅ HOME: - Com resposta: $withResponseCount');
      debugPrint('✅ HOME: - Excluídas: $dismissedCount');
      debugPrint('✅ HOME: - Finais (não excluídas): $finalCount');
      
      setState(() {
        _reportsNotificationCount = finalCount; // Usar contador filtrado
        // Atualizar contador total de notificações
        _notificationCount = _notificationCount + _reportsNotificationCount;
      });
      
      debugPrint('✅ HOME: Contador de respostas de denúncias (filtrado): $_reportsNotificationCount');
      debugPrint('✅ HOME: Contador total de notificações: $_notificationCount');
      
    } catch (e) {
      debugPrint('❌ HOME: Erro ao verificar respostas de denúncias: $e');
    }
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('pt_BR', null);
    final dateFormat = DateFormat('d \'de\' MMMM', 'pt_BR');
    setState(() {
      formattedDate = dateFormat.format(DateTime.now()).toLowerCase();
      isLocaleInitialized = true;
    });
  }
  
  Future<void> _initializeStreak() async {
    _streakService = getIt<StreakService>();
    await _streakService.checkAndUpdateStreak();
    
    setState(() {
      _currentStreak = _streakService.currentStreak;
    });
    
    debugPrint('🔥 HOME: Streak atual: $_currentStreak');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5EFFD),
        elevation: 0,
        automaticallyImplyLeading: false, // Remove o botão de voltar padrão
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
              const SizedBox(width: 4),
              Text(
                "$_currentStreak",
                style: const TextStyle(
                  color: Color(0xFF22223B),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        leadingWidth: 80, // Ajusta a largura do leading para acomodar o contador
        actions: [
          // Botão de notificações na AppBar
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.black54),
                onPressed: _openPendingInvitations,
              ),
              if (_notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      _notificationCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white70),
            onPressed: () => context.pushNamed('insights'),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: const BoxDecoration(
            color: Color(0xFF121212),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: const Text(
                  'A AIA foi programada especificamente pra você',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GestureDetector(
                  onTap: () => context.pushNamed('aia'),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Usando o círculo de partículas em vez da imagem colorida
                        const ParticleCircleIcon(size: 150),
                        const SizedBox(height: 24),
                        const Text(
                          'Fale com a AIA.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Espaço para o menu inferior
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 24,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Botão Insights foi removido
            _buildNavButton(
              useParticleCircle: true,
              text: 'AIA',
              isActive: true,
              onTap: () {},
            ),
            _buildNavButton(
              icon: Icons.person_outline,
              text: 'Você',
              isActive: false,
              onTap: () {
                context.pushNamed('profile');
              },
            ),
          ],
        ),
      ),
    );
  }
  
  // Método para abrir as notificações
  void _openPendingInvitations() {
    debugPrint('🔴 HOME: Navegando para tela de notificações');
    context.pushNamed('notifications').then((_) {
      // Recarregar contadores quando voltar da tela de notificações
      _checkPendingInvitations();
      _checkReportResponses();
    });
  }
  
  /// Mostrar diálogo com opções de notificações
  void _showNotificationOptionsDialog() {
    final invitesCount = _notificationCount - _reportsNotificationCount;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notificações'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (invitesCount > 0)
                ListTile(
                  leading: const Icon(Icons.person_add, color: Colors.blue),
                  title: Text('Convites de Psicólogos ($invitesCount)'),
                  subtitle: const Text('Novos convites pendentes'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _navigateToInvitations();
                  },
                ),
              if (_reportsNotificationCount > 0)
                ListTile(
                  leading: const Icon(Icons.reply, color: Colors.green),
                  title: Text('Respostas de Denúncias ($_reportsNotificationCount)'),
                  subtitle: const Text('Suas denúncias foram respondidas'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _navigateToReports();
                  },
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  /// Navegar para convites de psicólogos
  void _navigateToInvitations() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PendingInvitationsScreen(),
      ),
    ).then((_) {
      _checkPendingInvitations();
      _checkReportResponses();
    });
  }

  /// Navegar para denúncias
  void _navigateToReports() {
    context.pushNamed('reports').then((_) {
      _checkPendingInvitations();
      _checkReportResponses();
    });
  }

  /// Mostrar diálogo quando não há notificações
  void _showNoNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notificações'),
          content: const Text('Não há notificações pendentes.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Método para mostrar um diálogo quando não há convites (mantido para compatibilidade)
  void _showNoInvitationsDialog(BuildContext context) {
    _showNoNotificationsDialog(context);
  }
  
  // Método auxiliar para mostrar Snackbar (mantido para referência)
  void _showSnackBar(BuildContext context, String message) {
    debugPrint('🔔 HOME: Tentando mostrar Snackbar: $message');
    
    // Remover Snackbars anteriores
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    // Usar um método mais direto para mostrar o Snackbar
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Criar o Snackbar
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {
          scaffoldMessenger.hideCurrentSnackBar();
        },
      ),
    );
    
    // Mostrar o Snackbar
    final controller = scaffoldMessenger.showSnackBar(snackBar);
    
    // Verificar se o Snackbar foi mostrado
    controller.closed.then((reason) {
      debugPrint('🔔 HOME: Snackbar fechado: $reason');
    });
    
    debugPrint('🔔 HOME: Snackbar mostrado: $message');
  }
  
  Widget _buildNavButton({
    IconData? icon,
    String? imagePath,
    bool useParticleCircle = false,
    required String text,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (useParticleCircle)
            const ParticleCircleIcon(size: 24, isMini: true)
          else if (imagePath != null)
            Image.asset(imagePath, width: 24)
          else
            Icon(
              icon,
              color: isActive ? const Color(0xFF9D82FF) : Colors.grey,
              size: 24,
            ),
          const SizedBox(height: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? const Color(0xFF9D82FF) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
