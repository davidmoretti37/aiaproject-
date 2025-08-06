import 'package:calma_flutter/features/onboarding/presentation/components/stats_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:calma_flutter/features/onboarding/presentation/components/audio_wave_visualization.dart';
import 'package:calma_flutter/features/onboarding/presentation/components/diary_card_widget.dart';

/// OnboardingContentType - Tipos de conteúdo das telas de onboarding
enum OnboardingContentType {
  /// Tela informativa simples com texto e possivelmente imagem/ilustração
  info,

  /// Tela de chat que mostra exemplo de conversa com a IA
  chatExample,

  /// Tela de insight que mostra conexões e padrões descobertos
  insight,

  /// Tela de entrada de texto (nome, email, etc)
  textInput,

  /// Tela de seleção de opções (idade, gênero, etc)
  optionSelect,

  /// Tela de configuração (lembretes, etc)
  configuration,
}

/// OnboardingContentModel - Modelo de dados para conteúdo do onboarding
///
/// Define a estrutura e conteúdo de cada tela do fluxo de onboarding
class OnboardingContentModel {
  /// Tipo de conteúdo da tela
  final OnboardingContentType type;

  /// Título principal da tela
  final String? title;

  /// Descrição ou subtítulo da tela
  final String? subtitle;

  /// Placeholder para campos de input
  final String? placeholder;

  /// Número da página no fluxo de onboarding
  final int pageIndex;

  /// Elemento visual (opcional) a ser exibido na tela
  final Widget? visualElement;

  /// Ícone (opcional) para telas de configuração
  final IconData? icon;

  /// Lista de bolhas de chat para o exemplo de conversa
  final List<Map<String, dynamic>>? chatBubbles;

  /// Lista de opções para telas de seleção
  final List<String>? options;

  /// Define se é possível selecionar múltiplas opções
  final bool multiSelect;

  /// Construtor do OnboardingContentModel
  const OnboardingContentModel({
    this.type = OnboardingContentType.info,
    this.title,
    this.subtitle,
    this.placeholder,
    required this.pageIndex,
    this.visualElement,
    this.icon,
    this.chatBubbles,
    this.options,
    this.multiSelect = false,
  });
}

/// Dados completos do onboarding do C'Alma
///
/// Lista com informações de todas as telas do fluxo de onboarding
final List<OnboardingContentModel> onboardingData = [
  // Tela 1: Exemplo de conversa com a IA
  // Atualização do título na tela 1
  OnboardingContentModel(
    type: OnboardingContentType.chatExample,
    title: 'Converse sem medo e sem julgamentos 🤗',
    // O texto do chat vai ser estilizado por partes para destacar partes específicas com cores
    chatBubbles: [
      {
        'text': '', // Vamos renderizar este texto com estilo formatado
        'isUser': true,
        'formattedText': true,
        'segments': [
          {
            'text': 'Hoje, ',
            'color': Colors.black87,
            'weight': FontWeight.normal,
          },
          {
            'text': 'parei por um instante',
            'color': const Color(0xFF2E8B57),
            'weight': FontWeight.w600,
          },
          {'text': ' ⌛', 'color': Colors.black87, 'weight': FontWeight.normal},
          {'text': '.\n', 'color': Colors.black87, 'weight': FontWeight.normal},
          {
            'text': 'Respirei fundo...',
            'color': const Color(0xFF2F80ED),
            'weight': FontWeight.w500,
          },
          {
            'text': ' ☀️\n',
            'color': Colors.black87,
            'weight': FontWeight.normal,
          },
          {
            'text': 'e senti que era o que eu precisava',
            'color': Colors.black87,
            'weight': FontWeight.normal,
          },
          {'text': ' 👍', 'color': Colors.black87, 'weight': FontWeight.normal},
          {'text': '.', 'color': Colors.black87, 'weight': FontWeight.normal},
        ],
      },
    ],
    // Implementação das ondas sonoras no estilo iOS, com visualização suave
    visualElement: Container(
      height: 80, // Altura reduzida para um visual mais elegante
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: const Center(
        child: AudioWaveVisualization(
          // Usando o estilo de barras para simular a visualização nativa iOS
          waveStyle: WaveStyle.bars,
          // Cor azul suave para combinar com o tema
          color: Color(0xFF9AC8FF),
          // Mais barras para uma visualização mais densa e elegante
          barCount: 48,
        ),
      ),
    ),
    pageIndex: 1,
  ),

  // Tela 2: Organizar pensamentos
  OnboardingContentModel(
    type: OnboardingContentType.info,
    title: 'Organize seus pensamentos instantaneamente',
    // Utilizando componente dedicado para o card de diário
    visualElement: const DiaryCardWidget(),
    pageIndex: 2,
  ),

  // Tela 3: Insights com IA
  OnboardingContentModel(
    type: OnboardingContentType.insight,
    title: 'Insights com IA 💡',
    subtitle: 'Descubra padrões e conexões significativas no seu dia a dia',
    visualElement: Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.psychology, size: 60, color: Color(0xFF755BB4)),
          const SizedBox(height: 16),
          const Text(
            'Você se sente mais\nansioso à noite',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Baseado em 14 dias de registro',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    ),
    pageIndex: 3,
  ),

  // Tela 4: Estatísticas e registro diário
  OnboardingContentModel(
    type: OnboardingContentType.info,
    title: 'Fale sobre seus\nsentimentos diariamente',
    visualElement: const StatsCardWidget(),
    pageIndex: 4,
  ),

  // Tela 5: Vamos criar o seu perfil
  OnboardingContentModel(
    type: OnboardingContentType.info,
    title: 'Vamos\ncriar o seu\nperfil',
    // Sem elemento visual específico, apenas círculos decorativos no fundo
    pageIndex: 5,
  ),

  // Tela 6: Como quer que a AIA te chame? (Campo nome)
  OnboardingContentModel(
    type: OnboardingContentType.textInput,
    title: 'Como quer que a AIA te chame?',
    placeholder: 'Escreva o seu nome',
    subtitle: 'Seu nome será usado apenas no aplicativo.',
    pageIndex: 6,
  ),

  // Tela 7: Seleção de gênero
  OnboardingContentModel(
    type: OnboardingContentType.optionSelect,
    title: 'Selecione seu gênero',
    options: ['Masculino', 'Feminino', 'Não binário'],
    pageIndex: 7,
  ),

  // Tela 8: Seleção de idade
  OnboardingContentModel(
    type: OnboardingContentType.optionSelect,
    title: 'Qual é a sua idade?',
    options: ['18-24', '25-34', '35-44', '45-54', '55+'],
    pageIndex: 8,
  ),

  // Tela 9: Como a Aia pode te ajudar
  OnboardingContentModel(
    type: OnboardingContentType.optionSelect,
    title: 'Como a Aia pode te ajudar?',
    options: [
      'Acompanhar a minha vida',
      'Libertar emoções',
      'Melhorar o bem-estar mental',
      'Processar os meus pensamentos',
      'Praticar auto-reflexão',
    ],
    // Permitir múltiplas seleções
    multiSelect: true,
    pageIndex: 9,
  ),

  // Tela 10: Experiência com saúde mental
  OnboardingContentModel(
    type: OnboardingContentType.optionSelect,
    title: 'Qual sua experiência\ncom saúde mental?',
    options: ['Diariamente', 'Já tentei', 'Nunca fiz'],
    pageIndex: 10,
  ),

  // Tela 11: Tudo pronto!
  OnboardingContentModel(
    type: OnboardingContentType.textInput,
    title: 'Suas informações de contato',
    // Não precisamos de placeholder aqui pois teremos múltiplos campos
    // O campo de email será gerenciado no componente
    pageIndex: 11,
    // Flag para indicar que é um formulário de contato
    // Podemos usar o subtitle para instruções adicionais se necessário
    subtitle: 'Preencha seus dados para continuar',
  ),

  // Tela 12: Lembretes diários
  OnboardingContentModel(
    type: OnboardingContentType.configuration,
    title: 'Lembretes Diários',
    subtitle: 'Configure até 3 lembretes diários para conversar com a AIA',
    icon: Icons.alarm,
    pageIndex: 12,
  ),
];
