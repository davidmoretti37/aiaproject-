import 'dart:convert';
import 'package:http/http.dart' as http;
import 'integrated_auth_service.dart';

class ChatService {
  static const String backendUrl = 'http://localhost:8000'; // Ajuste conforme necessário
  
  /// Envia mensagem para o backend com user_id automaticamente
  static Future<Map<String, dynamic>?> sendMessage(String message) async {
    try {
      // Verifica se o usuário está logado
      if (!IntegratedAuthService.isSignedIn()) {
        throw Exception('Usuário não está logado');
      }

      // Pega o user_id automaticamente
      final userId = IntegratedAuthService.getUserId();
      if (userId == null) {
        throw Exception('Não foi possível obter ID do usuário');
      }

      print('📤 Enviando mensagem: "$message"');
      print('👤 User ID: $userId');

      final response = await http.post(
        Uri.parse('$backendUrl/chat'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': message,
          'user_id': userId, // ← Automaticamente incluído!
          'session_id': userId, // Usa user_id como session_id por simplicidade
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        print('✅ Resposta recebida:');
        print('   Agente: ${data['agent_used']}');
        print('   Sucesso: ${data['success']}');
        
        return data;
      } else {
        print('❌ Erro na requisição: ${response.statusCode}');
        print('   Resposta: ${response.body}');
        return null;
      }
      
    } catch (e) {
      print('❌ Erro ao enviar mensagem: $e');
      return null;
    }
  }

  /// Envia mensagem especificamente para lembretes
  static Future<Map<String, dynamic>?> createReminder({
    required String eventName,
    String timeExpression = "em 1 hora",
  }) async {
    final message = 'Me lembre de $eventName $timeExpression';
    return await sendMessage(message);
  }

  /// Lista lembretes do usuário
  static Future<Map<String, dynamic>?> listReminders() async {
    return await sendMessage('Lista meus lembretes ativos');
  }

  /// Cancela um lembrete específico
  static Future<Map<String, dynamic>?> cancelReminder(String reminderId) async {
    return await sendMessage('Cancele o lembrete $reminderId');
  }

  /// Testa conexão com o backend
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(Uri.parse('$backendUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Erro ao testar conexão: $e');
      return false;
    }
  }
}
