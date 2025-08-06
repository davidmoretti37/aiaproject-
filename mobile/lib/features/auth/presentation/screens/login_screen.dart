import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:calma_flutter/core/constants/app_colors.dart';
import 'package:calma_flutter/core/constants/app_text_styles.dart';
import 'package:calma_flutter/core/utils/mixin_utils.dart';
import 'package:calma_flutter/presentation/common_widgets/input_field.dart';
import 'package:calma_flutter/presentation/common_widgets/primary_button.dart';
import 'package:calma_flutter/presentation/common_widgets/text_button_custom.dart';
import 'package:calma_flutter/core/di/injection.dart';
import '../viewmodels/auth_viewmodel.dart';

/// LoginScreen - Tela de autenticação do aplicativo C'Alma
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with MixinsUtils {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final AuthViewModel _authViewModel;
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _authViewModel = getIt<AuthViewModel>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Gerencia o evento de login
  void _handleLogin() async {
    // Validar o formulário
    if (!_validateForm()) return;

    print("📱 LOGIN: Iniciando login para: ${_emailController.text}");
    
    try {
      final success = await _authViewModel.signIn(
        _emailController.text,
        _passwordController.text,
      );
      
      print("📱 LOGIN: Resultado do login: ${success ? 'Sucesso' : 'Falha'}");
      
      if (success && mounted) {
        print("📱 LOGIN: Usuário logado: ${_authViewModel.currentUser?.id}");
        print("📱 LOGIN: Navegando para /home");
        
        // Forçar uma atualização do estado antes de navegar
        await Future.delayed(const Duration(milliseconds: 300));
        
        if (mounted) {
          context.go('/home');
        }
      } else if (mounted) {
        // Identificar o tipo de erro e atualizar os campos correspondentes
        final errorMessage = _authViewModel.errorMessage ?? 'Erro ao fazer login';
        print("📱 LOGIN: Erro: $errorMessage");
        
        // Verificar se é erro de email não confirmado
        if (_authViewModel.isEmailNotConfirmedError) {
          print("📱 LOGIN: Email não confirmado - redirecionando para confirmação");
          context.pushNamed('email-confirmation', queryParameters: {
            'email': _emailController.text,
          });
        } else if (errorMessage.contains('Email ou senha incorretos')) {
          // Destacar ambos os campos para indicar que qualquer um pode estar incorreto
          setState(() {
            _emailError = 'Verifique seu email';
            _passwordError = 'Verifique sua senha';
          });
        } else if (errorMessage.contains('Email inválido')) {
          setState(() {
            _emailError = 'Email inválido';
          });
        } else if (errorMessage.contains('Usuário não cadastrado')) {
          setState(() {
            _emailError = 'Usuário não cadastrado';
          });
        } else {
          // Exibir erro geral em um dialog
          _showErrorDialog(errorMessage);
        }
      }
    } catch (e) {
      print("📱 LOGIN: Exceção: $e");
      _showErrorDialog('Erro inesperado: $e');
    }
  }
  
  /// Exibe um dialog de erro com a mensagem fornecida
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Erro de Autenticação',
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

  /// Valida o formulário de login
  bool _validateForm() {
    // Validação do email usando o mixin
    final emailValid = validateEmail(_emailController.text);

    // Para login, apenas verificamos se a senha não está vazia
    final passwordValid = isEmpty(
      _passwordController.text,
      'Por favor, insira sua senha',
    );

    setState(() {
      _emailError = emailValid;
      _passwordError = passwordValid;
    });

    return emailValid == null && passwordValid == null;
  }

  /// Navega para a tela de cadastro
  void _navigateToSignUp() {
    context.go('/signup');
  }

  /// Navega para a tela de recuperação de senha
  void _navigateToForgotPassword() {
    context.pushNamed('forgot-password');
  }

  @override
  Widget build(BuildContext context) {
    // O resto do código permanece igual
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
          child: Stack(children: [_buildBorder(), _buildContent()]),
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

  /// Constrói todo o conteúdo da tela
  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botão de voltar
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black54),
            onPressed: () => context.go('/'),
          ),
          const SizedBox(height: 20),

          // Título da tela
          Text(
            "Bem-vindo de volta",
            style: AppTextStyles.heading1.copyWith(
              color: AppColors.gray700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),

          // Subtítulo
          Text(
            "Entre na sua conta para continuar a jornada de autocuidado",
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray600),
          ),
          const SizedBox(height: 40),

          // Formulário de login
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Campo de email
                InputField(
                  controller: _emailController,
                  label: "Email",
                  hint: "seuemail@exemplo.com",
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  errorText: _emailError,
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                ),
                const SizedBox(height: 20),

                // Campo de senha
                InputField(
                  controller: _passwordController,
                  label: "Senha",
                  hint: "Sua senha",
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

                // Link "Esqueceu a Senha?"
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _navigateToForgotPassword,
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 12.0,
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      "Esqueceu a Senha?",
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.calmaBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Botão de Login
                PrimaryButton(
                  text: "Entrar",
                  onPressed: _handleLogin,
                  isLoading: _authViewModel.isLoading,
                  height: 52,
                  borderRadius: 50,
                ),

                const SizedBox(height: 40),

                // Link para criar conta
                Center(
                  child: TextButtonCustom(
                    text: "Não tem uma conta? Crie agora",
                    onPressed: _navigateToSignUp,
                    textColor: AppColors.gray700,
                    textStyle: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w400,
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

  // Os métodos de login social foram removidos conforme solicitação
}
