import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/reminder_model.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/reminder_card.dart';
import '../services/reminder_service.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({Key? key}) : super(key: key);

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen>
    with TickerProviderStateMixin {
  
  // Animation controllers
  late AnimationController _fadeInController;
  late AnimationController _fabController;
  
  // Animations
  late Animation<double> _fadeInOpacity;
  late Animation<double> _fabScale;
  
  // State management
  List<ReminderModel> _allReminders = [];
  List<ReminderModel> _filteredReminders = [];
  bool _isLoading = false;
  String _selectedFilter = 'all';
  int _currentNavIndex = 2;
  
  // Search
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadUserReminders();
    _searchController.addListener(_onSearchChanged);
  }

  void _initializeControllers() {
    _fadeInController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeInOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeInController,
      curve: Curves.easeOut,
    ));
    
    _fabScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    ));
    
    _fadeInController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _fabController.forward();
    });
  }

  /// Carrega os lembretes reais do usuário via ReminderService
  Future<void> _loadUserReminders() async {
    print('📋 Carregando lembretes do usuário...');
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Carregar apenas dados reais do Supabase
      final reminders = await ReminderService.getUserReminders();
      
      setState(() {
        _allReminders = reminders;
        _isLoading = false;
      });
      
      _applyFilter();
      print('✅ Lembretes carregados: ${_allReminders.length} itens');
      
    } catch (e) {
      print('❌ Erro ao carregar lembretes: $e');
      
      setState(() {
        _allReminders = [];
        _isLoading = false;
      });
      
      _applyFilter();
      _showErrorSnackBar('Erro ao carregar lembretes: $e');
    }
  }

  void _onSearchChanged() {
    _applyFilter();
  }

  void _applyFilter() {
    List<ReminderModel> filtered = List.from(_allReminders);
    
    // Apply status filter
    switch (_selectedFilter) {
      case 'active':
        filtered = filtered.where((r) => r.isActive).toList();
        break;
      case 'completed':
        filtered = filtered.where((r) => r.isCompleted).toList();
        break;
      case 'overdue':
        filtered = filtered.where((r) => r.isOverdue).toList();
        break;
      case 'upcoming':
        filtered = filtered.where((r) => r.isUpcoming).toList();
        break;
    }
    
    // Apply search filter
    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((r) => 
        r.eventName.toLowerCase().contains(searchQuery)
      ).toList();
    }
    
    setState(() {
      _filteredReminders = filtered;
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _applyFilter();
  }

  int _getFilterCount(String filter) {
    switch (filter) {
      case 'all':
        return _allReminders.length;
      case 'active':
        return _allReminders.where((r) => r.isActive).length;
      case 'completed':
        return _allReminders.where((r) => r.isCompleted).length;
      case 'overdue':
        return _allReminders.where((r) => r.isOverdue).length;
      case 'upcoming':
        return _allReminders.where((r) => r.isUpcoming).length;
      default:
        return 0;
    }
  }

  /// Atualiza status do lembrete no backend
  Future<void> _updateReminderStatus(String reminderId, String status) async {
    print('📝 Updating reminder $reminderId to status: $status');
    
    try {
      // Tentar atualizar no backend primeiro
      await ReminderService.updateReminderStatus(reminderId, status);
      
      // Se deu certo, atualizar localmente
      setState(() {
        final index = _allReminders.indexWhere((r) => r.id == reminderId);
        if (index != -1) {
          _allReminders[index] = _allReminders[index].copyWith(
            status: status,
            updatedAt: DateTime.now(),
          );
        }
      });
      
      _applyFilter();
      _showSuccessSnackBar('Lembrete atualizado com sucesso!');
      
    } catch (e) {
      print('❌ Erro ao atualizar lembrete: $e');
      _showErrorSnackBar('Erro ao atualizar lembrete: $e');
    }
  }

  /// Deleta lembrete no backend
  Future<void> _deleteReminder(String reminderId) async {
    print('🗑️ Deleting reminder $reminderId');
    
    try {
      // Tentar deletar no backend primeiro
      await ReminderService.deleteReminder(reminderId);
      
      // Se deu certo, remover localmente
      setState(() {
        _allReminders.removeWhere((r) => r.id == reminderId);
      });
      
      _applyFilter();
      _showSuccessSnackBar('Lembrete deletado com sucesso!');
      
    } catch (e) {
      print('❌ Erro ao deletar lembrete: $e');
      _showErrorSnackBar('Erro ao deletar lembrete: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 100, left: 20, right: 20),
      ),
    );
  }
  
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 100, left: 20, right: 20),
      ),
    );
  }

  void _onNavTap(int index) {
    print('🔄 Navigation tapped in Reminders: index $index');
    
    setState(() {
      _currentNavIndex = index;
    });
    
    switch (index) {
      case 0: // Chat
        print('📱 Returning to Chat screen');
        Navigator.pop(context);
        break;
      case 1: // Partners
        print('🏢 Partners navigation from Reminders');
        break;
      case 2: // Reminders - já estamos aqui
        print('⏰ Already on Reminders screen');
        break;
      case 3: // Settings
        print('⚙️ Settings navigation from Reminders');
        break;
    }
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    _fabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 Building RemindersScreen with ${_filteredReminders.length} filtered reminders');
    
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      body: AnimatedBuilder(
        animation: _fadeInOpacity,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeInOpacity.value,
            child: Stack(
              children: [
                // Background gradient
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF0F0F23),
                        Color(0xFF1A1A2E),
                        Color(0xFF16213E),
                      ],
                    ),
                  ),
                ),
                
                // Main content
                SafeArea(
                  child: Column(
                    children: [
                      // Header
                      _buildHeader(),
                      
                      // Search and Filters
                      _buildSearchAndFilters(),
                      
                      // Content
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _buildContent(),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Floating Action Button
                _buildFloatingActionButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withOpacity(0.1),
            Colors.purple.withOpacity(0.05),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          // Back Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () {
                print('⬅️ Back button pressed in Reminders');
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Reminders',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  '${_filteredReminders.length} reminders',
                  style: GoogleFonts.inter(
                    color: Colors.white60,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          
          // Action buttons
          Row(
            children: [
              // Search Toggle
              Container(
                decoration: BoxDecoration(
                  color: _isSearching 
                      ? Colors.blue.withOpacity(0.2)
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                      if (!_isSearching) {
                        _searchController.clear();
                      }
                    });
                  },
                  icon: Icon(
                    _isSearching ? Icons.close : Icons.search,
                    color: _isSearching ? Colors.blue : Colors.white70,
                    size: 22,
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Refresh Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {
                    print('🔄 Refresh button pressed');
                    _loadUserReminders();
                  },
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white70,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Search Bar
          if (_isSearching)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Search reminders...',
                  hintStyle: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.blue.withOpacity(0.7),
                    size: 22,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _applyFilter();
                          },
                          icon: Icon(
                            Icons.clear,
                            color: Colors.white.withOpacity(0.5),
                            size: 20,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          
          // Filter Chips
          Container(
            height: 60,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 5),
              children: [
                _buildFilterChip('all', 'All', Icons.list),
                _buildFilterChip('active', 'Active', Icons.alarm),
                _buildFilterChip('upcoming', 'Upcoming', Icons.schedule),
                _buildFilterChip('overdue', 'Overdue', Icons.warning),
                _buildFilterChip('completed', 'Completed', Icons.check_circle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final isSelected = _selectedFilter == value;
    final count = _getFilterCount(value);
    
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onFilterChanged(value),
          borderRadius: BorderRadius.circular(25),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected 
                  ? Colors.blue.withOpacity(0.2)
                  : Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected 
                    ? Colors.blue.withOpacity(0.6) 
                    : Colors.white.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? Colors.blue : Colors.white70,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: isSelected ? Colors.blue : Colors.white70,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Colors.blue.withOpacity(0.3)
                          : Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      count.toString(),
                      style: GoogleFonts.inter(
                        color: isSelected ? Colors.blue : Colors.white60,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      );
    }

    if (_filteredReminders.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _filteredReminders.length,
      itemBuilder: (context, index) {
        final reminder = _filteredReminders[index];
        return ReminderCard(
          reminder: reminder,
          onStatusChanged: (status) => _updateReminderStatus(reminder.id, status),
          onDelete: () => _deleteReminder(reminder.id),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;
    
    switch (_selectedFilter) {
      case 'active':
        message = 'No active reminders';
        icon = Icons.alarm_off;
        break;
      case 'completed':
        message = 'No completed reminders';
        icon = Icons.check_circle_outline;
        break;
      case 'overdue':
        message = 'No overdue reminders';
        icon = Icons.warning_amber;
        break;
      case 'upcoming':
        message = 'No upcoming reminders';
        icon = Icons.schedule;
        break;
      default:
        message = 'No reminders yet';
        icon = Icons.alarm_add;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.white30,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.inter(
              color: Colors.white60,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Mostra dialog para criar novo lembrete
  void _showCreateReminderDialog() {
    final eventController = TextEditingController();
    final timeController = TextEditingController(text: 'em 1 hora');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          'Criar Lembrete',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Campo do evento
            TextField(
              controller: eventController,
              style: GoogleFonts.inter(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Nome do evento',
                labelStyle: GoogleFonts.inter(color: Colors.white70),
                hintText: 'Ex: reunião com equipe',
                hintStyle: GoogleFonts.inter(color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.white30),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Campo do tempo
            TextField(
              controller: timeController,
              style: GoogleFonts.inter(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Quando lembrar',
                labelStyle: GoogleFonts.inter(color: Colors.white70),
                hintText: 'Ex: em 2 horas, amanhã às 9h',
                hintStyle: GoogleFonts.inter(color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.white30),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final eventName = eventController.text.trim();
              final timeExpression = timeController.text.trim();
              
              if (eventName.isNotEmpty) {
                Navigator.pop(context);
                await _createReminderViaAI(eventName, timeExpression);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: Text(
              'Criar',
              style: GoogleFonts.inter(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Cria lembrete via AIA
  Future<void> _createReminderViaAI(String eventName, String timeExpression) async {
    print('🤖 Criando lembrete via AIA: "$eventName" $timeExpression');
    
    try {
      final success = await ReminderService.createReminderViaAI(
        eventName: eventName,
        timeExpression: timeExpression,
      );
      
      if (success) {
        _showSuccessSnackBar('Lembrete criado com sucesso!');
        // Recarregar a lista para mostrar o novo lembrete
        _loadUserReminders();
      } else {
        _showErrorSnackBar('Falha ao criar lembrete. Tente novamente.');
      }
      
    } catch (e) {
      print('❌ Erro ao criar lembrete via AIA: $e');
      _showErrorSnackBar('Erro ao criar lembrete: $e');
    }
  }

  Widget _buildFloatingActionButton() {
    return Positioned(
      bottom: 30,
      right: 30,
      child: AnimatedBuilder(
        animation: _fabScale,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabScale.value,
            child: FloatingActionButton(
              onPressed: _showCreateReminderDialog,
              backgroundColor: Colors.blue,
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 28,
              ),
            ),
          );
        },
      ),
    );
  }
}
