import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:calma_flutter/core/di/injection.dart';
import 'package:calma_flutter/core/constants/app_colors.dart';
import 'package:calma_flutter/core/constants/app_text_styles.dart';
import 'package:calma_flutter/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:calma_flutter/features/insights/services/psychologist_invitation_checker_service.dart';

class PendingInvitationsScreen extends StatefulWidget {
  const PendingInvitationsScreen({Key? key}) : super(key: key);

  @override
  State<PendingInvitationsScreen> createState() => _PendingInvitationsScreenState();
}

class _PendingInvitationsScreenState extends State<PendingInvitationsScreen> {
  final _invitationService = getIt<PsychologistInvitationCheckerService>();
  final _authViewModel = getIt<AuthViewModel>();
  List<Map<String, dynamic>> _pendingInvites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    debugPrint('🔔 PENDING_INVITATIONS: Tela inicializada - INÍCIO');
    try {
      debugPrint('🔔 PENDING_INVITATIONS: Verificando serviços inicializados');
      debugPrint('🔔 PENDING_INVITATIONS: _invitationService: ${_invitationService.hashCode}');
      debugPrint('🔔 PENDING_INVITATIONS: _authViewModel: ${_authViewModel.hashCode}');
      
      _loadPendingInvitations();
    } catch (e, stackTrace) {
      debugPrint('❌ PENDING_INVITATIONS: Erro na inicialização: $e');
      debugPrint('❌ PENDING_INVITATIONS: Stack trace: $stackTrace');
    }
    debugPrint('🔔 PENDING_INVITATIONS: Tela inicializada - FIM');
  }
  
  @override
  void dispose() {
    debugPrint('🔔 PENDING_INVITATIONS: Tela descartada');
    super.dispose();
  }

  Future<void> _loadPendingInvitations() async {
    debugPrint('🔄 PENDING_INVITATIONS: Carregando convites pendentes - INÍCIO');
    try {
      final currentUser = _authViewModel.currentUser;
      debugPrint('🔄 PENDING_INVITATIONS: Usuário atual: ${currentUser?.email ?? "null"}');
      
      if (currentUser == null || currentUser.email == null) {
        debugPrint('⚠️ PENDING_INVITATIONS: Usuário não autenticado ou sem email');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _isLoading = true;
      });

      debugPrint('🔄 PENDING_INVITATIONS: Verificando convites para: ${currentUser.email}');
      final invites = await _invitationService.checkPendingInvitations(currentUser.email!);
      debugPrint('✅ PENDING_INVITATIONS: ${invites.length} convites encontrados');
      
      if (mounted) {
        setState(() {
          _pendingInvites = invites;
          _isLoading = false;
        });
        debugPrint('✅ PENDING_INVITATIONS: Estado atualizado com ${_pendingInvites.length} convites');
      } else {
        debugPrint('⚠️ PENDING_INVITATIONS: Widget não está mais montado, ignorando setState');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ PENDING_INVITATIONS: Erro ao carregar convites: $e');
      debugPrint('❌ PENDING_INVITATIONS: Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
    debugPrint('🔄 PENDING_INVITATIONS: Carregando convites pendentes - FIM');
  }

  Future<void> _acceptInvitation(String invitationId) async {
    final currentUser = _authViewModel.currentUser;
    if (currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    final success = await _invitationService.acceptInvitation(invitationId, currentUser.id);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Convite aceito com sucesso!')),
      );
      
      // Se não houver mais convites pendentes, voltar para a tela inicial
      await _loadPendingInvitations();
      
      if (_pendingInvites.isEmpty) {
        debugPrint('🔔 PENDING_INVITATIONS: Não há mais convites pendentes, voltando para a tela inicial');
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao aceitar convite')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _rejectInvitation(String invitationId) async {
    setState(() {
      _isLoading = true;
    });

    final success = await _invitationService.rejectInvitation(invitationId);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Convite rejeitado')),
      );
      
      // Se não houver mais convites pendentes, voltar para a tela inicial
      await _loadPendingInvitations();
      
      if (_pendingInvites.isEmpty) {
        debugPrint('🔔 PENDING_INVITATIONS: Não há mais convites pendentes, voltando para a tela inicial');
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao rejeitar convite')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Convites Pendentes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            debugPrint('🔔 PENDING_INVITATIONS: Botão voltar pressionado');
            Navigator.of(context).pop();
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingInvites.isEmpty
              ? const Center(child: Text('Nenhum convite pendente'))
              : ListView.builder(
                  itemCount: _pendingInvites.length,
                  itemBuilder: (context, index) {
                    final invite = _pendingInvites[index];
                    final psychologist = invite['psychologists'];
                    
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gray400.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Cabeçalho com avatar e nome
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Avatar ou ícone do psicólogo
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: AppColors.calmaBlueLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    size: 30,
                                    color: AppColors.calmaBlue,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Informações do psicólogo
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        psychologist['name'] ?? 'Psicólogo',
                                        style: AppTextStyles.heading4,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'CRP: ${psychologist['crp'] ?? 'N/A'}',
                                        style: AppTextStyles.bodySmall,
                                      ),
                                      Text(
                                        'Email: ${psychologist['email'] ?? 'N/A'}',
                                        style: AppTextStyles.caption.copyWith(color: AppColors.gray500),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Divisor
                          Divider(
                            color: AppColors.gray100,
                            thickness: 1,
                            indent: 16,
                            endIndent: 16,
                          ),
                          // Botões de ação
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Botão Rejeitar
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _rejectInvitation(invite['id']),
                                    icon: const Icon(Icons.close, size: 18),
                                    label: const Text('Rejeitar'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.error.withOpacity(0.1),
                                      foregroundColor: AppColors.error,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Botão Aceitar
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _acceptInvitation(invite['id']),
                                    icon: const Icon(Icons.check, size: 18),
                                    label: const Text('Aceitar'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.calmaBlue,
                                      foregroundColor: AppColors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
