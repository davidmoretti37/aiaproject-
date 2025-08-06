import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:calma_flutter/features/reports/data/models/ai_content_report.dart';

class ReportCard extends StatelessWidget {
  final AiContentReport report;
  final VoidCallback onTap;

  const ReportCard({
    super.key,
    required this.report,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
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
              // Header com status e data
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusBadge(),
                  Text(
                    _formatDate(report.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Categoria
              Row(
                children: [
                  Icon(
                    _getCategoryIcon(),
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    report.categoryDisplayName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Descrição (preview)
              Text(
                report.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                  height: 1.4,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Footer com indicador de resposta
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Incidente: ${_formatDate(report.timestampOfIncident)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  if (report.hasAdminResponse)
                    Row(
                      children: [
                        Icon(
                          Icons.reply,
                          size: 14,
                          color: const Color(0xFF9C89B8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Respondido',
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF9C89B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: report.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: report.statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        report.statusDisplayName,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: report.statusColor,
        ),
      ),
    );
  }

  IconData _getCategoryIcon() {
    // Usar a categoria em português para mapeamento de ícones
    switch (report.category.toLowerCase()) {
      case 'conteúdo inadequado':
      case 'conteúdo ofensivo':
        return Icons.warning_outlined;
      case 'comportamento estranho':
        return Icons.person_off_outlined;
      case 'informações incorretas':
        return Icons.info_outline;
      case 'conteúdo perigoso':
        return Icons.security_outlined;
      case 'outros':
        return Icons.help_outline;
      // Manter compatibilidade com categorias antigas em inglês
      case 'inappropriate_content':
      case 'offensive_language':
      case 'content_quality':
        return Icons.warning_outlined;
      case 'inappropriate_behavior':
      case 'harassment':
        return Icons.person_off_outlined;
      case 'misinformation':
      case 'false_information':
        return Icons.info_outline;
      case 'technical_issue':
        return Icons.bug_report_outlined;
      case 'privacy_violation':
        return Icons.privacy_tip_outlined;
      case 'safety_concern':
        return Icons.security_outlined;
      case 'spam':
        return Icons.block_outlined;
      case 'other':
        return Icons.help_outline;
      default:
        return Icons.report_outlined;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Agora';
        }
        return '${difference.inMinutes}min atrás';
      }
      return '${difference.inHours}h atrás';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
}
