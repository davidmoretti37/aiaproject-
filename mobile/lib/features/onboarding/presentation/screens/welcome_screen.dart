import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:calma_flutter/core/constants/app_colors.dart';
import 'package:calma_flutter/core/constants/app_text_styles.dart';
import 'package:calma_flutter/presentation/common_widgets/floating_element.dart';
import 'package:calma_flutter/presentation/common_widgets/primary_button.dart';
import 'package:calma_flutter/presentation/common_widgets/text_button_custom.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// WelcomeScreen - Tela inicial de boas-vindas do aplicativo C'Alma
///
/// Primeira tela exibida ao usuário, apresentando a identidade visual do app
/// e os botões principais para login ou início do processo de onboarding.
class WelcomeScreen extends StatelessWidget {
  /// Callback para navegação para a tela de onboarding
  final VoidCallback onGetStarted;

  /// Callback para navegação para a tela de login
  final VoidCallback onLogin;

  /// Callback para navegação para os termos de uso
  final VoidCallback onTerms;

  /// Callback para navegação para a política de privacidade
  final VoidCallback onPrivacy;

  /// Construtor da WelcomeScreen
  const WelcomeScreen({
    super.key,
    required this.onGetStarted,
    required this.onLogin,
    required this.onTerms,
    required this.onPrivacy,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
              // Elemento decorativo: Blob (bolha) suave
              _buildBlob(),

              // Borda simples
              _buildBorder(),

              // Conteúdo principal
              _buildMainContent(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói o elemento decorativo de fundo (blob)
  Widget _buildBlob() {
    return Positioned(
      top: 130,
      left: 0,
      right: 0,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.calmaBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(100),
              ),
            ).animate().blurXY(
              duration: const Duration(milliseconds: 600),
              end: 20,
            ),
            Positioned(
              top: 20,
              left: 40,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.calmaBlueDark.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
              ).animate().blurXY(
                duration: const Duration(milliseconds: 600),
                end: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói a borda decorativa da tela
  Widget _buildBorder() {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.calmaBlueDark.withOpacity(0.2),
              width: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  /// Constrói o conteúdo principal da tela
  Widget _buildMainContent(BuildContext context) {
    return Column(
      children: [
        // Logo e texto de boas-vindas (seção superior)
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Logo animado com efeito de flutuação
                FloatingElement(
                  verticalAmplitude: 8,
                  horizontalAmplitude: 4,
                  speed: 0.5,
                  child: Image.asset(
                    'assets/images/1439e60e-ac6d-4e93-be25-3689d9d0bfe2.png',
                    width: 200,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback caso a imagem não esteja disponível
                      return Container(
                        width: 200,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.calmaBlue.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "C'Alma",
                          style: AppTextStyles.heading1.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Texto de boas-vindas
                Text(
                  "Respire... Você chegou.",
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.gray700,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().fadeIn(
                  duration: const Duration(milliseconds: 800),
                  delay: const Duration(milliseconds: 400),
                ),
              ],
            ),
          ),
        ),

        // Botões e avisos legais (seção inferior)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
          child: Column(
            children: [
              // Texto "Impulsionado por AI"
              Text(
                "Impulsionado por AI",
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.gray600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

              // Botão principal "Começar"
              PrimaryButton(
                text: "Começar",
                onPressed: onGetStarted,
                backgroundColor: Colors.white.withOpacity(0.2),
                textColor: AppColors.gray700,
                height: 52,
                borderRadius: 50,
                width: double.infinity,
              ),
              const SizedBox(height: 16),

              // Botão de texto "Já tenho uma conta"
              TextButtonCustom(
                text: "Já tenho uma conta",
                onPressed: onLogin,
                textColor: AppColors.gray700,
                textStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.gray700,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 6),
              
              // Botão de texto "Sou psicólogo"
              TextButtonCustom(
                text: "Sou Psicólogo",
                onPressed: () async {
                  final Uri url = Uri.parse('https://calma.inventu.ai/');
                  if (!await launchUrl(url)) {
                    debugPrint('Não foi possível abrir o link: $url');
                  }
                },
                textColor: AppColors.gray700,
                textStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.gray700,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 32),

              // Texto de termos e política
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.gray600.withOpacity(0.9),
                    ),
                    children: [
                      const TextSpan(
                        text: 'Ao continuar, você concorda com nossos ',
                      ),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: onTerms,
                          child: Text(
                            'Termos de Uso',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.gray700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      const TextSpan(text: ' e '),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: onPrivacy,
                          child: Text(
                            'Política de Privacidade',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.gray700,
                              decoration: TextDecoration.underline,
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
        ),
      ],
    );
  }
}
