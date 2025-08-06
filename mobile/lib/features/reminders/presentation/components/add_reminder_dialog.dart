import 'package:flutter/material.dart';
import 'package:calma_flutter/presentation/common_widgets/time_wheel_picker.dart';

/// AddReminderDialog - Dialog para adicionar ou editar um lembrete
///
/// Permite ao usuário selecionar um horário usando TimePicker.
class AddReminderDialog extends StatefulWidget {
  final TimeOfDay? initialTime;
  final String title;
  final Function(TimeOfDay) onTimeSelected;

  const AddReminderDialog({
    super.key,
    this.initialTime,
    this.title = 'Adicionar Lembrete',
    required this.onTimeSelected,
  });

  @override
  State<AddReminderDialog> createState() => _AddReminderDialogState();
}

class _AddReminderDialogState extends State<AddReminderDialog> {
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF9C89B8).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.access_time,
              color: Color(0xFF9C89B8),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Selecione o horário para receber o lembrete:',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 24),
          
          // Botão para selecionar horário
          InkWell(
            onTap: _selectTime,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF9C89B8).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF9C89B8).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 48,
                    color: _selectedTime != null 
                        ? const Color(0xFF9C89B8)
                        : Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _selectedTime != null 
                        ? _formatTime(_selectedTime!)
                        : 'Toque para selecionar',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: _selectedTime != null 
                          ? const Color(0xFF333333)
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedTime != null 
                        ? _getTimeDescription(_selectedTime!)
                        : 'Escolha um horário',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (_selectedTime != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.blue[700],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'O lembrete será enviado diariamente neste horário.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancelar',
            style: TextStyle(
              color: Color(0xFF666666),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _selectedTime != null ? _saveReminder : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9C89B8),
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            widget.initialTime != null ? 'Atualizar' : 'Adicionar',
          ),
        ),
      ],
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await TimeWheelPickerDialog.show(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      title: 'Selecionar Horário',
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveReminder() {
    if (_selectedTime != null) {
      widget.onTimeSelected(_selectedTime!);
      Navigator.of(context).pop();
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _getTimeDescription(TimeOfDay time) {
    final now = DateTime.now();
    final selectedDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (selectedDateTime.isAfter(now)) {
      final difference = selectedDateTime.difference(now);
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;

      if (hours > 0) {
        return 'Em ${hours}h ${minutes}min';
      } else {
        return 'Em ${minutes}min';
      }
    } else {
      // Será amanhã
      final tomorrow = selectedDateTime.add(const Duration(days: 1));
      final difference = tomorrow.difference(now);
      final hours = difference.inHours;

      return 'Amanhã (em ${hours}h)';
    }
  }
}
