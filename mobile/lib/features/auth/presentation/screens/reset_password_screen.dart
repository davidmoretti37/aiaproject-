import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:calma_flutter/core/constants/app_colors.dart';
import 'package:calma_flutter/core/constants/app_text_styles.dart';
import 'package:calma_flutter/core/utils/mixin_utils.dart';
import 'package:calma_flutter/presentation/common_widgets/input_field.dart';
import 'package:calma_flutter/presentation/common_widgets/primary_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ResetPasswordScreen - Tela para definir nova senha via deep link
class ResetPasswordScreen extends StatefulWidget {
  final String? token;
  final String? accessToken;
  final String? refreshToken;
  
  const ResetPasswordScreen({
    super.key,
    this.token,
    this.accessToken,
    this.refreshToken,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with MixinsUtils {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _passwordError;
  bool _isLoading = false;
  
  // Visibilidade da senha
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    
    // Log dos tokens recebidos
    debugPrint('🔑 RESET_PASSWORD: Token recebido: ${widget.token}');
    debugPrint('🔑 RESET_PASSWORD: Access Token: ${widget.accessToken?.substring(0, 20)}...');
    debugPrint('🔑 RESET_PASSWORD: Refresh Token: ${widget.refreshToken?.substring(0, 20)}...');
    
    // Verificar se há tokens válidos
    if ((widget.accessToken == null || widget.refreshToken == null) && 
        (widget.token == null || widget.token!.isEmpty)) {
      debugPrint('❌ RESET_PASSWORD: Nenhum token válido encontrado');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorAndGoBack('Link de redefinição inválido ou expirado');
      });
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Gerencia a definição da nova senha
  void _handleSetNewPassword() async {
    if (!_validatePasswordForm()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('🔑 RESET_PASSWORD: Iniciando processo de redefinição de senha');
      
      final supabase = Supabase.instance.client;
      
      // MÉTODO CORRETO: Usar verifyOtp para tokens de recuperação
      String? tokenToUse;
      
      if (widget.accessToken != null) {
        debugPrint('🔑 RESET_PASSWORD: Usando access_token...');
        tokenToUse = widget.accessToken!;
      } else if (widget.token != null) {
        debugPrint('🔑 RESET_PASSWORD: Usando token simples...');
        tokenToUse = widget.token!;
      } else {
        throw AuthException('Nenhum token válido encontrado');
      }
      
      debugPrint('🔑 RESET_PASSWORD: Estabelecendo sessão com token de recuperação...');
      
      // MÉTODO SIMPLIFICADO: Tentar atualizar senha diretamente
      // O Supabase deve processar o token automaticamente se estiver na URL
      debugPrint('🔑 RESET_PASSWORD: Tentando atualizar senha diretamente...');
      
      // Verificar se há uma sessão ativa primeiro
      final currentUser = supabase.auth.currentUser;
      debugPrint('🔑 RESET_PASSWORD: Usuário atual: ${currentUser?.email ?? "Nenhum"}');
      
      // Se não há usuário, tentar estabelecer sessão com o token
      if (currentUser == null) {
        debugPrint('🔑 RESET_PASSWORD: Nenhum usuário logado, tentando estabelecer sessão...');
        
        try {
          // Tentar usar o token como access token
          await supabase.auth.setSession(tokenToUse);
          debugPrint('✅ RESET_PASSWORD: Sessão estabelecida com sucesso');
          
          final newUser = supabase.auth.currentUser;
          if (newUser != null) {
            debugPrint('✅ RESET_PASSWORD: Usuário autenticado: ${newUser.email}');
          } else {
            throw AuthException('Falha ao estabelecer sessão');
          }
          
        } catch (sessionError) {
          debugPrint('❌ RESET_PASSWORD: Erro ao estabelecer sessão: $sessionError');
          throw AuthException('Token de recuperação inválido ou expirado');
        }
      }
      
      // PASSO 2: Agora atualizar a senha (usuário já está autenticado)
      debugPrint('🔑 RESET_PASSWORD: Atualizando senha do usuário...');
      
      final updateResponse = await supabase.auth.updateUser(
        UserAttributes(password: _newPasswordController.text),
      );
      
      if (updateResponse.user != null) {
        debugPrint('✅ RESET_PASSWORD: Senha atualizada com sucesso');
        debugPrint('✅ RESET_PASSWORD: Usuário: ${updateResponse.user!.email}');
        debugPrint('✅ RESET_PASSWORD: ID: ${updateResponse.user!.id}');
        
        // PASSO 3: Fazer logout para garantir que nova senha seja aplicada
        debugPrint('🔑 RESET_PASSWORD: Fazendo logout para aplicar nova senha...');
        await supabase.auth.signOut();
        debugPrint('✅ RESET_PASSWORD: Logout realizado - nova senha aplicada');
        
        setState(() {
          _isLoading = false;
        });

        // Exibir mensagem de sucesso
        _showSuccessDialog();
        return;
      }
      
      // Se chegou aqui, algo deu errado
      throw AuthException('Não foi possível atualizar a senha');
      
    } catch (e) {
      debugPrint('❌ RESET_PASSWORD: Erro ao redefinir senha: $e');
      
      setState(() {
        _isLoading = false;
      });
      
      String errorMessage = 'Erro ao redefinir senha';
      
      if (e is AuthException) {
        debugPrint('❌ RESET_PASSWORD: AuthException: ${e.message}');
        if (e.message.contains('invalid') || e.message.contains('expired') || e.message.contains('Token')) {
          errorMessage = 'Link de redefinição inválido ou expirado. Solicite um novo link.';
        } else if (e.message.contains('weak') || e.message.contains('password')) {
          errorMessage = 'Senha muito fraca. Use pelo menos 8 caracteres com números e letras';
        } else if (e.message.contains('rate')) {
          errorMessage = 'Muitas tentativas. Aguarde alguns minutos';
        } else if (e.message.contains('session') || e.message.contains('auth')) {
          errorMessage = 'Sessão inválida. Solicite um novo link de redefinição';
        } else {
          errorMessage = 'Erro: ${e.message}';
        }
      } else {
        debugPrint('❌ RESET_PASSWORD: Erro genérico: $e');
        errorMessage = 'Erro inesperado: $e';
      }
      
      _showErrorDialog(errorMessage);
    }
  }

  /// Valida o formulário de nova senha
  bool _validatePasswordForm() {
    bool isValid = true;

    // Usando o método combine para validar múltiplas regras
    final passwordValid = combine([
      () => isEmpty(_newPasswordController.text, 'Por favor, insira uma senha'),
      () => moreThanSeven(_newPasswordController.text),
      () => hasNumber(_newPasswordController.text),
      () => upperLetter(_newPasswordController.text),
      () => lowerLetter(_newPasswordController.text),
    ]);

    // Verifica se a senha é válida
    if (passwordValid != null) {
      setState(() {
        _passwordError = passwordValid;
      });
      isValid = false;
    }
    // Verifica se as senhas coincidem
    else if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _passwordError = "As senhas não coincidem";
      });
      isValid = false;
    }
    // Tudo ok
    else {
      setState(() {
        _passwordError = null;
      });
    }

    return isValid;
  }

  /// Exibe dialog de sucesso
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Senha Alterada!',
          style: AppTextStyles.heading4,
        ),
        content: Text(
          'Sua senha foi alterada com sucesso. Você pode fazer login com a nova senha.',
          style: AppTextStyles.bodyMedium,
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToLogin();
            },
            child: Text(
              'Fazer Login',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.calmaBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Exibe um dialog de erro
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Erro',
          style: AppTextStyles.heading4,
        ),
        content: Text(
          message,
          style: AppTextStyles.bodyMedium,
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.calmaBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Mostra erro e volta para login
  void _showErrorAndGoBack(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Erro',
          style: AppTextStyles.heading4,
        ),
        content: Text(
          message,
          style: AppTextStyles.bodyMedium,
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToLogin();
            },
            child: Text(
              'Voltar ao Login',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.calmaBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Navega para a tela de login
  void _navigateToLogin() {
    context.go('/login');
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
              _buildBorder(),

              // Conteúdo principal
              _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói a borda decorativa da tela
  Widget _buildBorder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.0,
        ),
      ),
    );
  }

  /// Constrói o conteúdo principal da tela
  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botão de voltar
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.gray700),
            onPressed: _navigateToLogin,
          ),
          const SizedBox(height: 20),

          // Título da tela
          Text(
            "Nova senha",
            style: AppTextStyles.heading1.copyWith(
              color: AppColors.gray700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),

          // Subtítulo
          Text(
            "Crie uma nova senha para sua conta",
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray600),
          ),
          const SizedBox(height: 40),

          // Formulário de nova senha
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Nova senha
                InputField(
                  controller: _newPasswordController,
                  label: "Nova senha",
                  hint: "Digite sua nova senha",
                  obscureText: _obscurePassword,
                  errorText: _passwordError,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Confirmar senha
                InputField(
                  controller: _confirmPasswordController,
                  label: "Confirmar senha",
                  hint: "Digite novamente a senha",
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 30),

                // Botão de confirmar
                PrimaryButton(
                  text: "Confirmar nova senha",
                  onPressed: _isLoading ? null : _handleSetNewPassword,
                  isLoading: _isLoading,
                  height: 52,
                  borderRadius: 50,
                ),

                const SizedBox(height: 20),

                // Link para voltar ao login
                Center(
                  child: TextButton(
                    onPressed: _navigateToLogin,
                    child: Text(
                      "Voltar ao login",
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.gray700,
                        fontWeight: FontWeight.w400,
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
  }
}
