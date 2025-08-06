import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:calma_flutter/core/di/injection.dart';
import 'package:calma_flutter/core/services/supabase_service.dart';
import 'package:calma_flutter/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:calma_flutter/features/profile/presentation/viewmodels/user_profile_viewmodel.dart';
import 'package:calma_flutter/features/profile/presentation/components/profile_header.dart';
import 'package:calma_flutter/features/profile/presentation/components/profile_menu_item.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with WidgetsBindingObserver {
  late final AuthViewModel _authViewModel;
  late final UserProfileViewModel _profileViewModel;
  bool _hasNavigatedToWebapp = false;

  @override
  void initState() {
    super.initState();
    _authViewModel = getIt<AuthViewModel>();
    _profileViewModel = getIt<UserProfileViewModel>();
    WidgetsBinding.instance.addObserver(this);
    _loadProfile();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Quando o app volta ao foreground após navegar para o webapp
    if (state == AppLifecycleState.resumed && _hasNavigatedToWebapp) {
      debugPrint('🔄 App voltou ao foreground, recarregando perfil...');
      _loadProfile();
      _hasNavigatedToWebapp = false; // Reset flag
    }
  }

  Future<void> _loadProfile() async {
    final user = _authViewModel.currentUser;
    if (user != null) {
      await _profileViewModel.loadProfile(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Perfil',
          style: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: AnimatedBuilder(
        animation: _profileViewModel,
        builder: (context, child) {
          if (_profileViewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF9C89B8),
              ),
            );
          }

          if (_profileViewModel.errorMessage != null) {
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
                    'Erro ao carregar perfil',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _profileViewModel.errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadProfile,
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header do perfil
                ProfileHeader(
                  profile: _profileViewModel.currentProfile,
                  user: _authViewModel.currentUser,
                  onEditPressed: () => _navigateToEditProfile(),
                ),
                
                const SizedBox(height: 24),

                // Seção de dados pessoais
                if (_profileViewModel.hasProfileLoaded) ...[
                  _buildPersonalDataSection(),
                  const SizedBox(height: 16),
                  _buildObjectivesSection(),
                  const SizedBox(height: 24),
                ],

                // Menu de configurações
                _buildSettingsSection(),
                
                const SizedBox(height: 24),

                // Seção de conta
                _buildAccountSection(),
                
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPersonalDataSection() {
    final profile = _profileViewModel.currentProfile!;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
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
              Icon(
                Icons.person_outline,
                color: Colors.grey[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Meus Dados',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDataRow('Gênero', profile.gender),
          const SizedBox(height: 12),
          _buildDataRow('Idade', profile.ageRange),
          const SizedBox(height: 12),
          _buildDataRow('Experiência', profile.mentalHealthExperience),
        ],
      ),
    );
  }

  Widget _buildObjectivesSection() {
    final profile = _profileViewModel.currentProfile!;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
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
              Icon(
                Icons.flag_outlined,
                color: Colors.grey[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Meus Objetivos com a AIA',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...profile.aiaObjectives.map((objective) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: const Color(0xFF9C89B8),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    objective,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
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
        children: [
          ProfileMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Lembretes',
            subtitle: 'Gerenciar notificações',
            onTap: () => context.pushNamed('reminders'),
          ),
          const Divider(height: 1),
          ProfileMenuItem(
            icon: Icons.help_outline,
            title: 'Ajuda e Suporte',
            subtitle: 'Central de ajuda',
            onTap: () => context.pushNamed('help-support'),
          ),
          const Divider(height: 1),
          ProfileMenuItem(
            icon: Icons.description_outlined,
            title: 'Termos de Uso',
            subtitle: 'Condições de uso do app',
            onTap: () => context.pushNamed('terms'),
          ),
          const Divider(height: 1),
          ProfileMenuItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Política de Privacidade',
            subtitle: 'Como tratamos seus dados',
            onTap: () => context.pushNamed('privacy'),
          ),
          const Divider(height: 1),
          ProfileMenuItem(
            icon: Icons.report_outlined,
            title: 'Denúncias',
            subtitle: 'Minhas denúncias enviadas',
            onTap: () => context.pushNamed('reports'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ProfileMenuItem(
        icon: Icons.logout,
        title: 'Sair da Conta',
        subtitle: 'Fazer logout do aplicativo',
        titleColor: Colors.red[600],
        iconColor: Colors.red[600],
        onTap: _showLogoutDialog,
      ),
    );
  }

  void _navigateToEditProfile() async {
    try {
      debugPrint('🚀 PROFILE: Iniciando navegação para edição de perfil...');
      
      // Verificar se o usuário está autenticado
      final user = _authViewModel.currentUser;
      if (user == null) {
        debugPrint('❌ PROFILE: Usuário não autenticado');
        _showErrorMessage('Usuário não autenticado');
        return;
      }

      debugPrint('✅ PROFILE: Usuário autenticado - ID: ${user.id}');
      debugPrint('✅ PROFILE: Email do usuário: ${user.email}');

      // URL do webapp para edição de perfil com user_id (CORRIGIDO PARA HTTPS)
      final webappUrl = 'https://calma.inventu.ai/user/profile?user_id=${user.id}';
      
      debugPrint('🔄 PROFILE: URL do webapp: $webappUrl');
      debugPrint('🔄 PROFILE: Tentando abrir webapp...');
      
      // Marcar que navegamos para o webapp
      _hasNavigatedToWebapp = true;
      
      // Tentar abrir a URL no navegador
      final uri = Uri.parse(webappUrl);
      debugPrint('🔄 PROFILE: URI parseada: $uri');
      debugPrint('🔄 PROFILE: Scheme: ${uri.scheme}');
      debugPrint('🔄 PROFILE: Host: ${uri.host}');
      debugPrint('🔄 PROFILE: Path: ${uri.path}');
      debugPrint('🔄 PROFILE: Query: ${uri.query}');
      
      debugPrint('🔄 PROFILE: Verificando se pode abrir URL...');
      final canLaunch = await canLaunchUrl(uri);
      debugPrint('🔄 PROFILE: canLaunchUrl resultado: $canLaunch');
      
      if (canLaunch) {
        debugPrint('✅ PROFILE: URL pode ser aberta, lançando...');
        
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Abre no navegador externo
        );
        
        debugPrint('✅ PROFILE: launchUrl executado com sucesso');
      } else {
        debugPrint('❌ PROFILE: canLaunchUrl retornou false');
        // Reset flag se falhou
        _hasNavigatedToWebapp = false;
        
        // Tentar com modo diferente como fallback
        debugPrint('🔄 PROFILE: Tentando com LaunchMode.platformDefault...');
        try {
          await launchUrl(
            uri,
            mode: LaunchMode.platformDefault,
          );
          debugPrint('✅ PROFILE: Sucesso com LaunchMode.platformDefault');
          _hasNavigatedToWebapp = true; // Restaurar flag
        } catch (e2) {
          debugPrint('❌ PROFILE: Falha também com LaunchMode.platformDefault: $e2');
          _showWebappUnavailableDialog(webappUrl, 'canLaunchUrl retornou false');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ PROFILE: Erro crítico ao abrir webapp: $e');
      debugPrint('❌ PROFILE: Stack trace: $stackTrace');
      
      // Reset flag se falhou
      _hasNavigatedToWebapp = false;
      _showWebappUnavailableDialog('URL não informada', e.toString());
    }
  }

  void _showWebappUnavailableDialog([String? url, String? error]) {
    debugPrint('🚨 PROFILE: Mostrando diálogo de webapp indisponível');
    debugPrint('🚨 PROFILE: URL tentada: $url');
    debugPrint('🚨 PROFILE: Erro: $error');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Webapp Indisponível'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Não foi possível abrir o webapp para edição de perfil.'
            ),
            if (url != null) ...[
              const SizedBox(height: 8),
              Text(
                'URL: $url',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontFamily: 'monospace',
                ),
              ),
            ],
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(
                'Erro: $error',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red[600],
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Text('Deseja usar a tela de edição nativa do aplicativo?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Usar a tela nativa como fallback
              context.pushNamed('edit-profile');
            },
            child: const Text('Usar Tela Nativa'),
          ),
        ],
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature em breve!'),
        backgroundColor: const Color(0xFF9C89B8),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da Conta'),
        content: const Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _performLogout();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red[600],
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Fazer logout
      await _authViewModel.signOut();
      
      // Limpar dados do perfil
      _profileViewModel.clear();

      // Fechar loading
      if (mounted) {
        Navigator.of(context).pop();
        
        // Navegar diretamente para a rota welcome usando path absoluto
        // Isso evita que o redirecionamento global interfira
        context.go('/');
      }
    } catch (e) {
      // Fechar loading
      if (mounted) {
        Navigator.of(context).pop();
        
        // Mostrar erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao sair: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
