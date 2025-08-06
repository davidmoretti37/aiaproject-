import 'package:flutter/material.dart';
import 'package:calma_flutter/core/constants/app_colors.dart';
import 'package:calma_flutter/core/constants/app_text_styles.dart';

class PolicyScreen extends StatelessWidget {
  const PolicyScreen({super.key});

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

              // Conteúdo principal em uma lista rolável, incluindo título e data
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título principal
                      Text(
                        'Política de Privacidade',
                        style: AppTextStyles.heading3,
                      ),

                      const SizedBox(height: 8),

                      // Data de atualização
                      Text(
                        'Última atualização: 13 de Abril de 2025',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.gray500,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 1. Informações Coletadas
                      Text(
                        '1. Informações Coletadas',
                        style: AppTextStyles.heading4,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Coletamos informações pessoais que você fornece diretamente, como nome, endereço de e-mail, e entradas de diário. Também coletamos informações sobre como você usa o aplicativo.',
                        style: AppTextStyles.bodySmall,
                      ),

                      const SizedBox(height: 16),

                      // 2. Uso das Informações
                      Text(
                        '2. Uso das Informações',
                        style: AppTextStyles.heading4,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Usamos suas informações para fornecer e melhorar nossos serviços, personalizar sua experiência, e desenvolver novos recursos. Suas entradas de diário são usadas para treinar nossa IA para fornecer respostas mais relevantes.',
                        style: AppTextStyles.bodySmall,
                      ),

                      const SizedBox(height: 16),

                      // 3. Compartilhamento de Informações
                      Text(
                        '3. Compartilhamento de Informações',
                        style: AppTextStyles.heading4,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Não vendemos ou alugamos suas informações pessoais a terceiros. Podemos compartilhar informações com prestadores de serviços que nos ajudam a operar o aplicativo.',
                        style: AppTextStyles.bodySmall,
                      ),

                      const SizedBox(height: 16),

                      // 4. Segurança
                      Text('4. Segurança', style: AppTextStyles.heading4),
                      const SizedBox(height: 8),
                      Text(
                        'Implementamos medidas de segurança para proteger suas informações contra acesso não autorizado ou alteração. No entanto, nenhum método de transmissão pela Internet é 100% seguro.',
                        style: AppTextStyles.bodySmall,
                      ),

                      const SizedBox(height: 16),

                      // 5. Seus Direitos
                      Text('5. Seus Direitos', style: AppTextStyles.heading4),
                      const SizedBox(height: 8),
                      Text(
                        'Você tem direito de acessar, corrigir ou excluir suas informações pessoais. Para exercer esses direitos, entre em contato conosco.',
                        style: AppTextStyles.bodySmall,
                      ),

                      const SizedBox(height: 16),

                      // 6. Alterações na Política
                      Text(
                        '6. Alterações na Política',
                        style: AppTextStyles.heading4,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Podemos atualizar nossa Política de Privacidade periodicamente. Notificaremos você sobre quaisquer alterações publicando a nova política no aplicativo.',
                        style: AppTextStyles.bodySmall,
                      ),

                      const SizedBox(height: 16),

                      // 7. Contato
                      Text('7. Contato', style: AppTextStyles.heading4),
                      const SizedBox(height: 8),
                      Text(
                        'Para dúvidas sobre esta Política de Privacidade, entre em contato conosco pelo email: privacidade@calma-app.com',
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
