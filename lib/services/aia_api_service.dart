import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AIAApiService {
  // URL do backend AIA (atualizada para o novo ngrok)
  static const String _baseUrl = 'https://72f856fa9288.ngrok-free.app';
  
  // Session management para Conversation Buffer
  static String? _currentSessionId;
  static String? get currentSessionId => _currentSessionId;
  
  /// Chama a API AIA para executar tarefas específicas
  static Future<Map<String, dynamic>?> executeTask(String message, {String? userId, String? sessionId}) async {
    try {
      debugPrint('[AIA API] 🚀 Executando tarefa: $message');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/chat'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true', // Skip ngrok warning page
        },
        body: jsonEncode({
          'message': message,
          'user_id': userId ?? 'aiaproject_user',
          if (sessionId != null) 'session_id': sessionId,
          if (_currentSessionId != null) 'session_id': _currentSessionId,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('[AIA API] ✅ Resposta recebida: ${data['message']}');
        debugPrint('[AIA API] 📊 Agent: ${data['agent_id']}, Success: ${data['success']}');
        
        // Manter session_id para Conversation Buffer
        if (data['session_id'] != null) {
          _currentSessionId = data['session_id'];
          debugPrint('[AIA API] 🔗 Session ID mantido: $_currentSessionId');
        }
        
        // Normalizar resposta para compatibilidade
        final normalizedData = {
          'success': data['success'] ?? false,
          'response': data['message'] ?? '',
          'message': data['message'] ?? '', // Compatibilidade com interface atual
          'agent_used': data['agent_id'] ?? 'unknown',
          'session_id': data['session_id'],
          'metadata': data['metadata'],
          'error': data['error'],
          'completed': data['completed'] ?? true, // Assume completo se não especificado
        };
        
        return normalizedData;
      } else {
        debugPrint('[AIA API] ❌ Erro HTTP ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('[AIA API] ❌ Erro ao chamar API: $e');
      return null;
    }
  }
  
  /// Verifica se a API está funcionando
  static Future<bool> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/health'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[AIA API] ❌ Health check falhou: $e');
      return false;
    }
  }
  
  /// Determina se uma mensagem precisa de execução de tarefa
  static bool needsTaskExecution(String message) {
    final lowerMessage = message.toLowerCase();
    
    // Palavras-chave que indicam necessidade de execução de tarefa
    final taskKeywords = [
      // Email/Gmail - PRIORIDADE MÁXIMA
      'email', 'e-mail', 'enviar', 'mandar', 'escrever', 'responder',
      'gmail', 'mensagem', 'carta', 'correio',
      'quero mandar', 'preciso enviar', 'vou mandar', 'vou enviar',
      'mandar para', 'enviar para', 'email para', 'mensagem para',
      
      // Agenda/Calendar
      'reservar', 'agendar', 'marcar', 'reunião', 'compromisso',
      'evento', 'encontro', 'consulta', 'appointment',
      'calendário', 'agenda',
      
      // Transporte
      'pedir', 'solicitar', 'chamar', 'ligar',
      'uber', 'taxi', 'corrida', 'viagem', 'ir para', 'vou para',
      
      // Comida
      'ifood', 'comida', 'pedido', 'delivery',
      'restaurante', 'lanche', 'pizza', 'hambúrguer',
      
      // Ações gerais
      'executar', 'fazer', 'realizar', 'abrir', 'iniciar', 'começar',
      'comprar', 'buscar', 'encontrar', 'procurar',
    ];
    
    // Verificação mais sensível para emails
    if (RegExp(r'\b(email|e-mail|mandar|enviar|gmail|mensagem)\b').hasMatch(lowerMessage)) {
      return true;
    }
    
    return taskKeywords.any((keyword) => lowerMessage.contains(keyword));
  }
  
  /// Detecta o tipo de intent baseado na mensagem
  static String detectIntent(String message) {
    final lowerMessage = message.toLowerCase();
    
    // Calendar/Agenda
    if (RegExp(r'\b(agendar|marcar|reunião|compromisso|evento|encontro|consulta)\b').hasMatch(lowerMessage)) {
      return 'calendar';
    }
    
    // Gmail/Email
    if (RegExp(r'\b(email|enviar|mandar|escrever|responder|gmail|mensagem)\b').hasMatch(lowerMessage)) {
      return 'gmail';
    }
    
    // Transporte
    if (RegExp(r'\b(uber|taxi|corrida|viagem|ir para|vou para)\b').hasMatch(lowerMessage)) {
      return 'transport';
    }
    
    // Comida
    if (RegExp(r'\b(ifood|comida|pedido|delivery|restaurante|lanche|pizza)\b').hasMatch(lowerMessage)) {
      return 'food';
    }
    
    return 'general';
  }
  
  /// Limpa a sessão atual (útil para debug ou reset)
  static void clearSession() {
    _currentSessionId = null;
    debugPrint('[AIA API] 🗑️ Sessão limpa manualmente');
  }
  
  /// Verifica se há uma sessão ativa
  static bool hasActiveSession() {
    return _currentSessionId != null;
  }
  
  /// Obtém informações sobre sessões ativas (debug)
  static Future<Map<String, dynamic>?> getActiveSessions() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/health'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('[AIA API] ❌ Erro ao obter sessões: $e');
      return null;
    }
  }
}
