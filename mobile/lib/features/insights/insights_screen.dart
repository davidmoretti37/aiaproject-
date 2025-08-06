import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'data/repositories/call_session_repository.dart';
import 'presentation/viewmodels/insights_viewmodel.dart';
import 'presentation/components/mood_card.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> with WidgetsBindingObserver {
  String formattedDate = '';
  bool isLocaleInitialized = false;
  late InsightsViewModel _viewModel;
  bool _isCurrentRoute = false;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    _initializeViewModel();
    
    // Registrar o observer para detectar mudanças de foco
    WidgetsBinding.instance.addObserver(this);
    
    // Marcar como rota atual quando inicializada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isCurrentRoute = true;
      });
      // Carregar dados iniciais
      _viewModel.refreshSessions();
    });
  }

  void _initializeViewModel() {
    final repository = CallSessionRepository();
    _viewModel = InsightsViewModel(repository);
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Quando o app volta para o primeiro plano, atualizar os dados
    if (state == AppLifecycleState.resumed && _isCurrentRoute) {
      debugPrint('📱 INSIGHTS: App voltou para o primeiro plano, atualizando dados...');
      _viewModel.refreshSessions();
    }
  }
  
  // Método chamado quando a rota é empilhada ou desempilhada
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Verificar se esta tela está em foco e atualizar os dados
    _checkIfCurrentRouteAndUpdate();
  }
  
  // Verifica se esta é a rota atual e atualiza os dados se necessário
  void _checkIfCurrentRouteAndUpdate() {
    // Usar ModalRoute para verificar se esta tela está em foco
    final isCurrent = ModalRoute.of(context)?.isCurrent ?? false;
    
    // Se a tela acabou de receber foco, atualizar os dados
    if (isCurrent && !_isCurrentRoute) {
      debugPrint('📱 INSIGHTS: Tela recebeu foco, atualizando dados...');
      _viewModel.refreshSessions();
    }
    
    // Atualizar o estado
    if (_isCurrentRoute != isCurrent) {
      setState(() {
        _isCurrentRoute = isCurrent;
      });
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

  @override
  void dispose() {
    // Remover o observer quando a tela for descartada
    WidgetsBinding.instance.removeObserver(this);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            // Barra superior com botão voltar, data e convidar psicólogo
            SafeArea(
              bottom: false,
              child: Container(
                color: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Row(
                  children: [
                    // Botão de voltar (esquerda)
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white70),
                      onPressed: () => context.pop(),
                    ),
                    const Spacer(),
                    // Data (centro)
                    Text(
                      isLocaleInitialized ? formattedDate : '...',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    // Convidar psicólogo (direita)
                    IconButton(
                      icon: const Icon(
                        Icons.person_add_alt_1,
                        color: Color(0xFF9D82FF),
                        size: 22,
                      ),
                      onPressed: () {
                        context.pushNamed('invite-psychologist');
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Conteúdo principal
            Expanded(
              child: Stack(
                children: [
                    // CONTAINER PRETO COM BORDER RADIUS
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Conteúdo principal
                          Expanded(
                            child: Consumer<InsightsViewModel>(
                              builder: (context, viewModel, child) {
                                if (viewModel.isLoading) {
                                  return _buildLoadingState();
                                }

                                if (viewModel.shouldShowEmptyState) {
                                  return _buildEmptyState();
                                }

                                return _buildInsightsList(viewModel);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            // Barra de navegação inferior (fora do SafeArea, colada na base)
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF1E1E1E),
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
                  _buildNavButton(
                    icon: Icons.lightbulb_outline,
                    text: 'Insights',
                    isActive: true,
                    onTap: () {},
                  ),
                  _buildNavButton(
                    imagePath:
                        'assets/images/1813edc8-2cfd-4f21-928d-16663b4fe844.png',
                    text: 'AIA',
                    isActive: false,
                    onTap: () {
                      context.goNamed('home');
                    },
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
          ],
        ),
      ),
    );
  }

  /// Constrói o estado de carregamento
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF9D82FF),
          ),
          SizedBox(height: 16),
          Text(
            'Carregando seus insights...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói o estado vazio (quando não há sessões)
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone principal
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.psychology,
                size: 64,
                color: Color(0xFF9D82FF),
              ),
            ),
            const SizedBox(height: 24),
            
            // Título principal
            const Text(
              'Seus insights aparecerão aqui',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF22223B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Descrição
            const Text(
              'Converse com a AIA para gerar insights\npersonalizados sobre sua jornada de bem-estar',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Botão para conversar com AIA
            GestureDetector(
              onTap: () {
                context.goNamed('home');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF9D82FF),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9D82FF).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/1813edc8-2cfd-4f21-928d-16663b4fe844.png',
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Conversar com AIA',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói a lista de insights com cards de mood
  Widget _buildInsightsList(InsightsViewModel viewModel) {
    return RefreshIndicator(
      onRefresh: viewModel.refreshSessions,
      color: const Color(0xFF9D82FF),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            // Cards de mood agrupados por data
            GroupedMoodCards(
              sessionsByDate: viewModel.sessionsByDate,
              viewModel: viewModel,
            ),
            
            const SizedBox(height: 80), // Espaço extra para a navegação inferior
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton({
    IconData? icon,
    String? imagePath,
    required String text,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          imagePath != null
              ? Image.asset(imagePath, width: 24)
              : Icon(
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
