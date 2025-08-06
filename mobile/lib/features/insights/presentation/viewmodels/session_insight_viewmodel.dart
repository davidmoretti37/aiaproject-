import 'package:calma_flutter/core/utils/string_extensions.dart';
import 'package:calma_flutter/features/insights/data/repositories/session_insight_repository.dart';
import 'package:calma_flutter/features/insights/domain/models/call_session_model.dart';
import 'package:calma_flutter/features/insights/domain/models/session_insight_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// ViewModel para gerenciar os insights de uma sessão
class SessionInsightViewModel extends ChangeNotifier {
  final SessionInsightRepository _repository;
  final CallSessionModel session;
  
  SessionInsightModel? _insight;
  bool _isLoading = true;
  String? _error;
  bool _isDeleting = false;

  SessionInsightViewModel(this._repository, this.session) {
    _loadInsight();
  }

  /// Getters
  SessionInsightModel? get insight => _insight;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isDeleting => _isDeleting;
  bool get hasInsight => _insight != null;
  
  /// Carrega o insight para a sessão atual
  Future<void> _loadInsight() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _insight = await _repository.getInsightBySessionId(session.id);
      
      // Se não encontrar um insight, cria um mock para demonstração
      if (_insight == null) {
        _insight = _createMockInsight();
      }
    } catch (e) {
      debugPrint('Erro ao carregar insight: $e');
      _error = 'Não foi possível carregar os detalhes do insight.';
      _insight = _createMockInsight(); // Usa mock em caso de erro
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Cria um insight mock para demonstração
  SessionInsightModel _createMockInsight() {
    return SessionInsightModel(
      id: 0,
      sessionId: session.id,
      createdAt: DateTime.now(),
      topics: _generateMockTopics(),
      aiAdvice: null,
      longSummary: null,
    );
  }
  
  /// Gera tópicos mock baseados no mood da sessão
  List<String> _generateMockTopics() {
    final mood = session.mood?.toLowerCase() ?? 'neutro';
    
    switch (mood) {
      case 'feliz':
        return [
          'Gratidão',
          'Conquistas pessoais',
          'Momentos de alegria',
          'Relacionamentos positivos',
          'Autocuidado'
        ];
      case 'triste':
        return [
          'Processando emoções',
          'Aceitação',
          'Autocuidado',
          'Busca de apoio',
          'Reflexão pessoal'
        ];
      case 'ansioso':
        return [
          'Técnicas de respiração',
          'Gerenciamento de estresse',
          'Preocupações futuras',
          'Mindfulness',
          'Autocompaixão'
        ];
      case 'irritado':
        return [
          'Gerenciamento de raiva',
          'Comunicação assertiva',
          'Limites pessoais',
          'Resolução de conflitos',
          'Autoconsciência'
        ];
      case 'neutro':
      default:
        return [
          'Autoconhecimento',
          'Equilíbrio emocional',
          'Rotina diária',
          'Objetivos pessoais',
          'Bem-estar geral'
        ];
    }
  }
  
  /// Exclui o insight e a sessão correspondente
  Future<bool> deleteInsightAndSession() async {
    _isDeleting = true;
    notifyListeners();
    
    try {
      await _repository.deleteInsightAndSession(session.id);
      return true;
    } catch (e) {
      debugPrint('Erro ao excluir insight e sessão: $e');
      _error = 'Não foi possível excluir o insight.';
      return false;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }
  
  /// Retorna um título expressivo baseado no mood
  String getEmotionalTitle() {
    final mood = session.mood?.toLowerCase() ?? 'neutro';
    
    switch (mood) {
      case 'feliz':
        return 'Seu Momento de Alegria';
      case 'triste':
        return 'Um Momento para Refletir';
      case 'ansioso':
        return 'Navegando pela Inquietude';
      case 'irritado':
        return 'Canalizando a Energia';
      case 'neutro':
      default:
        return 'Um Momento de Equilíbrio';
    }
  }
  
  /// Retorna uma frase introdutória que conecta a emoção aos tópicos
  String getEmotionalIntro() {
    final mood = session.mood?.toLowerCase() ?? 'neutro';
    final moodDescription = session.getMoodDescription().toLowerCase();
    
    return 'Sua conversa refletiu um estado de $moodDescription, onde você explorou temas importantes para seu bem-estar.';
  }
  
  /// Retorna um gradiente de cores baseado no mood
  List<Color> getMoodGradient() {
    final mood = session.mood?.toLowerCase() ?? 'neutro';
    
    switch (mood) {
      case 'feliz':
        return [const Color(0xFFFFF9C4), const Color(0xFFFFECB3)]; // Amarelo claro para amarelo mais forte
      case 'triste':
        return [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)]; // Azul muito claro para azul claro
      case 'ansioso':
        return [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)]; // Laranja muito claro para laranja claro
      case 'irritado':
        return [const Color(0xFFFFEBEE), const Color(0xFFFFCDD2)]; // Vermelho muito claro para vermelho claro
      case 'neutro':
      default:
        return [const Color(0xFFF5F5F5), const Color(0xFFE0E0E0)]; // Cinza muito claro para cinza claro
    }
  }
  
  /// Retorna uma cor para os chips de tópicos (roxo claro padrão)
  Color getTopicChipColor() {
    return const Color(0xFFF0EBFF); // Roxo muito claro
  }
  
  /// Retorna uma cor para o texto dos chips de tópicos (roxo padrão)
  Color getTopicTextColor() {
    return const Color(0xFF9D82FF); // Roxo padrão
  }
  
  /// Gera um texto de resumo genérico baseado no mood
  String getGenericSummary() {
    final mood = session.mood?.toLowerCase() ?? 'neutro';
    final baseSummary = session.summary ?? 'Conversa com a AIA';
    
    switch (mood) {
      case 'feliz':
        return '$baseSummary\n\nEsta conversa revelou um estado de espírito positivo, com foco em experiências que trazem alegria e satisfação. Foram identificados momentos de gratidão e reconhecimento de conquistas pessoais, demonstrando uma perspectiva otimista sobre a vida.';
      case 'triste':
        return '$baseSummary\n\nDurante esta conversa, foram expressados sentimentos de tristeza e reflexão sobre situações desafiadoras. Houve um processo importante de reconhecimento e validação dessas emoções, abrindo caminho para a aceitação e eventual superação.';
      case 'ansioso':
        return '$baseSummary\n\nEsta conversa abordou sentimentos de ansiedade e preocupação com situações futuras. Foram discutidas estratégias para gerenciar o estresse e técnicas de mindfulness para trazer a atenção ao momento presente, reduzindo a sobrecarga mental.';
      case 'irritado':
        return '$baseSummary\n\nDurante esta interação, foram expressos sentimentos de frustração e irritação. A conversa permitiu identificar gatilhos emocionais e explorar formas mais construtivas de lidar com situações desafiadoras, promovendo uma comunicação mais assertiva.';
      case 'neutro':
      default:
        return '$baseSummary\n\nEsta conversa proporcionou um momento de equilíbrio e reflexão sobre diversos aspectos da vida cotidiana. Foram abordados temas relacionados ao autoconhecimento e bem-estar geral, contribuindo para uma visão mais integrada das experiências pessoais.';
    }
  }
}
