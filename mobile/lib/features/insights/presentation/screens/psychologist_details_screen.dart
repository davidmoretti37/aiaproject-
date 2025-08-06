import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:calma_flutter/presentation/common_widgets/primary_button.dart';
import 'package:calma_flutter/core/di/injection.dart';
import 'package:calma_flutter/features/insights/domain/models/psychologist_model.dart';
import 'package:calma_flutter/features/insights/services/psychologist_invitation_service.dart';

class PsychologistDetailsScreen extends StatefulWidget {
  final PsychologistModel psychologist;
  
  const PsychologistDetailsScreen({
    super.key,
    required this.psychologist,
  });

  @override
  State<PsychologistDetailsScreen> createState() => _PsychologistDetailsScreenState();
}

class _PsychologistDetailsScreenState extends State<PsychologistDetailsScreen> {
  bool _isLoading = false;
  
  late final PsychologistInvitationService _invitationService;
  
  @override
  void initState() {
    super.initState();
    _invitationService = getIt<PsychologistInvitationService>();
  }
  
  Future<void> _sendInvitation() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final success = await _invitationService.sendInvitation(widget.psychologist.id);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        if (success) {
          // Mostrar mensagem de sucesso
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Convite enviado com sucesso!'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
          
          // Voltar para a tela anterior
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Mostrar erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar convite: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // Header com botão de voltar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black54),
                    onPressed: () => context.pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Detalhes do Psicólogo',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Para balancear o layout
                ],
              ),
            ),
            
            // Conteúdo principal
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // Avatar
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF9D82FF).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          widget.psychologist.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF9D82FF),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Nome
                    Text(
                      widget.psychologist.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF22223B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Especialização
                    Text(
                      widget.psychologist.specialization,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Container com dados do psicólogo
                    Container(
                      width: double.infinity, // Ocupa 100% da largura disponível
                      padding: const EdgeInsets.all(24),
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
                          const Text(
                            'Informações de Contato',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF22223B),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // CRP
                          _buildInfoRow(
                            icon: Icons.badge_outlined,
                            label: 'CRP',
                            value: widget.psychologist.crp,
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Email
                          _buildInfoRow(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value: widget.psychologist.email,
                          ),
                          
                          if (widget.psychologist.phone != null) ...[
                            const SizedBox(height: 12),
                            
                            // Telefone
                            _buildInfoRow(
                              icon: Icons.phone_outlined,
                              label: 'Telefone',
                              value: widget.psychologist.phone!,
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    if (widget.psychologist.bio != null) ...[
                      const SizedBox(height: 24),
                      
                      // Container com biografia
                      Container(
                        width: double.infinity, // Ocupa 100% da largura disponível
                        padding: const EdgeInsets.all(24),
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
                            const Text(
                              'Sobre',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF22223B),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.psychologist.bio!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 32),
                    
                    // Botão de enviar convite
                    PrimaryButton(
                      text: _isLoading ? 'Enviando...' : 'Enviar Convite',
                      onPressed: _isLoading ? null : _sendInvitation,
                      backgroundColor: const Color(0xFF9D82FF),
                      isLoading: _isLoading,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Informação adicional
                    Container(
                      width: double.infinity, // Ocupa 100% da largura disponível
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5EFFD),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF9D82FF).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: const Color(0xFF9D82FF),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'O psicólogo receberá um convite para acessar seus insights de forma segura.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF9D82FF),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF22223B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
