import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/call_session_model.dart';
import '../viewmodels/insights_viewmodel.dart';

/// Widget para exibir um card com informações de mood e summary de uma sessão
class MoodCard extends StatelessWidget {
  final CallSessionModel session;
  final InsightsViewModel viewModel;

  const MoodCard({
    super.key,
    required this.session,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navegar para a tela de detalhes do insight
        context.pushNamed(
          'insight-detail',
          extra: session,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quadrado colorido com ícone do mood
            _buildMoodIcon(),
            const SizedBox(width: 12),
            // Conteúdo do card
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói o quadrado colorido com o ícone do mood
  Widget _buildMoodIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: session.getMoodBackgroundColor(),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          session.getMoodIcon(),
          size: 20,
          color: session.getMoodIconColor(),
        ),
      ),
    );
  }

  /// Constrói o conteúdo principal do card
  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary da conversa
        _buildSummary(),
        const SizedBox(height: 8),
        // Data da sessão
        _buildDate(),
      ],
    );
  }

  /// Constrói o texto do summary
  Widget _buildSummary() {
    return Text(
      session.truncatedSummary,
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF22223B),
        height: 1.4,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Constrói a data formatada
  Widget _buildDate() {
    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 14,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          viewModel.formatSessionDate(session.createdAt),
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Widget para exibir uma lista de cards de mood
class MoodCardList extends StatelessWidget {
  final List<CallSessionModel> sessions;
  final InsightsViewModel viewModel;

  const MoodCardList({
    super.key,
    required this.sessions,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return MoodCard(
          session: session,
          viewModel: viewModel,
        );
      },
    );
  }
}

/// Widget para exibir cards agrupados por data
class GroupedMoodCards extends StatelessWidget {
  final Map<String, List<CallSessionModel>> sessionsByDate;
  final InsightsViewModel viewModel;

  const GroupedMoodCards({
    super.key,
    required this.sessionsByDate,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    if (sessionsByDate.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sessionsByDate.entries.map((entry) {
        final dateLabel = entry.key;
        final sessions = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho da data
            _buildDateHeader(dateLabel),
            const SizedBox(height: 12),
            // Cards da data
            MoodCardList(
              sessions: sessions,
              viewModel: viewModel,
            ),
            const SizedBox(height: 24),
          ],
        );
      }).toList(),
    );
  }

  /// Constrói o cabeçalho da data
  Widget _buildDateHeader(String dateLabel) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        dateLabel,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF22223B),
        ),
      ),
    );
  }
}

/// Widget para exibir estatísticas rápidas dos moods
class MoodStatsWidget extends StatelessWidget {
  final Map<String, int> moodDistribution;

  const MoodStatsWidget({
    super.key,
    required this.moodDistribution,
  });

  @override
  Widget build(BuildContext context) {
    if (moodDistribution.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalSessions = moodDistribution.values.fold(0, (sum, count) => sum + count);
    
    if (totalSessions == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE9ECEF),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumo dos seus humores',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF22223B),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: moodDistribution.entries
                .where((entry) => entry.value > 0)
                .map((entry) => _buildMoodChip(entry.key, entry.value, totalSessions))
                .toList(),
          ),
        ],
      ),
    );
  }

  /// Constrói um chip de mood com estatística
  Widget _buildMoodChip(String mood, int count, int total) {
    final percentage = ((count / total) * 100).round();
    final session = CallSessionModel(
      id: '',
      userId: '',
      startedAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      mood: mood,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: session.getMoodBackgroundColor(),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: session.getMoodIconColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            session.getMoodIcon(),
            size: 16,
            color: session.getMoodIconColor(),
          ),
          const SizedBox(width: 6),
          Text(
            '${session.getMoodDescription()} $percentage%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: session.getMoodIconColor(),
            ),
          ),
        ],
      ),
    );
  }
}
