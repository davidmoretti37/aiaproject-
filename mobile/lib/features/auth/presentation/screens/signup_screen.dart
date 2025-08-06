import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:calma_flutter/core/constants/app_colors.dart';
import 'package:calma_flutter/core/constants/app_text_styles.dart';
import 'package:calma_flutter/core/utils/mixin_utils.dart';
import 'package:calma_flutter/presentation/common_widgets/input_field.dart';
import 'package:calma_flutter/presentation/common_widgets/primary_button.dart';
import 'package:calma_flutter/presentation/common_widgets/text_button_custom.dart';
import 'package:calma_flutter/core/di/injection.dart';
import '../viewmodels/auth_viewmodel.dart';

/// SignUpScreen - Tela de cadastro de novos usuários
///
/// Permite que novos usuários criem uma conta no C'Alma,
/// fornecendo dados básicos e escolhendo uma senha.
class SignUpScreen extends StatefulWidget {
  /// Construtor da SignUpScreen
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with MixinsUtils {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late final AuthViewModel _authViewModel;
  bool _acceptTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _termsError;
  
  @override
  void initState() {
    super.initState();
    _authViewModel = getIt<AuthViewModel>();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Gerencia o evento de cadastro
  void _handleSignUp() async {
    // Validar o formulário
    if (!_validateForm()) return;

    setState(() {
      _termsError = null;
    });
    
    // Mostrar dialog de depuração em modo de desenvolvimento
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Text('Depuração de Cadastro'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Dados que serão enviados:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Email: ${_emailController.text}'),
              Text('Nome: ${_nameController.text}'),
              Text('Senha: ${'*' * _passwordController.text.length}'),
              const SizedBox(height: 16),
              const Text('Configuração do Supabase:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              FutureBuilder<String>(
                future: _getSupabaseInfo(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  return Text(snapshot.data ?? 'Não foi possível obter informações');
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continuar com o cadastro'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cadastro cancelado pelo usuário')),
              );
            },
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    // Verificar se o contexto ainda está montado após o diálogo
    if (!mounted) return;
    
    // Mostrar indicador de carregamento
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      print("📱 APP: Iniciando processo de cadastro no SignUpScreen");
      print("📱 APP: Email: ${_emailController.text}");
      print("📱 APP: Nome: ${_nameController.text}");
      print("📱 APP: Senha: ${'*' * _passwordController.text.length}");
      
      final success = await _authViewModel.signUp(
        _emailController.text,
        _passwordController.text,
        _nameController.text,
      );
      
      // Fechar o indicador de carregamento
      if (mounted) {
        Navigator.of(context).pop();
      }
      
      print("📱 APP: Resultado do cadastro: ${success ? 'Sucesso' : 'Falha'}");
      
      if (success && mounted) {
        print("📱 APP: Cadastro realizado com sucesso - redirecionando para confirmação de email");
        context.pushReplacementNamed('email-confirmation', queryParameters: {
          'email': _emailController.text,
        });
      } else if (mounted) {
        print("📱 APP: Exibindo erro: ${_authViewModel.errorMessage}");
        _handleSignUpError(_authViewModel.errorMessage ?? 'Erro ao criar conta');
      }
    } catch (e) {
      // Fechar o indicador de carregamento
      if (mounted) {
        Navigator.of(context).pop();
      }
      
      print("📱 APP: Exceção no cadastro: $e");
      _handleSignUpError('Erro inesperado: $e');
    }
  }
  
  /// Trata erros de cadastro de forma mais detalhada
  void _handleSignUpError(String errorMessage) {
    print("📱 APP: Tratando erro de cadastro: $errorMessage");
    
    if (errorMessage.contains('Email já cadastrado')) {
      setState(() {
        _emailError = 'Email já cadastrado';
      });
    } else if (errorMessage.contains('Email inválido')) {
      setState(() {
        _emailError = 'Email inválido';
      });
    } else if (errorMessage.contains('Senha muito fraca')) {
      setState(() {
        _passwordError = 'Senha muito fraca';
      });
    } else if (errorMessage.contains('banco de dados')) {
      // Erro específico de banco de dados
      _showErrorDialog('Erro no banco de dados do servidor. Por favor, tente novamente mais tarde.');
    } else {
      // Exibir erro geral em um dialog
      _showErrorDialog(errorMessage);
    }
  }
  
  /// Exibe um dialog de erro com a mensagem fornecida
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Erro de Cadastro',
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

  /// Valida o formulário de cadastro
  bool _validateForm() {
    // Validação do nome
    final nameValid = isEmpty(
      _nameController.text,
      'Por favor, insira seu nome',
    );

    // Validação do email
    final emailValid = validateEmail(_emailController.text);

    // Validação completa da senha combinando múltiplas regras
    final passwordValid = combine([
      () => isEmpty(_passwordController.text, 'Por favor, insira uma senha'),
      () => moreThanSeven(_passwordController.text),
      () => hasNumber(_passwordController.text),
      () => upperLetter(_passwordController.text),
      () => lowerLetter(_passwordController.text),
    ]);

    // Validação de confirmação de senha
    final confirmPasswordValid = matchPassword(
      _passwordController.text,
      _confirmPasswordController.text,
      'As senhas não coincidem',
    );

    setState(() {
      _nameError = nameValid;
      _emailError = emailValid;
      _passwordError = passwordValid;
      _confirmPasswordError = confirmPasswordValid;

      if (!_acceptTerms) {
        _termsError = 'Você precisa aceitar os termos para continuar';
      } else {
        _termsError = null;
      }
    });

    return nameValid == null &&
        emailValid == null &&
        passwordValid == null &&
        confirmPasswordValid == null &&
        _acceptTerms;
  }

  /// Navega para a tela de login
  void _navigateToLogin() {
    context.go('/login');
  }

  /// Navega para a tela de termos
  void _navigateToTerms() {
    context.goNamed('terms');
  }

  /// Navega para a tela de política de privacidade
  void _navigateToPrivacy() {
    context.goNamed('privacy');
  }
  
  /// Obtém informações sobre a configuração do Supabase
  Future<String> _getSupabaseInfo() async {
    try {
      final url = dotenv.env['SUPABASE_URL'] ?? 'URL não encontrada';
      final keyPrefix = dotenv.env['SUPABASE_ANON_KEY']?.substring(0, 10) ?? 'Chave não encontrada';
      
      return 'URL: $url\nChave: $keyPrefix...';
    } catch (e) {
      return 'Erro ao obter informações: $e';
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

  /// Constrói todo o conteúdo da tela
  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botão de voltar
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.gray700),
            onPressed: () => context.go('/'),
          ),
          const SizedBox(height: 20),

          // Título da tela
          Text(
            "Criar conta",
            style: AppTextStyles.heading1.copyWith(
              color: AppColors.gray700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),

          // Subtítulo
          Text(
            "Comece sua jornada de autocuidado hoje",
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray600),
          ),
          const SizedBox(height: 32),

          // Formulário de cadastro
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Campo de nome
                InputField(
                  controller: _nameController,
                  label: "Nome completo",
                  hint: "Seu nome",
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  errorText: _nameError,
                  prefixIcon: const Icon(Icons.person_outline, size: 20),
                ),
                const SizedBox(height: 20),

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
                const SizedBox(height: 20),

                // Campo de confirmação de senha
                InputField(
                  controller: _confirmPasswordController,
                  label: "Confirmar senha",
                  hint: "Digite sua senha novamente",
                  obscureText: _obscureConfirmPassword,
                  errorText: _confirmPasswordError,
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
                const SizedBox(height: 24),

                // Checkbox de aceitação de termos
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Transform.scale(
                      scale: 1.0,
                      child: Checkbox(
                        value: _acceptTerms,
                        onChanged: (value) {
                          setState(() {
                            _acceptTerms = value ?? false;
                            if (_acceptTerms) {
                              _termsError = null;
                            }
                          });
                        },
                        activeColor: AppColors.calmaBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.gray600,
                              ),
                              children: [
                                const TextSpan(text: 'Eu aceito os '),
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: _navigateToTerms,
                                    child: Text(
                                      'Termos de Uso',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.calmaBlue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                                const TextSpan(text: ' e a '),
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: _navigateToPrivacy,
                                    child: Text(
                                      'Política de Privacidade',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.calmaBlue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_termsError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                _termsError!,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Botão de cadastro
                PrimaryButton(
                  text: "Criar conta",
                  onPressed: _handleSignUp,
                  isLoading: _authViewModel.isLoading,
                  height: 52,
                  borderRadius: 50,
                ),
                const SizedBox(height: 24),

                // Link para login
                Center(
                  child: TextButtonCustom(
                    text: "Já tem uma conta? Entre agora",
                    onPressed: _navigateToLogin,
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
}
