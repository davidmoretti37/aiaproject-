import 'package:flutter/material.dart';

import '../../domain/models/reminder_model.dart';

/// ReminderCard - Widget para exibir um lembrete individual
///
/// Mostra o horário, status (ativo/inativo) e ações disponíveis.
class ReminderCard extends StatelessWidget {
  final ReminderModel reminder;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const ReminderCard({
    super.key,
    required this.reminder,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        border: Border.all(
          color: reminder.isActive 
              ? const Color(0xFF9C89B8).withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Ícone de status
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: reminder.isActive 
                    ? const Color(0xFF9C89B8).withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                reminder.isActive ? Icons.notifications_active : Icons.notifications_off,
                color: reminder.isActive 
                    ? const Color(0xFF9C89B8)
                    : Colors.grey,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Informações do lembrete
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        reminder.toTimeString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: reminder.isActive 
                              ? const Color(0xFF333333)
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: reminder.isActive 
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          reminder.isActive ? 'Ativo' : 'Inativo',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: reminder.isActive 
                                ? Colors.green[700]
                                : Colors.orange[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getTimeDescription(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (reminder.lastTriggered != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Último disparo: ${_formatLastTriggered()}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Ações
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Botão de toggle (ativar/desativar)
                IconButton(
                  onPressed: onToggle,
                  icon: Icon(
                    reminder.isActive ? Icons.pause_circle : Icons.play_circle,
                    color: reminder.isActive 
                        ? const Color.fromARGB(255, 255, 210, 156)
                        : const Color.fromARGB(255, 111, 173, 113),
                  ),
                  tooltip: reminder.isActive ? 'Desativar' : 'Ativar',
                ),
                
                // Botão de editar
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(
                    Icons.edit,
                    color: const Color.fromARGB(255, 147, 204, 255),
                  ),
                  tooltip: 'Editar',
                ),
                
                // Botão de excluir
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete,
                    color: const Color.fromARGB(255, 255, 146, 144),
                  ),
                  tooltip: 'Excluir',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeDescription() {
    final now = DateTime.now();
    final reminderTime = DateTime(now.year, now.month, now.day, reminder.hour, reminder.minute);
    
    if (reminderTime.isAfter(now)) {
      final difference = reminderTime.difference(now);
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      
      if (hours > 0) {
        return 'Em ${hours}h ${minutes}min';
      } else {
        return 'Em ${minutes}min';
      }
    } else {
      // Próximo disparo será amanhã
      final tomorrow = reminderTime.add(const Duration(days: 1));
      final difference = tomorrow.difference(now);
      final hours = difference.inHours;
      
      return 'Amanhã (em ${hours}h)';
    }
  }

  String _formatLastTriggered() {
    if (reminder.lastTriggered == null) return 'Nunca';
    
    final now = DateTime.now();
    final triggered = reminder.lastTriggered!;
    final difference = now.difference(triggered);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} dia${difference.inDays > 1 ? 's' : ''} atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora${difference.inHours > 1 ? 's' : ''} atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''} atrás';
    } else {
      return 'Agora mesmo';
    }
  }
}
