import 'package:flutter/material.dart';
import 'package:calma_flutter/core/constants/app_colors.dart';
import 'package:calma_flutter/core/constants/app_text_styles.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Botão voltar com estilo visto na imagem
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.arrow_back, color: Colors.black54,),
              ),

              const SizedBox(height: 12),

              // Conteúdo principal em uma lista rolável
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Termos de Uso', style: AppTextStyles.heading3),

                      const SizedBox(height: 8),

                      // Data de atualização
                      Text(
                        'Última atualização: 13 de Abril de 2025',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.gray500,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 1. Aceitação dos Termos
                      Text(
                        '1. Aceitação dos Termos',
                        style: AppTextStyles.heading4,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ao acessar ou usar o aplicativo C\'Alma, você concorda em cumprir e estar vinculado a estes Termos de Uso. Se você não concordar com qualquer parte destes termos, não poderá acessar o serviço.',
                        style: AppTextStyles.bodySmall,
                      ),

                      const SizedBox(height: 16),

                      // 2. Descrição do Serviço
                      Text(
                        '2. Descrição do Serviço',
                        style: AppTextStyles.heading4,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'C\'Alma é um aplicativo de saúde mental que utiliza inteligência artificial para fornecer suporte e orientação para o bem-estar emocional dos usuários. O aplicativo não substitui aconselhamento médico ou psicológico profissional.',
                        style: AppTextStyles.bodySmall,
                      ),

                      const SizedBox(height: 16),

                      // 3. Privacidade
                      Text('3. Privacidade', style: AppTextStyles.heading4),
                      const SizedBox(height: 8),
                      Text(
                        'O uso do C\'Alma está sujeito à nossa Política de Privacidade, que descreve como coletamos, usamos e compartilhamos suas informações.',
                        style: AppTextStyles.bodySmall,
                      ),

                      const SizedBox(height: 16),

                      // 4. Contas de Usuário
                      Text(
                        '4. Contas de Usuário',
                        style: AppTextStyles.heading4,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Para usar certos recursos do aplicativo, você pode precisar criar uma conta. Você é responsável por manter a confidencialidade de sua senha e por todas as atividades que ocorrem sob sua conta.',
                        style: AppTextStyles.bodySmall,
                      ),

                      const SizedBox(height: 16),

                      // 5. Uso Aceitável
                      Text('5. Uso Aceitável', style: AppTextStyles.heading4),
                      const SizedBox(height: 8),
                      Text(
                        'Você concorda em usar o C\'Alma apenas para fins legais e de maneira que não viole os direitos de qualquer terceiro.',
                        style: AppTextStyles.bodySmall,
                      ),

                      const SizedBox(height: 16),

                      // 6. Alterações nos Termos
                      Text(
                        '6. Alterações nos Termos',
                        style: AppTextStyles.heading4,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Reservamo-nos o direito de modificar estes termos a qualquer momento. É sua responsabilidade verificar alterações periodicamente.',
                        style: AppTextStyles.bodySmall,
                      ),

                      const SizedBox(height: 16),

                      // 7. Contato
                      Text('7. Contato', style: AppTextStyles.heading4),
                      const SizedBox(height: 8),
                      Text(
                        'Para dúvidas sobre estes Termos de Uso, entre em contato conosco pelo email: contato@calma-app.com',
                        style: AppTextStyles.bodySmall,
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
