import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:calma_flutter/presentation/common_widgets/input_field.dart';
import 'package:calma_flutter/presentation/common_widgets/primary_button.dart';
import 'package:calma_flutter/features/insights/services/psychologist_invitation_service.dart';
import 'package:calma_flutter/core/di/injection.dart';
import 'package:calma_flutter/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:calma_flutter/features/profile/domain/repositories/user_profile_repository.dart';
import 'package:calma_flutter/features/profile/domain/models/user_profile_model.dart';
import 'package:calma_flutter/features/insights/domain/repositories/psychologist_repository.dart';
import 'package:calma_flutter/features/insights/domain/models/psychologist_model.dart';
import 'package:calma_flutter/core/services/supabase_service.dart';

class InvitePsychologistScreen extends StatefulWidget {
  const InvitePsychologistScreen({super.key});

  @override
  State<InvitePsychologistScreen> createState() => _InvitePsychologistScreenState();
}

class _InvitePsychologistScreenState extends State<InvitePsychologistScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isEmailValid = false;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Serviço de convite
  late final PsychologistInvitationService _invitationService;
  
  // Novos campos
  bool _isConnected = false;
  PsychologistModel? _psychologist;
  UserProfileModel? _userProfile;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    _invitationService = getIt<PsychologistInvitationService>();
    _checkPsychologistConnection();
  }
  
  /// Verifica se o usuário já está conectado a um psicólogo
  Future<void> _checkPsychologistConnection() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Obter perfil do usuário
      final authViewModel = getIt<AuthViewModel>();
      final currentUser = authViewModel.currentUser;
      
      if (currentUser == null) {
        debugPrint('❌ Usuário não autenticado');
        setState(() {
          _isLoading = false;
          _isConnected = false;
        });
        return;
      }
      
      final profileRepository = getIt<UserProfileRepository>();
      try {
        _userProfile = await profileRepository.getProfileByUserId(currentUser.id);
      } catch (e) {
        debugPrint('❌ Erro ao buscar perfil do usuário: $e');
        setState(() {
          _isLoading = false;
          _isConnected = false;
        });
        return;
      }
      
      if (_userProfile == null) {
        debugPrint('❌ Perfil do usuário não encontrado');
        setState(() {
          _isLoading = false;
          _isConnected = false;
        });
        return;
      }
      
      // Verificar se existe uma conexão ativa na tabela psychologists_patients
      final supabase = SupabaseService.client;
      try {
        final activeConnection = await supabase
            .from('psychologists_patients')
            .select('*, psychologists(*)')
            .eq('patient_id', currentUser.id)
            .eq('status', 'active')
            .maybeSingle();
        
        if (activeConnection != null) {
          // Existe uma conexão ativa na tabela de relacionamentos
          try {
            final psychologistData = activeConnection['psychologists'];
            _psychologist = PsychologistModel.fromJson(psychologistData);
            
            // Verificar se o perfil do usuário está sincronizado
            if (_userProfile!.psychologistId != _psychologist!.id) {
              // Atualizar o perfil do usuário para sincronizar
              final updatedProfile = _userProfile!.copyWith(
                psychologistId: _psychologist!.id,
                updatedAt: DateTime.now(),
              );
              
              try {
                final result = await profileRepository.updateProfile(updatedProfile);
                if (result != null) {
                  _userProfile = result;
                }
              } catch (e) {
                debugPrint('❌ Erro ao atualizar perfil do usuário: $e');
              }
            }
            
            setState(() {
              _isConnected = true;
              _isLoading = false;
            });
            return;
          } catch (e) {
            debugPrint('❌ Erro ao processar dados do psicólogo: $e');
          }
        }
      } catch (e) {
        debugPrint('❌ Erro ao verificar conexão ativa na tabela psychologists_patients: $e');
      }
      
      // Se não encontrou na tabela de relacionamentos, verificar no perfil do usuário
      if (_userProfile!.psychologistId != null) {
        // Buscar dados do psicólogo
        try {
          final psychologistRepository = getIt<PsychologistRepository>();
          _psychologist = await psychologistRepository.getPsychologistById(_userProfile!.psychologistId!);
          
          if (_psychologist != null) {
            // Verificar se existe uma entrada na tabela psychologists_patients
            try {
              final existingRelation = await supabase
                  .from('psychologists_patients')
                  .select()
                  .eq('patient_id', currentUser.id)
                  .eq('psychologist_id', _psychologist!.id)
                  .eq('status', 'active')
                  .maybeSingle();
              
              if (existingRelation == null) {
                // Não existe relação ativa, mas o perfil tem um psychologistId
                // Em vez de criar uma relação, vamos remover o psychologistId do perfil
                debugPrint('⚠️ Encontrado psychologistId no perfil, mas sem relação ativa na tabela');
                
                // Atualizar o perfil do usuário para remover o psychologistId
                final updatedProfile = _userProfile!.copyWith(
                  psychologistId: null,
                  updatedAt: DateTime.now(),
                );
                
                try {
                  final result = await profileRepository.updateProfile(updatedProfile);
                  if (result != null) {
                    _userProfile = result;
                    _psychologist = null;
                    
                    setState(() {
                      _isConnected = false;
                      _isLoading = false;
                    });
                    
                    debugPrint('✅ Removido psychologistId do perfil para manter consistência');
                    return;
                  }
                } catch (e) {
                  debugPrint('❌ Erro ao atualizar perfil do usuário: $e');
                }
              } else {
                // Existe uma relação ativa
                setState(() {
                  _isConnected = true;
                  _isLoading = false;
                });
                return;
              }
            } catch (e) {
              debugPrint('❌ Erro ao verificar relação na tabela psychologists_patients: $e');
            }
          } else {
            // Psicólogo não encontrado, remover o ID do perfil
            final updatedProfile = _userProfile!.copyWith(
              psychologistId: null,
              updatedAt: DateTime.now(),
            );
            
            try {
              final result = await profileRepository.updateProfile(updatedProfile);
              if (result != null) {
                _userProfile = result;
              }
            } catch (e) {
              debugPrint('❌ Erro ao atualizar perfil do usuário: $e');
            }
          }
        } catch (e) {
          debugPrint('❌ Erro ao buscar dados do psicólogo: $e');
        }
      }
      
      // Se chegou até aqui, não há conexão ativa
      setState(() {
        _isConnected = false;
        _psychologist = null;
        _isLoading = false;
      });
    } catch (e) {
      // Tratamento de erro global
      debugPrint('❌ Erro global no _checkPsychologistConnection: $e');
      setState(() {
        _isLoading = false;
        _isConnected = false;
      });
    }
  }
  
  /// Desconecta o usuário do psicólogo
  Future<void> _disconnectPsychologist() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Atualizar perfil do usuário para remover o psychologist_id
      if (_userProfile != null && _psychologist != null) {
        debugPrint('🔄 Tentando desconectar psicólogo. ID atual: ${_userProfile!.psychologistId}');
        
        // 1. Atualizar o status na tabela psychologists_patients
        final supabase = SupabaseService.client;
        try {
          await supabase
              .from('psychologists_patients')
              .update({
                'status': 'terminated',
                'ended_at': DateTime.now().toIso8601String(),
              })
              .eq('patient_id', _userProfile!.userId)
              .eq('psychologist_id', _psychologist!.id)
              .eq('status', 'active');
          
          debugPrint('✅ Status atualizado na tabela psychologists_patients');
        } catch (e) {
          debugPrint('❌ Erro ao atualizar status na tabela psychologists_patients: $e');
          // Continuar mesmo se houver erro, para garantir que o perfil seja atualizado
        }
        
        // 2. Atualizar o perfil do usuário
        final updatedProfile = _userProfile!.copyWith(
          psychologistId: null,
          updatedAt: DateTime.now(),
        );
        
        debugPrint('🔄 Perfil atualizado localmente: ${updatedProfile.toString()}');
        
        final profileRepository = getIt<UserProfileRepository>();
        final result = await profileRepository.updateProfile(updatedProfile);
        
        // Verificar se o perfil foi realmente atualizado
        if (result != null && result.psychologistId != null) {
          debugPrint('⚠️ Perfil não foi atualizado corretamente. Tentando novamente...');
          
          // Tentar novamente com uma atualização direta no Supabase
          final supabase = SupabaseService.client;
          try {
            await supabase
                .from('user_profiles')
                .update({
                  'psychologist_id': null,
                  'updated_at': DateTime.now().toIso8601String(),
                })
                .eq('user_id', _userProfile!.userId);
            
            debugPrint('✅ Perfil atualizado diretamente no Supabase');
            
            // Buscar o perfil atualizado
            final updatedProfileData = await supabase
                .from('user_profiles')
                .select()
                .eq('user_id', _userProfile!.userId)
                .single();
            
            _userProfile = UserProfileModel.fromJson(updatedProfileData);
            debugPrint('✅ Perfil atualizado: ${_userProfile.toString()}');
          } catch (e) {
            debugPrint('❌ Erro ao atualizar perfil diretamente: $e');
          }
        }
        
        if (result != null) {
          debugPrint('✅ Perfil atualizado com sucesso no banco. Novo psychologistId: ${result.psychologistId}');
          
          // Atualizar o perfil local com o resultado do banco de dados
          _userProfile = result;
          
          setState(() {
            _isConnected = false;
            _psychologist = null;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Desconectado do psicólogo com sucesso!'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        } else {
          debugPrint('❌ Falha ao atualizar perfil no banco de dados');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao desconectar: falha na atualização do perfil'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else if (_userProfile != null) {
        // Caso não tenhamos os dados do psicólogo, mas temos o ID no perfil
        debugPrint('🔄 Tentando desconectar psicólogo sem dados completos. ID: ${_userProfile!.psychologistId}');
        
        // Atualizar apenas o perfil do usuário
        final updatedProfile = _userProfile!.copyWith(
          psychologistId: null,
          updatedAt: DateTime.now(),
        );
        
        final profileRepository = getIt<UserProfileRepository>();
        final result = await profileRepository.updateProfile(updatedProfile);
        
        if (result != null) {
          _userProfile = result;
          
          setState(() {
            _isConnected = false;
            _psychologist = null;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Desconectado do psicólogo com sucesso!'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Exceção ao desconectar psicólogo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao desconectar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final email = _emailController.text;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    setState(() {
      _isEmailValid = emailRegex.hasMatch(email);
    });
  }
  
  /// Envia o convite para o psicólogo
  Future<void> _sendInvitation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final success = await _invitationService.sendInvitation(_emailController.text);
      
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
          
          // Limpar campo de email
          _emailController.clear();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
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
                      'Convidar Psicólogo',
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
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF9D82FF)))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: _isConnected 
                      ? _buildConnectedView() 
                      : _buildInviteView(),
                  ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Constrói a visualização quando o usuário já está conectado a um psicólogo
  Widget _buildConnectedView() {
    return Column(
      children: [
        const SizedBox(height: 40),
        
        // Ícone/Ilustração
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFF9D82FF).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.psychology_outlined,
            size: 60,
            color: Color(0xFF9D82FF),
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Título
        const Text(
          'Você está Conectado',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF22223B),
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 6),
        
        // Descrição
        Text(
          'Você já está conectado com um Psicólogo que pode acessar seus insights.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 48),
        
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
                'Dados do Psicólogo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF22223B),
                ),
              ),
              const SizedBox(height: 16),
              
              // Nome
              _buildInfoRow(
                icon: Icons.person_outline,
                label: 'Nome',
                value: _psychologist?.name ?? 'Não disponível',
              ),
              
              const SizedBox(height: 12),
              
              // CRP
              _buildInfoRow(
                icon: Icons.badge_outlined,
                label: 'CRP',
                value: _psychologist?.crp ?? 'Não disponível',
              ),
              
              const SizedBox(height: 12),
              
              // Email
              _buildInfoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: _psychologist?.email ?? 'Não disponível',
              ),
              
              if (_psychologist?.specialization != null) ...[
                const SizedBox(height: 12),
                
                // Especialização
                _buildInfoRow(
                  icon: Icons.psychology_outlined,
                  label: 'Especialização',
                  value: _psychologist!.specialization,
                ),
              ],
              
              if (_psychologist?.phone != null) ...[
                const SizedBox(height: 12),
                
                // Telefone
                _buildInfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Telefone',
                  value: _psychologist!.phone!,
                ),
              ],
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Botão de desconectar
        PrimaryButton(
          text: 'Desconectar',
          onPressed: _disconnectPsychologist,
          backgroundColor: Colors.red,
        ),
      ],
    );
  }
  
  /// Constrói uma linha de informação para o psicólogo
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
  
  /// Constrói a visualização para convidar um psicólogo
  Widget _buildInviteView() {
    return Column(
      children: [
        const SizedBox(height: 40),
        
        // Ícone/Ilustração
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFF9D82FF).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.psychology_outlined,
            size: 60,
            color: Color(0xFF9D82FF),
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Título
        const Text(
          'Conecte-se com um Psicólogo',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF22223B),
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 12),
        
        // Descrição
        Text(
          'Compartilhe seus insights e evolução com seu psicólogo de confiança.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 48),
        
        // Botão para buscar psicólogos
        PrimaryButton(
          text: 'Buscar Psicólogos',
          onPressed: () => context.push('/search-psychologist'),
          backgroundColor: const Color(0xFF9D82FF),
        ),
        
        const SizedBox(height: 16),
        
        // Ou enviar convite diretamente
        Text(
          'ou',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Container do formulário para envio direto por email
        Container(
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enviar convite diretamente por email',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF22223B),
                  ),
                ),
                const SizedBox(height: 8),
                InputField(
                  controller: _emailController,
                  hint: 'exemplo@email.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Color(0xFF9D82FF),
                    size: 20,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira um email';
                    }
                    if (!_isEmailValid) {
                      return 'Por favor, insira um email válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  text: _isLoading ? 'Enviando...' : 'Enviar Convite',
                  onPressed: _isEmailValid && !_isLoading ? _sendInvitation : null,
                  backgroundColor: const Color(0xFF9D82FF),
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
        
        // Exibir mensagem de erro se houver
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        
        const SizedBox(height: 24),
        
        // Informação adicional
        Container(
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
                  'Seu Psicólogo receberá um convite para acessar seus insights de forma segura.',
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
    );
  }
}
