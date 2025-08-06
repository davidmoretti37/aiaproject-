import 'package:flutter/foundation.dart';
import '../../../core/services/supabase_service.dart';

/// Helper para criar dados de teste para a funcionalidade de insights
class TestDataHelper {
  
  /// Cria sessões de exemplo com mood e summary para testar a funcionalidade
  static Future<void> criarDadosDeExemplo() async {
    try {
      debugPrint('🔄 TEST_DATA: Criando dados de exemplo...');
      
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) {
        debugPrint('❌ TEST_DATA: Usuário não autenticado');
        return;
      }

      final now = DateTime.now();
      
      // Lista de sessões de exemplo
      final sessionsExemplo = [
        {
          'user_id': user.id,
          'started_at': now.subtract(const Duration(days: 1)).toIso8601String(),
          'ended_at': now.subtract(const Duration(days: 1, minutes: -15)).toIso8601String(),
          'mood': 'feliz',
          'summary': 'Conversa positiva sobre conquistas pessoais e planos futuros. Você se mostrou motivado e confiante sobre novos projetos.',
          'conversation_data': {
            'session_info': {
              'total_exchanges': 8,
              'user_name': 'Usuário',
              'ai_model': 'gpt-4o-realtime-preview-2024-12-17'
            },
            'conversation': [
              {
                'exchange_id': 1,
                'user_message': 'Estou muito feliz com meu novo projeto no trabalho',
                'ai_response': 'Que ótimo! Conte-me mais sobre esse projeto.'
              }
            ]
          }
        },
        {
          'user_id': user.id,
          'started_at': now.subtract(const Duration(days: 2)).toIso8601String(),
          'ended_at': now.subtract(const Duration(days: 2, minutes: -20)).toIso8601String(),
          'mood': 'ansioso',
          'summary': 'Discussão sobre pressão no trabalho e dificuldades para dormir. Ansiedade sobre prazos e responsabilidades profissionais.',
          'conversation_data': {
            'session_info': {
              'total_exchanges': 12,
              'user_name': 'Usuário',
              'ai_model': 'gpt-4o-realtime-preview-2024-12-17'
            },
            'conversation': [
              {
                'exchange_id': 1,
                'user_message': 'Estou muito ansioso com os prazos do trabalho',
                'ai_response': 'Entendo sua preocupação. Vamos conversar sobre estratégias para lidar com essa ansiedade.'
              }
            ]
          }
        },
        {
          'user_id': user.id,
          'started_at': now.subtract(const Duration(days: 3)).toIso8601String(),
          'ended_at': now.subtract(const Duration(days: 3, minutes: -18)).toIso8601String(),
          'mood': 'triste',
          'summary': 'Conversa sobre sentimentos de tristeza e isolamento. Você mencionou saudade da família e momentos de solidão.',
          'conversation_data': {
            'session_info': {
              'total_exchanges': 10,
              'user_name': 'Usuário',
              'ai_model': 'gpt-4o-realtime-preview-2024-12-17'
            },
            'conversation': [
              {
                'exchange_id': 1,
                'user_message': 'Me sinto muito sozinho ultimamente',
                'ai_response': 'Sinto muito que esteja passando por isso. Quer conversar sobre esses sentimentos?'
              }
            ]
          }
        },
        {
          'user_id': user.id,
          'started_at': now.subtract(const Duration(hours: 6)).toIso8601String(),
          'ended_at': now.subtract(const Duration(hours: 6, minutes: -12)).toIso8601String(),
          'mood': 'neutro',
          'summary': 'Conversa casual sobre rotina diária e planejamento de atividades. Tom neutro e reflexivo sobre o dia a dia.',
          'conversation_data': {
            'session_info': {
              'total_exchanges': 6,
              'user_name': 'Usuário',
              'ai_model': 'gpt-4o-realtime-preview-2024-12-17'
            },
            'conversation': [
              {
                'exchange_id': 1,
                'user_message': 'Como posso organizar melhor minha rotina?',
                'ai_response': 'Vamos pensar em algumas estratégias de organização que podem te ajudar.'
              }
            ]
          }
        },
        {
          'user_id': user.id,
          'started_at': now.subtract(const Duration(days: 4)).toIso8601String(),
          'ended_at': now.subtract(const Duration(days: 4, minutes: -25)).toIso8601String(),
          'mood': 'irritado',
          'summary': 'Discussão sobre frustração com situações do trabalho e conflitos interpessoais. Você expressou irritação com colegas.',
          'conversation_data': {
            'session_info': {
              'total_exchanges': 15,
              'user_name': 'Usuário',
              'ai_model': 'gpt-4o-realtime-preview-2024-12-17'
            },
            'conversation': [
              {
                'exchange_id': 1,
                'user_message': 'Estou muito irritado com meu chefe',
                'ai_response': 'Percebo sua frustração. Que situação específica te deixou assim?'
              }
            ]
          }
        },
        {
          'user_id': user.id,
          'started_at': now.subtract(const Duration(hours: 2)).toIso8601String(),
          'ended_at': now.subtract(const Duration(hours: 2, minutes: -10)).toIso8601String(),
          'mood': 'feliz',
          'summary': 'Conversa animada sobre planos para o fim de semana e atividades prazerosas. Você demonstrou entusiasmo e energia positiva.',
          'conversation_data': {
            'session_info': {
              'total_exchanges': 5,
              'user_name': 'Usuário',
              'ai_model': 'gpt-4o-realtime-preview-2024-12-17'
            },
            'conversation': [
              {
                'exchange_id': 1,
                'user_message': 'Estou animado para o fim de semana!',
                'ai_response': 'Que bom! O que você está planejando fazer?'
              }
            ]
          }
        }
      ];

      // Inserir todas as sessões
      for (final session in sessionsExemplo) {
        await SupabaseService.client
            .from('call_sessions')
            .insert(session);
      }

      debugPrint('✅ TEST_DATA: ${sessionsExemplo.length} sessões de exemplo criadas com sucesso!');
      
    } catch (e) {
      debugPrint('❌ TEST_DATA: Erro ao criar dados de exemplo: $e');
    }
  }

  /// Remove todos os dados de teste do usuário atual
  static Future<void> limparDadosDeExemplo() async {
    try {
      debugPrint('🔄 TEST_DATA: Removendo dados de exemplo...');
      
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) {
        debugPrint('❌ TEST_DATA: Usuário não autenticado');
        return;
      }

      await SupabaseService.client
          .from('call_sessions')
          .delete()
          .eq('user_id', user.id);

      debugPrint('✅ TEST_DATA: Dados de exemplo removidos com sucesso!');
      
    } catch (e) {
      debugPrint('❌ TEST_DATA: Erro ao remover dados de exemplo: $e');
    }
  }

  /// Verifica se existem dados de teste
  static Future<bool> temDadosDeExemplo() async {
    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) return false;

      final response = await SupabaseService.client
          .from('call_sessions')
          .select('id')
          .eq('user_id', user.id)
          .limit(1);

      return (response as List).isNotEmpty;
    } catch (e) {
      debugPrint('❌ TEST_DATA: Erro ao verificar dados: $e');
      return false;
    }
  }
}
