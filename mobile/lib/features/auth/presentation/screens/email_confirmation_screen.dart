import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:calma_flutter/core/constants/app_colors.dart';
import 'package:calma_flutter/core/constants/app_text_styles.dart';
import 'package:calma_flutter/presentation/common_widgets/primary_button.dart';
import 'package:calma_flutter/core/di/injection.dart';
import 'package:calma_flutter/features/auth/presentation/viewmodels/auth_viewmodel.dart';

/// EmailConfirmationScreen - Tela de confirmação de email
///
/// Exibida após o cadastro, informando ao usuário que um email foi enviado
/// e fornecendo um botão para confirmar quando o email for verificado.
class EmailConfirmationScreen extends StatefulWidget {
  /// Email do usuário
  final String email;

  /// Construtor da EmailConfirmationScreen
  const EmailConfirmationScreen({
    super.key,
    required this.email,
  });

  @override
  State<EmailConfirmationScreen> createState() => _EmailConfirmationScreenState();
}

class _EmailConfirmationScreenState extends State<EmailConfirmationScreen> {
  late final AuthViewModel _authViewModel;
  bool _isLoading = false;
  bool _isVerified = false;
  Timer? _verificationTimer;
  bool _cameFromDeepLink = false;
  String _userEmail = '';
  
  @override
  void initState() {
    super.initState();
    _authViewModel = getIt<AuthViewModel>();
    
    // Verificar se veio de um deep link
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uri = GoRouterState.of(context).uri;
      final verified = uri.queryParameters['verified'];
      
      if (verified == 'true') {
        _cameFromDeepLink = true;
        debugPrint('📧 EMAIL_CONFIRMATION: Usuário chegou via deep link de verificação');
      }
      
      // Detectar o email do usuário atual se não foi fornecido
      if (widget.email.isEmpty) {
        final currentUser = _authViewModel.currentUser;
        if (currentUser != null && currentUser.email.isNotEmpty) {
          _userEmail = currentUser.email;
          debugPrint('📧 EMAIL_CONFIRMATION: Email detectado automaticamente: $_userEmail');
        }
      } else {
        _userEmail = widget.email;
      }
      
      // Verificar o status do email
      _checkEmailVerification();
    });
    
    // Configurar um timer para verificar periodicamente se o email foi confirmado
    _verificationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_isVerified && mounted) {
        _checkEmailVerification();
      } else if (_isVerified) {
        // Se o email for verificado, cancelar o timer
        timer.cancel();
      }
    });
  }
  
  @override
  void dispose() {
    _verificationTimer?.cancel();
    super.dispose();
  }
  
  /// Verifica se o email foi confirmado
  Future<void> _checkEmailVerification() async {
    if (_isLoading) return; // Evitar verificações simultâneas
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Recarregar o usuário para obter as informações mais recentes
      await _authViewModel.reloadCurrentUser();
      
      final isVerified = await _authViewModel.isEmailVerified();
      
      if (mounted) {
        setState(() {
          _isVerified = isVerified;
          _isLoading = false;
        });
        
        // Resetar flag se veio de deep link
        if (isVerified && _cameFromDeepLink) {
          _cameFromDeepLink = false;
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  /// Envia um novo email de verificação
  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _authViewModel.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email de verificação reenviado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao reenviar email: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  /// Continua para a próxima tela após verificar o email
  void _continueToNextScreen() async {
    debugPrint('🔄 EMAIL_CONFIRMATION: Verificando email antes de continuar');
    
    // Mostrar indicador de carregamento
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Verificar se o email foi confirmado
      await _checkEmailVerification();
      
      if (_isVerified) {
        debugPrint('✅ EMAIL_CONFIRMATION: Email verificado - navegando para onboarding');
        
        // Navegar para a página de lembretes do onboarding
        context.pushReplacementNamed('onboarding', queryParameters: {'page': '11'});
      } else {
        debugPrint('⚠️ EMAIL_CONFIRMATION: Email ainda não verificado');
        
        // Mostrar mensagem pedindo para verificar o email
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, verifique seu email antes de continuar.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ EMAIL_CONFIRMATION: Erro ao verificar email: $e');
      
      // Mostrar mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao verificar email: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.calmaBlueLight, Color(0xFFD6BCFA)],
            stops: [0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Borda decorativa
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.0,
                  ),
                ),
              ),

              // Conteúdo principal
              SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Botão de voltar
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.gray700),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Ícone de email - muda para check se verificado
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: _isVerified ? Colors.green : Colors.white,
                        borderRadius: BorderRadius.circular(60),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isVerified ? Icons.check_circle : Icons.email_outlined,
                        size: 60,
                        color: _isVerified ? Colors.white : AppColors.calmaBlue,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Título - muda se verificado
                    Text(
                      _isVerified ? "Email Verificado!" : "Verifique seu email",
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.gray700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Subtítulo - muda se verificado
                    if (!_isVerified) ...[
                      Text(
                        "Enviamos um link de confirmação para:",
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.gray600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      
                      // Email do usuário
                      Text(
                        _userEmail.isNotEmpty ? _userEmail : widget.email,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.calmaBlue,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ] else ...[
                      Text(
                        "Seu email foi confirmado com sucesso!",
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.gray600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Instruções - só mostra se não verificado
                    if (!_isVerified)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Por favor, verifique sua caixa de entrada e clique no link de confirmação que enviamos.",
                              style: TextStyle(
                                color: AppColors.gray700,
                                fontSize: 16,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Não se esqueça de verificar também sua pasta de spam.",
                              style: TextStyle(
                                color: AppColors.gray600,
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 32),

                    // Botão para confirmar
                    PrimaryButton(
                      text: _isVerified 
                          ? "Continuar" 
                          : "Já verifiquei meu e-mail",
                      onPressed: _continueToNextScreen,
                      isLoading: _isLoading,
                      height: 52,
                      borderRadius: 50,
                    ),
                    const SizedBox(height: 16),

                    // Botão para reenviar email - só mostra se não verificado
                    if (!_isVerified)
                      TextButton(
                        onPressed: _isLoading ? null : _resendVerificationEmail,
                        child: Text(
                          "Reenviar email de confirmação",
                          style: AppTextStyles.buttonMedium.copyWith(
                            color: AppColors.calmaBlue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    
                    // Status de verificação
                    if (_isVerified)
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.green,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Pronto para configurar lembretes!",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
