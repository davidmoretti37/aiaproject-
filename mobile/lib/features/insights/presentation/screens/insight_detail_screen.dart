import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/string_extensions.dart';
import '../../data/repositories/session_insight_repository.dart';
import '../../domain/models/call_session_model.dart';
import '../viewmodels/session_insight_viewmodel.dart';

/// InsightDetailScreen - Tela de detalhes de um insight específico
///
/// Exibe informações detalhadas sobre uma sessão de conversa com a AIA,
/// incluindo emoji, emoção predominante, tópicos, resumo e reflexão.
class InsightDetailScreen extends StatefulWidget {
  final CallSessionModel session;

  const InsightDetailScreen({
    super.key,
    required this.session,
  });

  @override
  State<InsightDetailScreen> createState() => _InsightDetailScreenState();
}

class _InsightDetailScreenState extends State<InsightDetailScreen> {
  bool isLocaleInitialized = false;
  late SessionInsightViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _initializeLocale();
    _initializeViewModel();
  }

  void _initializeViewModel() {
    final repository = SessionInsightRepository();
    _viewModel = SessionInsightViewModel(repository, widget.session);
  }

  Future<void> _initializeLocale() async {
    await initializeDateFormatting('pt_BR', null);
    setState(() {
      isLocaleInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        appBar: AppBar(
          title: const Text(
            'Detalhes do Insight',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        body: Consumer<SessionInsightViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return _buildLoadingState();
            }
            
            if (viewModel.error != null) {
              return _buildErrorState(viewModel.error!);
            }
            
            return _buildContent(viewModel);
          },
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
            'Carregando detalhes do insight...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói o estado de erro
  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            error,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9D82FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Voltar'),
          ),
        ],
      ),
    );
  }

  /// Constrói o conteúdo principal da tela
  Widget _buildContent(SessionInsightViewModel viewModel) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card principal expressivo com emoji à esquerda e informações integradas
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: _buildEmotionalCard(viewModel),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // Card com tópicos da conversa
                _buildTopicsCard(viewModel),
                
                const SizedBox(height: 20),
                
                // Card com reflexão detalhada
                _buildReflectionCard(viewModel),
                
                const SizedBox(height: 20),
                
                // Card com resumo
                _buildSummaryCard(viewModel),
                
                const SizedBox(height: 24),
                
                // Botão para excluir insight
                _buildDeleteButton(viewModel),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói um item de informação para a barra integrada
  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color(0xFF9D82FF),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói o card principal expressivo com informações integradas
  Widget _buildEmotionalCard(SessionInsightViewModel viewModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Parte superior: Emoji e título
          Row(
            crossAxisAlignment: CrossAxisAlignment.center, // Alinhamento vertical centralizado
            children: [
              // Emoji menor (lado esquerdo) com cor dinâmica
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: widget.session.getMoodBackgroundColor(), // Cor dinâmica baseada no mood
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    widget.session.getMoodIcon(),
                    size: 30,
                    color: widget.session.getMoodIconColor(),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Título expressivo com cor preta padrão
              Expanded(
                child: Text(
                  viewModel.getEmotionalTitle(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87, // Cor preta padrão
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Frase introdutória (ocupa toda a largura)
          Text(
            viewModel.getEmotionalIntro(),
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF444444),
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 20),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),
          
          // Informações de data/duração/início
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Data da conversa
              _buildInfoItem(
                Icons.calendar_today,
                'Data',
                _formatDate(),
              ),
              
              // Divisor vertical
              Container(
                height: 24,
                width: 1,
                color: Colors.grey.withOpacity(0.3),
              ),
              
              // Duração da conversa
              _buildInfoItem(
                Icons.access_time,
                'Duração',
                _formatDuration(),
              ),
              
              // Divisor vertical
              Container(
                height: 24,
                width: 1,
                color: Colors.grey.withOpacity(0.3),
              ),
              
              // Horário de início
              _buildInfoItem(
                Icons.schedule,
                'Início',
                _formatStartTime(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Constrói o card com tópicos da conversa
  Widget _buildTopicsCard(SessionInsightViewModel viewModel) {
    final topics = viewModel.insight?.topics ?? [];
    
    return Card(
      elevation: 0,
      color: Color(0xFF1E1E1E),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.topic,
                  color: Color(0xFF9D82FF),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Temas da Conversa',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: topics.map((topic) => _buildTopicChip(topic, viewModel)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói um chip para um tópico
  Widget _buildTopicChip(String topic, SessionInsightViewModel viewModel) {
    final formattedTopic = topic.formatTopicName;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: viewModel.getTopicChipColor(),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        formattedTopic,
        style: TextStyle(
          fontSize: 14,
          color: viewModel.getTopicTextColor(),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Constrói o card com reflexão detalhada
  Widget _buildReflectionCard(SessionInsightViewModel viewModel) {
    return Card(
      elevation: 0,
      color: Color(0xFF1E1E1E),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.psychology,
                  color: Color(0xFF9D82FF),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Reflexão Detalhada',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              // Usa o aiAdvice do banco se disponível, caso contrário usa o texto padrão
              viewModel.insight?.aiAdvice != null && viewModel.insight!.aiAdvice!.isNotEmpty
                  ? viewModel.insight!.aiAdvice!
                  : _getDetailedDescription(),
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white70,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Constrói o card com resumo da conversa
  Widget _buildSummaryCard(SessionInsightViewModel viewModel) {
    return Card(
      elevation: 0,
      color: Color(0xFF1E1E1E),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.summarize,
                  color: Color(0xFF9D82FF),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Resumo da Conversa',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              // Usa o longSummary do banco se disponível, caso contrário usa o texto padrão
              viewModel.insight?.longSummary != null && viewModel.insight!.longSummary!.isNotEmpty
                  ? viewModel.insight!.longSummary!
                  : viewModel.getGenericSummary(),
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white70,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói o botão para excluir insight
  Widget _buildDeleteButton(SessionInsightViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: viewModel.isDeleting
            ? null
            : () => _showDeleteConfirmationDialog(viewModel),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[50],
          foregroundColor: Colors.red[700],
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.red[200]!),
          ),
        ),
        icon: viewModel.isDeleting
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red[700]!),
                ),
              )
            : Icon(Icons.delete_outline, color: Colors.red[700]),
        label: Text(
          viewModel.isDeleting ? 'Excluindo...' : 'Excluir Insight',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.red[700],
          ),
        ),
      ),
    );
  }

  /// Mostra diálogo de confirmação para excluir insight
  void _showDeleteConfirmationDialog(SessionInsightViewModel viewModel) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir Insight'),
        content: const Text(
          'Tem certeza que deseja excluir este insight? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              // Fecha o diálogo de confirmação
              Navigator.of(dialogContext).pop();
              
              // Mostra um indicador de progresso enquanto exclui
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Excluindo insight...'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
              
              // Executa a exclusão
              final success = await viewModel.deleteInsightAndSession();
              
              if (success && mounted) {
                // Primeiro fecha a tela de detalhes e volta para a tela de insights
                context.pop(true);
                
                // Depois mostra a mensagem de sucesso (será exibida na tela de insights)
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Insight excluído com sucesso!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                });
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(viewModel.error ?? 'Erro ao excluir insight'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  /// Gera uma descrição detalhada criativa baseada no mood
  String _getDetailedDescription() {
    final mood = widget.session.mood?.toLowerCase() ?? 'neutro';
    
    switch (mood) {
      case 'feliz':
        return 'Que momento especial! Sua conversa com a AIA refletiu um estado de espírito positivo e radiante. '
               'Momentos como este são preciosos e merecem ser celebrados. A felicidade que você expressou '
               'mostra sua capacidade de encontrar alegria e gratidão, mesmo nas pequenas coisas da vida. '
               'Continue cultivando essa energia positiva - ela é contagiosa e transforma não apenas seu dia, '
               'mas também o ambiente ao seu redor.';
               
      case 'triste':
        return 'Reconhecer e expressar tristeza é um ato de coragem e autoconhecimento. Sua conversa com a AIA '
               'mostrou sua capacidade de se conectar com suas emoções mais profundas. Lembre-se de que a tristeza '
               'é uma emoção válida e necessária - ela nos ensina sobre o que realmente importa em nossas vidas. '
               'Permita-se sentir, mas também lembre-se de que este momento é temporário. Você tem a força '
               'interior para atravessar qualquer tempestade emocional.';
               
      case 'ansioso':
        return 'A ansiedade que você compartilhou com a AIA revela sua sensibilidade e consciência sobre os '
               'desafios da vida. É natural sentir-se ansioso diante do desconhecido ou de situações importantes. '
               'Sua capacidade de reconhecer e falar sobre esses sentimentos já é um grande passo. Lembre-se de '
               'respirar profundamente, focar no presente e confiar em sua capacidade de lidar com os desafios. '
               'Cada respiração consciente é um ato de autocuidado e fortalecimento interior.';
               
      case 'irritado':
        return 'A irritação que você expressou é um sinal de que algo importante para você foi afetado. '
               'Reconhecer esses sentimentos com a AIA mostra sua maturidade emocional. A raiva, quando bem '
               'direcionada, pode ser uma força transformadora que nos motiva a criar mudanças positivas. '
               'Use essa energia para identificar o que precisa ser ajustado em sua vida. Lembre-se de que '
               'você tem o poder de escolher como responder às situações que desafiam sua paciência.';
               
      case 'neutro':
      default:
        return 'Sua conversa com a AIA refletiu um momento de equilíbrio e serenidade interior. Estar em um '
               'estado neutro não significa ausência de emoções, mas sim uma harmonia entre diferentes sentimentos. '
               'Esses momentos de calma são oportunidades valiosas para reflexão e autoconhecimento. Aproveite '
               'essa estabilidade emocional para observar seus pensamentos e sentimentos com clareza, '
               'preparando-se para os próximos capítulos de sua jornada pessoal.';
    }
  }

  /// Formata a data da conversa
  String _formatDate() {
    if (!isLocaleInitialized) return 'Carregando...';
    
    final now = DateTime.now();
    final sessionDate = widget.session.createdAt;
    final difference = now.difference(sessionDate).inDays;
    
    if (difference == 0) {
      return 'Hoje';
    } else if (difference == 1) {
      return 'Ontem';
    } else {
      final dateFormat = DateFormat('d MMM', 'pt_BR');
      return dateFormat.format(sessionDate);
    }
  }

  /// Formata a duração da conversa
  String _formatDuration() {
    final durationSec = widget.session.durationSec ?? 0;
    
    if (durationSec < 60) {
      return '${durationSec}s';
    } else {
      final minutes = durationSec ~/ 60;
      final seconds = durationSec % 60;
      
      if (seconds == 0) {
        return '${minutes}min';
      } else {
        return '${minutes}min ${seconds}s';
      }
    }
  }

  /// Formata o horário de início da conversa
  String _formatStartTime() {
    final timeFormat = DateFormat('HH:mm', 'pt_BR');
    return timeFormat.format(widget.session.startedAt);
  }
}
