import 'package:calma_flutter/features/onboarding/presentation/components/wavy_line_widget.dart';
import 'package:flutter/material.dart';
import 'package:calma_flutter/features/onboarding/presentation/components/onboarding_content_model.dart';
import 'package:calma_flutter/features/reminders/presentation/viewmodels/reminder_viewmodel.dart';
import 'package:calma_flutter/presentation/common_widgets/time_wheel_picker.dart';
import 'package:get_it/get_it.dart';

/// OnboardingScreenBuilder - Constrói diferentes tipos de telas de onboarding
///
/// Factory que retorna o widget correto baseado no tipo de conteúdo da tela
class OnboardingScreenBuilder {
  /// Constrói APENAS o conteúdo da tela, sem barra de progresso e botão
  /// Este método será usado pelo novo OnboardingScreen para manter elementos fixos
  static Widget buildScreenContent({
    required OnboardingContentModel content,
    required Function(bool) onValidationChanged,
    TextEditingController? nameController,
    TextEditingController? emailController,
    TextEditingController? phoneController,
    TextEditingController? passwordController,
    TextEditingController? confirmPasswordController,
    String? emailError,
    bool? rememberMe,
    Function(bool)? onRememberMeChanged,
    Function(String)? onTextInputChanged,
    Function(String)? onOptionSelected,
    Function(List<String>)? onMultipleOptionsSelected,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: _buildContent(
              content, 
              onValidationChanged,
              nameController,
              emailController,
              phoneController,
              passwordController,
              confirmPasswordController,
              emailError,
              rememberMe,
              onRememberMeChanged,
              onTextInputChanged,
              onOptionSelected,
              onMultipleOptionsSelected,
            )),
          ),
        );
      },
    );
  }

  // Método privado para construir o conteúdo adequado
  static Widget _buildContent(
    OnboardingContentModel content,
    Function(bool) onValidationChanged,
    TextEditingController? nameController,
    TextEditingController? emailController,
    TextEditingController? phoneController,
    TextEditingController? passwordController,
    TextEditingController? confirmPasswordController,
    String? emailError,
    bool? rememberMe,
    Function(bool)? onRememberMeChanged,
    Function(String)? onTextInputChanged,
    Function(String)? onOptionSelected,
    Function(List<String>)? onMultipleOptionsSelected,
  ) {
    switch (content.type) {
      case OnboardingContentType.info:
        onValidationChanged(true); // Sempre válido
        return _buildInfoContent(content: content);
      case OnboardingContentType.chatExample:
        onValidationChanged(true); // Sempre válido
        return _buildChatExampleContent(content: content);
      case OnboardingContentType.insight:
        onValidationChanged(true); // Sempre válido
        return _buildInsightContent(content: content);
      case OnboardingContentType.textInput:
        return _buildTextInputContent(
          content: content,
          onValidationChanged: onValidationChanged,
          nameController: nameController,
          emailController: emailController,
          phoneController: phoneController,
          passwordController: passwordController,
          confirmPasswordController: confirmPasswordController,
          emailError: emailError,
          rememberMe: rememberMe,
          onRememberMeChanged: onRememberMeChanged,
          onTextInputChanged: onTextInputChanged,
        );
      case OnboardingContentType.optionSelect:
        return _buildOptionSelectContent(
          content: content,
          onValidationChanged: onValidationChanged,
          onOptionSelected: onOptionSelected,
          onMultipleOptionsSelected: onMultipleOptionsSelected,
        );
      case OnboardingContentType.configuration:
        return _buildConfigurationContent(
          content: content,
          onValidationChanged: onValidationChanged,
        );
    }
  }

  /// Construir apenas o conteúdo da tela de informação
  static Widget _buildInfoContent({required OnboardingContentModel content}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Stack(
        children: [
          // Círculos decorativos de fundo (apenas quando não houver visualElement)
          if (content.visualElement == null) ...[
            // Posicionar vários círculos decorativos com diferentes tamanhos e posições
            Positioned(
              top: 80,
              left: 20,
              child: _buildDecorativeCircle(18, const Color(0xFFD4E5FF)),
            ),
            Positioned(
              top: 50,
              right: 80,
              child: _buildDecorativeCircle(12, const Color(0xFFD4E5FF)),
            ),
            // ...outros círculos decorativos...
          ],

          // Conteúdo principal
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Elemento visual (se houver)
              if (content.visualElement != null) ...[
                SizedBox(
                  height: 240,
                  child: Center(child: content.visualElement!),
                ),
                const SizedBox(height: 32),
              ],

              // Título centralizado (com tamanho aumentado para página de perfil)
              if (content.title != null) ...[
                Text(
                  content.title!,
                  style: TextStyle(
                    color: const Color(0xFF333333),
                    fontSize:
                        content.pageIndex == 5
                            ? 28
                            : 20, // Maior para a tela de perfil
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              // Subtítulo ou descrição (se houver)
              if (content.subtitle != null) ...[
                const SizedBox(height: 12),
                Text(
                  content.subtitle!,
                  style: const TextStyle(color: Colors.black54, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Construir apenas o conteúdo da tela de chat exemplo
  static Widget _buildChatExampleContent({
    required OnboardingContentModel content,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Layout ajustado com ícone de microfone posicionado corretamente
          Stack(
            clipBehavior:
                Clip.none, // Para permitir que o botão se estenda para fora
            children: [
              // Bolha de conversa estilo iOS
              if (content.chatBubbles != null &&
                  content.chatBubbles!.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 5.0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        content.chatBubbles!.map((bubble) {
                          // Verifica se o texto é formatado ou regular
                          if (bubble['formattedText'] == true &&
                              bubble['segments'] != null) {
                            // Texto formatado com cores diferentes
                            List<InlineSpan> spans = [];
                            for (var segment in bubble['segments']) {
                              spans.add(
                                TextSpan(
                                  text: segment['text'],
                                  style: TextStyle(
                                    color: segment['color'],
                                    fontSize: 16,
                                    fontWeight: segment['weight'],
                                    height: 1.4,
                                  ),
                                ),
                              );
                            }

                            return RichText(text: TextSpan(children: spans));
                          } else {
                            // Texto regular
                            return Text(
                              bubble['text'],
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                height: 1.4,
                              ),
                            );
                          }
                        }).toList(),
                  ),
                ),
              ],

              // Botão de microfone/voz posicionado no topo direito da bolha
              Positioned(
                top: -5,
                right: -5,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF92CAFF),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.mic, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),

          // Elemento visual (ondas de voz)
          if (content.visualElement != null) ...[
            Container(
              height: 100,
              margin: const EdgeInsets.only(top: 16, bottom: 16),
              child: content.visualElement!,
            ),
          ],

          // Título principal com emoji
          if (content.title != null) ...[
            Text(
              content.title!,
              style: const TextStyle(
                color: Color(0xFF333333),
                fontSize: 20,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  // Implementações similares para os outros métodos de conteúdo
  static Widget _buildInsightContent({
    required OnboardingContentModel content,
  }) {
    // Implementação similar ao _buildInsightScreen mas sem barra de progresso e botão
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (content.visualElement != null) ...[
            Center(
              child: Container(
                width: 280,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cabeçalho do card
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.lightbulb_outline,
                            color: Color(0xFFFFB800),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Novo Insight',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEFCF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            '1',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFD97706),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Círculos de categorias
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Círculo 1 - Atividades
                        Column(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3E8FF),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.show_chart,
                                  color: Color(0xFFA855F7),
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Atividades\nao ar livre',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        // Círculo 2 - Emoções
                        Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF9C4),
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: const Center(
                                child: Text(
                                  '🙂',
                                  style: TextStyle(fontSize: 28),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Emoções\npositivas',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Linha decorativa ondulada
                    Center(
                      child: Container(
                        height: 20,
                        width: 120,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/wavy_line.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                        // Alternativa à imagem, caso não esteja disponível
                        child: CustomPaint(
                          painter: WavyLinePainter(
                            color: const Color(0xFF4ADE80),
                            amplitude: 3.0,
                            frequency: 2.0,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Texto do rodapé do card
                    const Center(
                      child: Text(
                        'Conexões descobertas por inteligência artificial',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Título e subtítulo
          if (content.title != null) ...[
            Text(
              content.title!,
              style: const TextStyle(
                color: Color(0xFF333333),
                fontSize: 20,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          if (content.subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              content.subtitle!,
              style: const TextStyle(
                color: Color(0xFF666666),
                fontSize: 16,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  static Widget _buildTextInputContent({
    required OnboardingContentModel content,
    required Function(bool) onValidationChanged,
    TextEditingController? nameController,
    TextEditingController? emailController,
    TextEditingController? phoneController,
    TextEditingController? passwordController,
    TextEditingController? confirmPasswordController,
    String? emailError,
    bool? rememberMe,
    Function(bool)? onRememberMeChanged,
    Function(String)? onTextInputChanged,
  }) {
    final bool isContactInfoScreen =
        content.pageIndex == 11 || content.title?.contains('contato') == true;

    if (isContactInfoScreen) {
      // Controllers para os campos de texto - usar os fornecidos ou criar novos
      final TextEditingController _nameController = nameController ?? TextEditingController();
      final TextEditingController _emailController = emailController ?? TextEditingController();
      final TextEditingController _phoneController = phoneController ?? TextEditingController();
      final TextEditingController _passwordController = passwordController ?? TextEditingController();
      final TextEditingController _confirmPasswordController = confirmPasswordController ?? TextEditingController();

      // Estados para visibilidade das senhas
      ValueNotifier<bool> obscurePassword = ValueNotifier<bool>(true);
      ValueNotifier<bool> obscureConfirmPassword = ValueNotifier<bool>(true);
      
      // Estados para mensagens de erro
      ValueNotifier<String?> passwordError = ValueNotifier<String?>(null);
      ValueNotifier<String?> confirmPasswordError = ValueNotifier<String?>(null);

      // Estado para o checkbox de termos
      ValueNotifier<bool> acceptTerms = ValueNotifier<bool>(false);
      ValueNotifier<String?> termsError = ValueNotifier<String?>(null);
      
      // Função para validar os campos e habilitar o botão de continuar
      void validateFields() {
        final isNameValid = _nameController.text.trim().isNotEmpty;
        final isEmailValid = _isValidEmail(_emailController.text.trim());
        
        // Validação de senha
        final password = _passwordController.text;
        final confirmPassword = _confirmPasswordController.text;
        
        bool isPasswordValid = false;
        bool isConfirmPasswordValid = false;
        
        // Validar senha
        if (password.isEmpty) {
          passwordError.value = 'Por favor, insira uma senha';
        } else if (password.length < 8) {
          passwordError.value = 'A senha deve ter pelo menos 8 caracteres';
        } else if (!password.contains(RegExp(r'[A-Z]'))) {
          passwordError.value = 'A senha deve conter pelo menos uma letra maiúscula';
        } else if (!password.contains(RegExp(r'[a-z]'))) {
          passwordError.value = 'A senha deve conter pelo menos uma letra minúscula';
        } else if (!password.contains(RegExp(r'[0-9]'))) {
          passwordError.value = 'A senha deve conter pelo menos um número';
        } else {
          passwordError.value = null;
          isPasswordValid = true;
        }
        
        // Validar confirmação de senha
        if (confirmPassword.isEmpty) {
          confirmPasswordError.value = 'Por favor, confirme sua senha';
        } else if (confirmPassword != password) {
          confirmPasswordError.value = 'As senhas não coincidem';
        } else {
          confirmPasswordError.value = null;
          isConfirmPasswordValid = true;
        }
        
        // Validar aceitação dos termos
        if (!acceptTerms.value) {
          termsError.value = 'Você precisa aceitar os termos para continuar';
        } else {
          termsError.value = null;
        }
        
        final canContinue = isNameValid && isEmailValid && isPasswordValid && isConfirmPasswordValid && acceptTerms.value;

        // Notifica o OnboardingScreen sobre o estado de validação
        onValidationChanged(canContinue);
      }

      // Inicializar como inválido
      onValidationChanged(false);

      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Stack(
              children: [
                // Círculos decorativos de fundo
                Positioned(
                  top: 80,
                  left: 20,
                  child: _buildDecorativeCircle(18, const Color(0xFFD4E5FF)),
                ),
                Positioned(
                  top: 50,
                  right: 80,
                  child: _buildDecorativeCircle(12, const Color(0xFFD4E5FF)),
                ),
                Positioned(
                  top: 150,
                  right: 30,
                  child: _buildDecorativeCircle(24, const Color(0xFFCCE0FF)),
                ),

                // Conteúdo principal
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),

                    // Título centralizado
                    if (content.title != null) ...[
                      Center(
                        child: Text(
                          content.title!,
                          style: const TextStyle(
                            color: Color(0xFF333333),
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Campo de nome completo
                    const Text(
                      'Nome Completo *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Digite seu nome completo',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      onChanged: (_) => validateFields(),
                    ),
                    const SizedBox(height: 16),

                    // Campo de email
                    const Text(
                      'Email *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'seu@email.com',
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: Colors.grey,
                          size: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: emailError != null 
                              ? const BorderSide(color: Colors.red, width: 1.0)
                              : BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: emailError != null 
                              ? const BorderSide(color: Colors.red, width: 1.0)
                              : BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      onChanged: (_) => validateFields(),
                    ),
                    if (emailError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                        child: Text(
                          emailError,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Campo de telefone (opcional)
                    const Text(
                      'Telefone (opcional)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: '+55 (00) 00000-0000',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Campo de senha
                    const Text(
                      'Senha *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<bool>(
                      valueListenable: obscurePassword,
                      builder: (context, isObscured, _) {
                        return ValueListenableBuilder<String?>(
                          valueListenable: passwordError,
                          builder: (context, error, _) {
                            return TextField(
                              controller: _passwordController,
                              obscureText: isObscured,
                              decoration: InputDecoration(
                                hintText: 'Digite sua senha',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    obscurePassword.value = !isObscured;
                                  },
                                ),
                                errorText: error,
                              ),
                              onChanged: (_) => validateFields(),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Campo de confirmação de senha
                    const Text(
                      'Confirmar Senha *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<bool>(
                      valueListenable: obscureConfirmPassword,
                      builder: (context, isObscured, _) {
                        return ValueListenableBuilder<String?>(
                          valueListenable: confirmPasswordError,
                          builder: (context, error, _) {
                            return TextField(
                              controller: _confirmPasswordController,
                              obscureText: isObscured,
                              decoration: InputDecoration(
                                hintText: 'Confirme sua senha',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    obscureConfirmPassword.value = !isObscured;
                                  },
                                ),
                                errorText: error,
                              ),
                              onChanged: (_) => validateFields(),
                            );
                          },
                        );
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Checkbox "Lembre-se de mim"
                    if (rememberMe != null && onRememberMeChanged != null)
                      Row(
                        children: [
                          Transform.scale(
                            scale: 1.0,
                            child: Checkbox(
                              value: rememberMe,
                              onChanged: (value) {
                                if (value != null) {
                                  onRememberMeChanged(value);
                                }
                              },
                              activeColor: const Color(0xFF9C89B8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const Text(
                            'Lembre-se de mim',
                            style: TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    
                    const SizedBox(height: 24),
                    
                    // Checkbox de aceitação de termos
                    ValueListenableBuilder<bool>(
                      valueListenable: acceptTerms,
                      builder: (context, isAccepted, _) {
                        return ValueListenableBuilder<String?>(
                          valueListenable: termsError,
                          builder: (context, error, _) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Transform.scale(
                                      scale: 1.0,
                                      child: Checkbox(
                                        value: isAccepted,
                                        onChanged: (value) {
                                          acceptTerms.value = value ?? false;
                                          validateFields();
                                        },
                                        activeColor: const Color(0xFF9C89B8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                            color: Color(0xFF666666),
                                            fontSize: 14,
                                          ),
                                          children: [
                                            const TextSpan(text: 'Eu aceito os '),
                                            WidgetSpan(
                                              child: GestureDetector(
                                                onTap: () {
                                                  // Navegar para a tela de termos
                                                  Navigator.of(context).pushNamed('terms');
                                                },
                                                child: const Text(
                                                  'Termos de Uso',
                                                  style: TextStyle(
                                                    color: Color(0xFF9C89B8),
                                                    decoration: TextDecoration.underline,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const TextSpan(text: ' e a '),
                                            WidgetSpan(
                                              child: GestureDetector(
                                                onTap: () {
                                                  // Navegar para a tela de privacidade
                                                  Navigator.of(context).pushNamed('privacy');
                                                },
                                                child: const Text(
                                                  'Política de Privacidade',
                                                  style: TextStyle(
                                                    color: Color(0xFF9C89B8),
                                                    decoration: TextDecoration.underline,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (error != null)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 40.0, top: 4.0),
                                    child: Text(
                                      error,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    } else {
      final TextEditingController textController = TextEditingController();

      // Inicializar como inválido
      onValidationChanged(false);
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Stack(
              children: [
                // Círculos decorativos de fundo
                Positioned(
                  top: 80,
                  left: 20,
                  child: _buildDecorativeCircle(18, const Color(0xFFD4E5FF)),
                ),
                Positioned(
                  top: 50,
                  right: 80,
                  child: _buildDecorativeCircle(12, const Color(0xFFD4E5FF)),
                ),
                Positioned(
                  top: 150,
                  right: 30,
                  child: _buildDecorativeCircle(24, const Color(0xFFCCE0FF)),
                ),

                // Conteúdo principal
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Título centralizado
                    if (content.title != null) ...[
                      Text(
                        content.title!,
                        style: const TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Subtítulo (opcional)
                    if (content.subtitle != null) ...[
                      Text(
                        content.subtitle!,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Campo de entrada de texto
                    TextField(
                      controller: textController,
                      decoration: InputDecoration(
                        hintText: content.placeholder ?? 'Digite aqui',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      onChanged: (value) {
                        onValidationChanged(value.trim().isNotEmpty);
                        if (onTextInputChanged != null) {
                          onTextInputChanged(value);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }
  }

  static Widget _buildOptionSelectContent({
    required OnboardingContentModel content,
    required Function(bool) onValidationChanged,
    Function(String)? onOptionSelected,
    Function(List<String>)? onMultipleOptionsSelected,
  }) {
    // Estado para armazenar a opção selecionada (para seleção única)
    ValueNotifier<String?> selectedOption = ValueNotifier<String?>(null);

    // Estado para armazenar múltiplas opções selecionadas
    ValueNotifier<List<String>> selectedOptions = ValueNotifier<List<String>>(
      [],
    );

    // Inicializar como inválido
    onValidationChanged(false);

    // Método para salvar com base no tipo de dado
    void saveSelectedOption(String option) {
      if (content.multiSelect) {
        // Para seleção de objetivos, adicionar ou remover da lista
        List<String> currentOptions = List.from(selectedOptions.value);
        if (currentOptions.contains(option)) {
          currentOptions.remove(option);
        } else {
          currentOptions.add(option);
        }
        selectedOptions.value = currentOptions;

        // Notificar o callback de múltiplas seleções
        if (onMultipleOptionsSelected != null) {
          onMultipleOptionsSelected(currentOptions);
        }

        // Notificar validação (válido se pelo menos uma opção selecionada)
        onValidationChanged(currentOptions.isNotEmpty);
      } else {
        selectedOption.value = option;
        
        // Notificar o callback de seleção única
        if (onOptionSelected != null) {
          onOptionSelected(option);
        }
        
        // Notificar validação (sempre válido para seleção única)
        onValidationChanged(true);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Stack(
        children: [
          // Círculos decorativos de fundo
          Positioned(
            top: 80,
            left: 20,
            child: _buildDecorativeCircle(18, const Color(0xFFD4E5FF)),
          ),
          Positioned(
            top: 50,
            right: 80,
            child: _buildDecorativeCircle(12, const Color(0xFFD4E5FF)),
          ),
          Positioned(
            top: 150,
            right: 30,
            child: _buildDecorativeCircle(24, const Color(0xFFCCE0FF)),
          ),
          Positioned(
            bottom: 200,
            left: 40,
            child: _buildDecorativeCircle(30, const Color(0xFFE6E1FA)),
          ),
          Positioned(
            bottom: 300,
            right: 60,
            child: _buildDecorativeCircle(15, const Color(0xFFDFD8F7)),
          ),
          Positioned(
            bottom: 100,
            left: 70,
            child: _buildDecorativeCircle(20, const Color(0xFFCCE0FF)),
          ),

          // Conteúdo principal
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título centralizado
              if (content.title != null) ...[
                Text(
                  content.title!,
                  style: const TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
              ],

              // Opções em formato de botões
              if (content.options != null) ...[
                if (content.multiSelect) ...[
                  // Interface para seleção múltipla
                  ValueListenableBuilder<List<String>>(
                    valueListenable: selectedOptions,
                    builder: (context, selectedValues, _) {
                      return Column(
                        children:
                            content.options!.map((option) {
                              final bool isSelected = selectedValues.contains(
                                option,
                              );
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? const Color(0xFF9C89B8)
                                            : Colors.transparent,
                                    width: isSelected ? 2 : 0,
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    saveSelectedOption(option);
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 16.0,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            option,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF333333),
                                            ),
                                          ),
                                        ),
                                        if (isSelected)
                                          const Icon(
                                            Icons.check_circle,
                                            color: Color(0xFF9C89B8),
                                            size: 24,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      );
                    },
                  ),
                ] else ...[
                  // Interface para seleção única (rádio buttons)
                  ValueListenableBuilder<String?>(
                    valueListenable: selectedOption,
                    builder: (context, selectedValue, _) {
                      return Column(
                        children:
                            content.options!.map((option) {
                              final bool isSelected = selectedValue == option;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? const Color(0xFF9C89B8)
                                            : Colors.transparent,
                                    width: isSelected ? 2 : 0,
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    selectedOption.value = option;
                                    saveSelectedOption(option);
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 16.0,
                                    ),
                                    child: Row(
                                      children: [
                                        Radio<String>(
                                          value: option,
                                          groupValue: selectedValue,
                                          onChanged: (String? value) {
                                            selectedOption.value = value;
                                            if (value != null) {
                                              saveSelectedOption(value);
                                            }
                                          },
                                          activeColor: const Color(0xFF9C89B8),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          option,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF333333),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      );
                    },
                  ),
                ],
              ],
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildConfigurationContent({
    required Function(bool) onValidationChanged,
    required OnboardingContentModel content,
  }) {
    // Máximo de lembretes permitidos
    const int maxReminders = 3;
    
    onValidationChanged(true);

    return StatefulBuilder(
      builder: (context, setState) {
        // Obter o ReminderViewModel
        final reminderViewModel = GetIt.instance<ReminderViewModel>();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Stack(
            children: [
              // Círculos decorativos de fundo
              Positioned(
                top: 80,
                left: 20,
                child: _buildDecorativeCircle(18, const Color(0xFFD4E5FF)),
              ),
              Positioned(
                top: 50,
                right: 80,
                child: _buildDecorativeCircle(12, const Color(0xFFD4E5FF)),
              ),
              Positioned(
                top: 150,
                right: 30,
                child: _buildDecorativeCircle(24, const Color(0xFFCCE0FF)),
              ),
              Positioned(
                bottom: 200,
                left: 40,
                child: _buildDecorativeCircle(30, const Color(0xFFE6E1FA)),
              ),
              Positioned(
                bottom: 300,
                right: 60,
                child: _buildDecorativeCircle(15, const Color(0xFFDFD8F7)),
              ),
              Positioned(
                bottom: 100,
                left: 70,
                child: _buildDecorativeCircle(20, const Color(0xFFCCE0FF)),
              ),

              // Conteúdo principal
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Ícone de relógio
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.alarm,
                        size: 40,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Título
                  if (content.title != null) ...[
                    Text(
                      content.title!,
                      style: const TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  // Subtítulo
                  if (content.subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      content.subtitle!,
                      style: const TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 16,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Lista de lembretes
                  AnimatedBuilder(
                    animation: reminderViewModel,
                    builder: (context, _) {
                      final remindersList = reminderViewModel.reminders;
                      return Column(
                        children: [
                          // Lista de horários já adicionados
                          ...remindersList.map(
                            (reminder) => _buildTimePickerItem(
                              time: reminder.toTimeOfDay(),
                              onTap: () async {
                                final newTime = await TimeWheelPickerDialog.show(
                                  context: context,
                                  initialTime: reminder.toTimeOfDay(),
                                  title: 'Editar Horário',
                                );

                                if (newTime != null && reminder.id != null) {
                                  reminderViewModel.updateReminder(reminder.id!, newTime);
                                }
                              },
                              onDelete: () {
                                if (remindersList.length > 1 && reminder.id != null) {
                                  reminderViewModel.removeReminder(reminder.id!);
                                }
                              },
                            ),
                          ),

                          // Botão para adicionar mais lembretes se não atingiu o limite
                          if (remindersList.length < maxReminders) ...[
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () async {
                                final newTime = await TimeWheelPickerDialog.show(
                                  context: context,
                                  initialTime: const TimeOfDay(
                                    hour: 12,
                                    minute: 0,
                                  ),
                                  title: 'Adicionar Lembrete',
                                );

                                if (newTime != null) {
                                  await reminderViewModel.addReminder(newTime);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_circle_outline,
                                      size: 18,
                                      color: Color(0xFF9C89B8),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Adicionar lembrete',
                                      style: TextStyle(
                                        color: Color(0xFF333333),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Método para criar os círculos decorativos com diferentes tamanhos e cores
  static Widget _buildDecorativeCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  // Função auxiliar para validação de email
  static bool _isValidEmail(String email) {
    if (email.isEmpty) return false;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Método para construir um item de seleção de horário
  static Widget _buildTimePickerItem({
    required TimeOfDay time,
    required Function() onTap,
    required Function() onDelete,
  }) {
    // Formatar horário para exibição
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.access_time, size: 20, color: Colors.grey),
              const SizedBox(width: 12),
              Text(
                '$hour:$minute $period',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.close, size: 20, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
