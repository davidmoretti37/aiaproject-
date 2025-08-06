import 'package:flutter/material.dart';
import 'package:calma_flutter/core/di/injection.dart';
import 'package:calma_flutter/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:calma_flutter/features/help/presentation/components/faq_item.dart';
import 'package:calma_flutter/features/help/presentation/components/support_contact_card.dart';

/// HelpSupportScreen - Tela de ajuda e suporte
///
/// Fornece informações de ajuda, perguntas frequentes e opções de contato.
class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final AuthViewModel _authViewModel;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _authViewModel = getIt<AuthViewModel>();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Ajuda e Suporte',
          style: TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF9C89B8),
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: const Color(0xFF9C89B8),
          dividerColor: Colors.transparent, // Remove a linha divisória
          tabs: const [
            Tab(text: 'Perguntas Frequentes'),
            Tab(text: 'Sobre a AIA'),
            Tab(text: 'Contato'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFAQTab(),
          _buildAboutAIATab(),
          _buildContactTab(),
        ],
      ),
    );
  }

  Widget _buildFAQTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Texto introdutório
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF5F0FF),
                ),
                child: const Icon(
                  Icons.question_answer,
                  size: 40,
                  color: Color(0xFF9C89B8),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Perguntas Frequentes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Aqui você encontra respostas para as dúvidas mais comuns sobre o C\'Alma e a AIA. Se não encontrar o que procura, entre em contato com nosso suporte na aba "Contato".',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Título da seção
        const Text(
          'Dúvidas Comuns',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 12),
        
        // FAQs
        const FAQItem(
          question: 'Como funciona a AIA?',
          answer: 'A AIA é uma ferramenta de conversação por voz que utiliza tecnologia avançada para ajudar no seu bem-estar mental. Basta falar com ela como você falaria com um amigo, e ela responderá de forma empática e útil.',
          initiallyExpanded: true,
        ),
        const FAQItem(
          question: 'Como configurar lembretes diários?',
          answer: 'Para configurar lembretes diários, acesse a seção "Lembretes" no menu de perfil. Lá você pode adicionar novos lembretes, escolhendo o horário que deseja ser notificado. Os lembretes funcionam mesmo quando o aplicativo está fechado.',
        ),
        const FAQItem(
          question: 'Minhas conversas são privadas?',
          answer: 'Sim, suas conversas são privadas e seguras. Utilizamos criptografia de ponta a ponta e seguimos rigorosos padrões de segurança. Você pode ver o histórico de suas conversas na seção "Insights", mas apenas você tem acesso a esse conteúdo, mas caso se conecte com um Psicólogo, ele também terá acesso aos seus insights.',
        ),
        const FAQItem(
          question: 'Posso usar o app sem internet?',
          answer: 'Algumas funcionalidades como lembretes funcionam sem internet, mas para conversar com a AIA é necessário estar conectado. Trabalhamos para melhorar a experiência offline em atualizações futuras.',
        ),
        const FAQItem(
          question: 'Como editar meu perfil?',
          answer: 'Para editar seu perfil, acesse a tela de Perfil e toque no botão "Editar" próximo à sua foto. Lá você pode atualizar sua foto, nome preferido e outras informações pessoais.',
        ),
        const FAQItem(
          question: 'O que são os insights?',
          answer: 'Insights são resumos e análises das suas conversas com a AIA. Eles ajudam você a acompanhar seu progresso e identificar padrões em seus pensamentos e emoções ao longo do tempo.',
        ),
      ],
    );
  }

  Widget _buildAboutAIATab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF5F0FF),
                  ),
                  child: const Icon(
                    Icons.psychology,
                    size: 40,
                    color: Color(0xFF9C89B8),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'O que é a AIA?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'A AIA (Assistente de Inteligência Artificial) é uma companheira digital projetada para ajudar no seu bem-estar mental e emocional. Utilizando tecnologia avançada de processamento de linguagem natural, a AIA pode conversar com você, ouvir suas preocupações e oferecer suporte empático.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Recursos da AIA',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            icon: Icons.chat_bubble_outline,
            title: 'Conversação Natural',
            description: 'Converse com a AIA como falaria com um amigo, usando sua voz natural.',
          ),
          _buildFeatureItem(
            icon: Icons.psychology_outlined,
            title: 'Suporte Empático',
            description: 'Receba respostas empáticas e compreensivas para suas preocupações.',
          ),
          _buildFeatureItem(
            icon: Icons.insights_outlined,
            title: 'Insights Personalizados',
            description: 'Obtenha insights sobre seus padrões de pensamento e emoções.',
          ),
          _buildFeatureItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacidade Garantida',
            description: 'Suas conversas são privadas e protegidas com criptografia.',
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F0FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF9C89B8).withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Importante',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9C89B8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'A AIA não substitui o atendimento profissional de saúde mental. Se você estiver enfrentando problemas graves, busque ajuda de um profissional qualificado.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Como podemos ajudar?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Escolha uma das opções abaixo para entrar em contato com nossa equipe de suporte.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        SupportContactCard(
          title: 'Email de Suporte',
          description: 'Resposta em até 24 horas',
          icon: Icons.email_outlined,
          url: 'mailto:suporte@calma-app.com',
        ),
        SupportContactCard(
          title: 'Chat ao Vivo',
          description: 'Disponível em dias úteis (9h-18h)',
          icon: Icons.chat_outlined,
          onTap: () {
            _showComingSoon(context, 'Chat ao Vivo');
          },
        ),
        SupportContactCard(
          title: 'Central de Ajuda',
          description: 'Artigos e tutoriais detalhados',
          icon: Icons.help_outline,
          onTap: () {
            _showComingSoon(context, 'Central de Ajuda');
          },
        ),
        SupportContactCard(
          title: 'Redes Sociais',
          description: 'Siga-nos para novidades',
          icon: Icons.public,
          url: 'https://instagram.com/calma-app',
        ),
        SupportContactCard(
          title: 'Excluir Conta',
          description: 'Remover permanentemente sua conta e dados',
          icon: Icons.delete_outline,
          iconColor: Colors.red[400] ?? Colors.red,
          backgroundColor: Colors.red[50] ?? const Color(0xFFFFEBEE),
          url: _buildDeleteAccountUrl(),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Horário de Atendimento',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 12),
              _buildScheduleRow('Segunda a Sexta', '9h às 18h'),
              const SizedBox(height: 8),
              _buildScheduleRow('Sábado', '9h às 13h'),
              const SizedBox(height: 8),
              _buildScheduleRow('Domingo e Feriados', 'Fechado'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF9C89B8).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF9C89B8),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleRow(String day, String hours) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          day,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        Text(
          hours,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature em breve!'),
        backgroundColor: const Color(0xFF9C89B8),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  String _buildDeleteAccountUrl() {
    final user = _authViewModel.currentUser;
    if (user == null) {
      return 'https://calma.inventu.ai/suporte';
    }
    
    // Codificar o ID para garantir que caracteres especiais sejam tratados corretamente
    final encodedId = Uri.encodeComponent(user.id);
    
    // Construir a URL com o parâmetro user_id
    return 'https://calma.inventu.ai/suporte?user_id=${encodedId}';
  }
}
