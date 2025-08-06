import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injection.dart';
import '../../../../presentation/common_widgets/primary_button.dart';
import '../viewmodels/reminder_viewmodel.dart';
import '../components/reminder_card.dart';
import '../components/add_reminder_dialog.dart';

/// ReminderScreen - Tela principal para gerenciar lembretes
///
/// Permite visualizar, adicionar, editar e excluir lembretes.
/// Mostra indicadores visuais para lembretes ativos e inativos.
class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  late final ReminderViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ReminderViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text(
            'Meus Lembretes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black54,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            Consumer<ReminderViewModel>(
              builder: (context, viewModel, _) {
                if (viewModel.reminders.isNotEmpty) {
                  return PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      color: Colors.black54,
                    ),
                    onSelected: (value) {
                      if (value == 'delete_all') {
                        _showDeleteAllDialog();
                      } else if (value == 'exact_alarms') {
                        _openExactAlarmSettings();
                      }
                    },
                    itemBuilder: (context) => [
                      if (Platform.isAndroid)
                        const PopupMenuItem(
                          value: 'exact_alarms',
                          child: Row(
                            children: [
                              Icon(Icons.alarm, color: Color(0xFF9C89B8)),
                              SizedBox(width: 8),
                              Text('Configurar Alarmes Exatos'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'delete_all',
                        child: Row(
                          children: [
                            Icon(Icons.delete_sweep, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Excluir todos'),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: Consumer<ReminderViewModel>(
          builder: (context, viewModel, _) {
            // Estado de loading
            if (viewModel.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF9C89B8),
                ),
              );
            }
            
            // Estado vazio - sem scroll
            if (viewModel.reminders.isEmpty) {
              return _buildEmptyState();
            }
            
            // Estado com lembretes - com scroll e RefreshIndicator
            return RefreshIndicator(
              onRefresh: viewModel.refreshReminders,
              color: const Color(0xFF9C89B8),
              child: CustomScrollView(
                slivers: [
                  // Header com informações (só quando há lembretes)
                  SliverToBoxAdapter(
                    child: _buildHeader(viewModel),
                  ),

                  // Lista de lembretes
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final reminder = viewModel.reminders[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ReminderCard(
                              reminder: reminder,
                              onEdit: () => _showEditReminderDialog(reminder),
                              onDelete: () => _showDeleteDialog(reminder.id!),
                              onToggle: () => _toggleReminder(reminder.id!),
                            ),
                          );
                        },
                        childCount: viewModel.reminders.length,
                      ),
                    ),
                  ),

                  // Espaçamento inferior (só quando há lembretes)
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
            );
          },
        ),
        floatingActionButton: Consumer<ReminderViewModel>(
          builder: (context, viewModel, _) {
            // Só mostrar o FAB quando há pelo menos 1 lembrete
            if (viewModel.reminders.isEmpty) {
              return const SizedBox.shrink();
            }
            
            return FloatingActionButton.extended(
              onPressed: viewModel.canAddMoreReminders
                  ? _showAddReminderDialog
                  : null,
              backgroundColor: viewModel.canAddMoreReminders
                  ? const Color(0xFF9C89B8)
                  : Colors.grey,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: Text(
                viewModel.canAddMoreReminders
                    ? 'Adicionar Lembrete'
                    : 'Limite Atingido',
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(ReminderViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF9C89B8).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C89B8).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications_active,
                  color: Color(0xFF9C89B8),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lembretes Configurados',
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${viewModel.reminders.length} de ${ReminderViewModel.maxReminders} lembretes',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatusIndicator(
                'Ativos',
                viewModel.activeReminders.length,
                Colors.green,
              ),
              const SizedBox(width: 16),
              _buildStatusIndicator(
                'Inativos',
                viewModel.reminders.length - viewModel.activeReminders.length,
                Colors.orange,
              ),
              const SizedBox(width: 16),
              _buildStatusIndicator(
                'Disponíveis',
                viewModel.remainingSlots,
                Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5), // Cinza claro padronizado
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFE0E0E0), // Cinza para borda
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF9C89B8).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.alarm_add,
                size: 60,
                color: Color(0xFF9C89B8),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nenhum lembrete configurado',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Adicione lembretes para receber notificações nos horários que você escolher. Você pode configurar até 3 lembretes.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Adicionar Primeiro Lembrete',
              onPressed: _showAddReminderDialog,
              icon: Icons.add,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddReminderDialog() {
    showDialog(
      context: context,
      builder: (context) => AddReminderDialog(
        onTimeSelected: (time) async {
          final success = await _viewModel.addReminder(time);
          if (success && mounted) {
            _showSuccessSnackBar(_viewModel.successMessage!);
          } else if (mounted) {
            _showErrorSnackBar(_viewModel.errorMessage!);
          }
        },
      ),
    );
  }

  void _showEditReminderDialog(reminder) {
    showDialog(
      context: context,
      builder: (context) => AddReminderDialog(
        initialTime: reminder.toTimeOfDay(),
        title: 'Editar Lembrete',
        onTimeSelected: (time) async {
          final success = await _viewModel.updateReminder(reminder.id!, time);
          if (success && mounted) {
            _showSuccessSnackBar(_viewModel.successMessage!);
          } else if (mounted) {
            _showErrorSnackBar(_viewModel.errorMessage!);
          }
        },
      ),
    );
  }

  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Lembrete'),
        content: const Text(
          'Tem certeza que deseja excluir este lembrete? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await _viewModel.removeReminder(id);
              if (success && mounted) {
                _showSuccessSnackBar(_viewModel.successMessage!);
              } else if (mounted) {
                _showErrorSnackBar(_viewModel.errorMessage!);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Todos os Lembretes'),
        content: const Text(
          'Tem certeza que deseja excluir TODOS os lembretes? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await _viewModel.deleteAllReminders();
              if (success && mounted) {
                _showSuccessSnackBar(_viewModel.successMessage!);
              } else if (mounted) {
                _showErrorSnackBar(_viewModel.errorMessage!);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir Todos'),
          ),
        ],
      ),
    );
  }

  void _toggleReminder(String id) async {
    final success = await _viewModel.toggleReminderStatus(id);
    if (success && mounted) {
      _showSuccessSnackBar(_viewModel.successMessage!);
    } else if (mounted) {
      _showErrorSnackBar(_viewModel.errorMessage!);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  
  // Método para abrir configurações de alarmes exatos
  Future<void> _openExactAlarmSettings() async {
    try {
      // Mostrar diálogo de carregamento
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF9C89B8),
          ),
        ),
      );
      
      // Abrir configurações
      final success = await _viewModel.openExactAlarmSettings();
      
      // Fechar diálogo de carregamento
      if (mounted) Navigator.of(context).pop();
      
      // Mostrar resultado
      if (_viewModel.errorMessage != null) {
        _showErrorSnackBar(_viewModel.errorMessage!);
      } else if (_viewModel.successMessage != null) {
        _showSuccessSnackBar(_viewModel.successMessage!);
      } else if (success) {
        _showSuccessSnackBar('Por favor, ative a permissão "Alarmes e lembretes" nas configurações');
      } else {
        _showErrorSnackBar('Não foi possível abrir as configurações. Por favor, verifique manualmente em Configurações > Apps > C\'Alma');
      }
    } catch (e) {
      // Fechar diálogo de carregamento em caso de erro
      if (mounted) Navigator.of(context).pop();
      _showErrorSnackBar('Erro ao abrir configurações: $e');
    }
  }
}
