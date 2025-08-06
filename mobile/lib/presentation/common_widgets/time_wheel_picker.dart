import 'package:flutter/material.dart';

/// TimeWheelPicker - Um seletor de horário estilo rolagem (wheel picker)
///
/// Permite ao usuário selecionar horas e minutos usando um controle de rolagem
/// similar ao seletor de data/hora do iOS.
class TimeWheelPicker extends StatefulWidget {
  /// Horário inicial selecionado
  final TimeOfDay initialTime;
  
  /// Callback chamado quando o horário é alterado
  final Function(TimeOfDay) onTimeChanged;
  
  /// Altura do seletor
  final double height;
  
  /// Cor do item selecionado
  final Color? selectedItemColor;
  
  /// Cor do texto do item selecionado
  final Color? selectedTextColor;
  
  /// Cor do texto dos itens não selecionados
  final Color? unselectedTextColor;
  
  /// Cor de fundo do seletor
  final Color? backgroundColor;
  
  /// Construtor do TimeWheelPicker
  const TimeWheelPicker({
    super.key,
    required this.initialTime,
    required this.onTimeChanged,
    this.height = 200,
    this.selectedItemColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.backgroundColor,
  });

  @override
  State<TimeWheelPicker> createState() => _TimeWheelPickerState();
}

class _TimeWheelPickerState extends State<TimeWheelPicker> {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  
  late int _selectedHour;
  late int _selectedMinute;
  
  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialTime.hour;
    _selectedMinute = widget.initialTime.minute;
    
    // Inicializar os controladores com as posições corretas
    _hourController = FixedExtentScrollController(initialItem: _selectedHour);
    _minuteController = FixedExtentScrollController(initialItem: _selectedMinute);
  }
  
  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Cores padrão se não forem especificadas
    final selectedItemColor = widget.selectedItemColor ?? const Color(0xFF9C89B8);
    final selectedTextColor = widget.selectedTextColor ?? Colors.white;
    final unselectedTextColor = widget.unselectedTextColor ?? Colors.black87;
    final backgroundColor = widget.backgroundColor ?? Colors.white;
    
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Seletor de horas
          Expanded(
            child: _buildWheelPicker(
              controller: _hourController,
              itemCount: 24,
              onSelectedItemChanged: (index) {
                setState(() {
                  _selectedHour = index;
                  _notifyTimeChanged();
                });
              },
              itemBuilder: (context, index) {
                return _buildPickerItem(
                  text: index.toString().padLeft(2, '0'),
                  isSelected: index == _selectedHour,
                  selectedItemColor: selectedItemColor,
                  selectedTextColor: selectedTextColor,
                  unselectedTextColor: unselectedTextColor,
                );
              },
            ),
          ),
          
          // Separador
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
              ":",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: unselectedTextColor,
              ),
            ),
          ),
          
          // Seletor de minutos
          Expanded(
            child: _buildWheelPicker(
              controller: _minuteController,
              itemCount: 60,
              onSelectedItemChanged: (index) {
                setState(() {
                  _selectedMinute = index;
                  _notifyTimeChanged();
                });
              },
              itemBuilder: (context, index) {
                return _buildPickerItem(
                  text: index.toString().padLeft(2, '0'),
                  isSelected: index == _selectedMinute,
                  selectedItemColor: selectedItemColor,
                  selectedTextColor: selectedTextColor,
                  unselectedTextColor: unselectedTextColor,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  /// Constrói um item do seletor
  Widget _buildPickerItem({
    required String text,
    required bool isSelected,
    required Color selectedItemColor,
    required Color selectedTextColor,
    required Color unselectedTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: isSelected ? selectedItemColor : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? selectedTextColor : unselectedTextColor,
        ),
      ),
    );
  }
  
  /// Constrói um seletor de rolagem
  Widget _buildWheelPicker({
    required FixedExtentScrollController controller,
    required int itemCount,
    required Function(int) onSelectedItemChanged,
    required Widget Function(BuildContext, int) itemBuilder,
  }) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 40,
      perspective: 0.005,
      diameterRatio: 1.5,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onSelectedItemChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: itemCount,
        builder: itemBuilder,
      ),
    );
  }
  
  /// Notifica a mudança de horário
  void _notifyTimeChanged() {
    final newTime = TimeOfDay(hour: _selectedHour, minute: _selectedMinute);
    widget.onTimeChanged(newTime);
  }
}

/// TimeWheelPickerDialog - Um diálogo que contém o seletor de rolagem de horário
///
/// Exibe um diálogo com o TimeWheelPicker e botões de confirmar/cancelar
class TimeWheelPickerDialog extends StatefulWidget {
  /// Horário inicial selecionado
  final TimeOfDay initialTime;
  
  /// Título do diálogo
  final String title;
  
  /// Construtor do TimeWheelPickerDialog
  const TimeWheelPickerDialog({
    super.key,
    required this.initialTime,
    this.title = 'Selecionar Horário',
  });
  
  /// Método estático para exibir o diálogo
  static Future<TimeOfDay?> show({
    required BuildContext context,
    required TimeOfDay initialTime,
    String title = 'Selecionar Horário',
  }) async {
    return showDialog<TimeOfDay>(
      context: context,
      builder: (context) => TimeWheelPickerDialog(
        initialTime: initialTime,
        title: title,
      ),
    );
  }

  @override
  State<TimeWheelPickerDialog> createState() => _TimeWheelPickerDialogState();
}

class _TimeWheelPickerDialogState extends State<TimeWheelPickerDialog> {
  late TimeOfDay _selectedTime;
  
  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Seletor de horário
            TimeWheelPicker(
              initialTime: widget.initialTime,
              onTimeChanged: (time) {
                _selectedTime = time;
              },
              height: 200,
              selectedItemColor: const Color(0xFF9C89B8),
              backgroundColor: Colors.white,
            ),
            
            const SizedBox(height: 24),
            
            // Botões
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(_selectedTime),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C89B8),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Confirmar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
