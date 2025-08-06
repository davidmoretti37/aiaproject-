import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/call_session_repository.dart';
import '../../domain/models/call_session_model.dart';

/// ViewModel para gerenciar o estado da tela de insights
class InsightsViewModel extends ChangeNotifier {
  final CallSessionRepository _repository;

  /// Lista de sessões do usuário
  List<CallSessionModel> _sessions = [];
  
  /// Indica se está carregando dados
  bool _isLoading = false;
  
  /// Mensagem de erro, se houver
  String? _errorMessage;
  
  /// Última vez que os dados foram atualizados
  DateTime? _lastUpdated;

  /// Construtor do ViewModel
  InsightsViewModel(this._repository) {
    _loadSessions();
  }

  /// Getters
  List<CallSessionModel> get sessions => List.unmodifiable(_sessions);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get lastUpdated => _lastUpdated;
  
  /// Verifica se há sessões para exibir
  bool get hasSessions => _sessions.isNotEmpty;
  
  /// Verifica se deve exibir o estado vazio
  bool get shouldShowEmptyState => !_isLoading && _sessions.isEmpty;

  /// Carrega as sessões do usuário
  Future<void> _loadSessions() async {
    try {
      debugPrint('🔄 INSIGHTS_VM: Carregando sessões...');
      
      _setLoading(true);
      _clearError();
      
      final sessions = await _repository.getUserSessions();
      
      _sessions = sessions;
      _lastUpdated = DateTime.now();
      
      debugPrint('✅ INSIGHTS_VM: ${sessions.length} sessões carregadas');
    } catch (e) {
      debugPrint('❌ INSIGHTS_VM: Erro ao carregar sessões: $e');
      _setError('Erro ao carregar insights: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Recarrega as sessões
  Future<void> refreshSessions() async {
    debugPrint('🔄 INSIGHTS_VM: Atualizando sessões...');
    await _loadSessions();
  }

  /// Busca sessões por período específico
  Future<void> loadSessionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      debugPrint('🔄 INSIGHTS_VM: Carregando sessões por período...');
      
      _setLoading(true);
      _clearError();
      
      final sessions = await _repository.getSessionsByDateRange(
        startDate: startDate,
        endDate: endDate,
      );
      
      _sessions = sessions;
      _lastUpdated = DateTime.now();
      
      debugPrint('✅ INSIGHTS_VM: ${sessions.length} sessões carregadas para o período');
    } catch (e) {
      debugPrint('❌ INSIGHTS_VM: Erro ao carregar sessões por período: $e');
      _setError('Erro ao filtrar insights: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Busca sessões por mood específico
  Future<void> loadSessionsByMood(String mood) async {
    try {
      debugPrint('🔄 INSIGHTS_VM: Carregando sessões por mood: $mood');
      
      _setLoading(true);
      _clearError();
      
      final sessions = await _repository.getSessionsByMood(mood);
      
      _sessions = sessions;
      _lastUpdated = DateTime.now();
      
      debugPrint('✅ INSIGHTS_VM: ${sessions.length} sessões carregadas para mood $mood');
    } catch (e) {
      debugPrint('❌ INSIGHTS_VM: Erro ao carregar sessões por mood: $e');
      _setError('Erro ao filtrar por humor: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega apenas sessões recentes (últimos 7 dias)
  Future<void> loadRecentSessions() async {
    try {
      debugPrint('🔄 INSIGHTS_VM: Carregando sessões recentes...');
      
      _setLoading(true);
      _clearError();
      
      final sessions = await _repository.getRecentSessions();
      
      _sessions = sessions;
      _lastUpdated = DateTime.now();
      
      debugPrint('✅ INSIGHTS_VM: ${sessions.length} sessões recentes carregadas');
    } catch (e) {
      debugPrint('❌ INSIGHTS_VM: Erro ao carregar sessões recentes: $e');
      _setError('Erro ao carregar insights recentes: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Obtém estatísticas de distribuição de mood
  Future<Map<String, int>> getMoodDistribution() async {
    try {
      debugPrint('🔄 INSIGHTS_VM: Calculando distribuição de moods...');
      return await _repository.getMoodDistribution();
    } catch (e) {
      debugPrint('❌ INSIGHTS_VM: Erro ao calcular distribuição: $e');
      return {};
    }
  }

  /// Obtém estatísticas gerais do usuário
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      debugPrint('🔄 INSIGHTS_VM: Obtendo estatísticas do usuário...');
      return await _repository.getUserStats();
    } catch (e) {
      debugPrint('❌ INSIGHTS_VM: Erro ao obter estatísticas: $e');
      return {};
    }
  }

  /// Verifica se há novas sessões disponíveis
  Future<bool> checkForNewSessions() async {
    try {
      final hasNew = await _repository.hasNewSessions(since: _lastUpdated);
      if (hasNew) {
        debugPrint('🔔 INSIGHTS_VM: Novas sessões detectadas');
      }
      return hasNew;
    } catch (e) {
      debugPrint('❌ INSIGHTS_VM: Erro ao verificar novas sessões: $e');
      return false;
    }
  }

  /// Agrupa sessões por data para exibição organizada
  Map<String, List<CallSessionModel>> get sessionsByDate {
    final Map<String, List<CallSessionModel>> grouped = {};
    
    for (final session in _sessions) {
      final dateKey = _formatDateKey(session.createdAt);
      
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      
      grouped[dateKey]!.add(session);
    }
    
    return grouped;
  }

  /// Formata a data para agrupamento
  String _formatDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final sessionDate = DateTime(date.year, date.month, date.day);
    
    if (sessionDate == today) {
      return 'Hoje';
    } else if (sessionDate == yesterday) {
      return 'Ontem';
    } else {
      return DateFormat('d \'de\' MMMM', 'pt_BR').format(date);
    }
  }

  /// Formata data para exibição no card
  String formatSessionDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final sessionDate = DateTime(date.year, date.month, date.day);
    
    if (sessionDate == today) {
      return 'Hoje, ${DateFormat('HH:mm').format(date)}';
    } else if (sessionDate == yesterday) {
      return 'Ontem, ${DateFormat('HH:mm').format(date)}';
    } else {
      return DateFormat('d \'de\' MMMM \'de\' y, HH:mm', 'pt_BR').format(date);
    }
  }

  /// Obtém o mood mais comum
  String? get mostCommonMood {
    if (_sessions.isEmpty) return null;
    
    final Map<String, int> moodCount = {};
    
    for (final session in _sessions) {
      final mood = session.mood?.toLowerCase();
      if (mood != null) {
        moodCount[mood] = (moodCount[mood] ?? 0) + 1;
      }
    }
    
    if (moodCount.isEmpty) return null;
    
    String mostCommon = moodCount.keys.first;
    int maxCount = moodCount[mostCommon]!;
    
    moodCount.forEach((mood, count) {
      if (count > maxCount) {
        maxCount = count;
        mostCommon = mood;
      }
    });
    
    return mostCommon;
  }

  /// Obtém a sessão mais recente
  CallSessionModel? get latestSession {
    return _sessions.isNotEmpty ? _sessions.first : null;
  }

  /// Define estado de carregamento
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Define mensagem de erro
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Limpa mensagem de erro
  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Limpa mensagem de erro manualmente
  void clearError() {
    _clearError();
  }

  /// Reseta filtros e carrega todas as sessões
  Future<void> resetFilters() async {
    debugPrint('🔄 INSIGHTS_VM: Resetando filtros...');
    await _loadSessions();
  }
}
