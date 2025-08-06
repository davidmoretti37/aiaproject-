import 'dart:convert';
import 'package:http/http.dart' as http;
import 'services/google_auth_service.dart';
import 'services/aia_api_service.dart';

class AIService {
  // Backend simples local (fallback apenas)
  static const String baseUrl = 'http://192.168.3.54:8000';

  
  // Initialize Google Auth Service
  Future<void> initializeAuth() async {
    await GoogleAuthService.initialize();
  }
  
  Future<Map<String, dynamic>> sendMessage(String message, {String? sessionId}) async {
    try {
      // Use provided session ID or generate a default one
      final effectiveSessionId = sessionId ?? 'flutter_user_${DateTime.now().millisecondsSinceEpoch}';
      
      // Get Google access token if user is signed in
      String? accessToken;
      String? userEmail;
      if (GoogleAuthService.isSignedIn()) {
        accessToken = await GoogleAuthService.getAccessToken();
        userEmail = GoogleAuthService.getUserEmail();
      }
      
      print('📤 Analyzing message: $message');
      print('🔑 Session ID: $effectiveSessionId');
      print('👤 User Email: $userEmail');
      
      // 🧠 PRIORIDADE: Sempre tentar backend AIA primeiro
      print('🎯 Trying AIA backend first for: $message');
      
      // Verificar se o backend AIA está disponível
      final aiaHealthy = await AIAApiService.healthCheck();
      if (aiaHealthy) {
        print('✅ AIA Backend is healthy, using advanced AI system');
        
        // Usar o sistema avançado do AIAV3
        final aiaResult = await AIAApiService.executeTask(
          message, 
          userId: userEmail ?? 'aiaproject_user',
          sessionId: effectiveSessionId,
        );
        
        if (aiaResult != null && aiaResult['success'] == true) {
          print('🚀 AIA executed successfully: ${aiaResult['message']}');
          return {
            'message': aiaResult['message'] ?? aiaResult['response'] ?? 'Tarefa executada com sucesso',
            'metadata': aiaResult['metadata'],
            'agent_used': aiaResult['agent_used'] ?? 'aia_advanced',
            'session_id': aiaResult['session_id'] ?? effectiveSessionId,
            'success': true,
            'intent_category': AIAApiService.detectIntent(message),
            'execution_type': 'advanced_aia',
          };
        } else {
          print('⚠️ AIA execution failed, falling back to simple backend');
        }
      } else {
        print('⚠️ AIA Backend not available, falling back to simple backend');
      }
      
      // 🔄 FALLBACK: Usar backend simples original
      print('📤 Sending to simple backend: $baseUrl/chat');
      
      final requestBody = {
        'message': message,
        'session_id': effectiveSessionId,
        'user_id': userEmail ?? 'flutter_user',
      };

      final headers = {
        'Content-Type': 'application/json',
      };

      // Add Google access token to header if available
      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'message': data['response'] ?? data['message'] ?? 'No response received',
          'metadata': data['metadata'] ?? data['data'],
          'agent_used': data['agent_used'] ?? 'simple_backend',
          'session_id': data['session_id'] ?? effectiveSessionId,
          'success': data['success'] ?? true,
          'intent_category': data['intent_category'] ?? 'general',
          'execution_type': 'simple_backend',
        };
      } else {
        return {
          'message': 'Error: ${response.statusCode} - ${response.body}',
          'metadata': null,
          'agent_used': 'error',
          'session_id': effectiveSessionId,
          'success': false,
          'execution_type': 'error',
        };
      }
    } catch (e) {
      print('❌ Send message failed: $e');
      return {
        'message': 'Connection error: $e',
        'metadata': null,
        'agent_used': 'error',
        'session_id': sessionId ?? 'error',
        'success': false,
        'execution_type': 'error',
      };
    }
  }

  // Google Authentication Methods
  Future<bool> signInWithGoogle() async {
    try {
      final account = await GoogleAuthService.signIn();
      return account != null;
    } catch (e) {
      print('❌ Google sign-in failed: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await GoogleAuthService.signOut();
  }

  bool isSignedIn() {
    return GoogleAuthService.isSignedIn();
  }

  String? getUserEmail() {
    return GoogleAuthService.getUserEmail();
  }

  String? getUserDisplayName() {
    return GoogleAuthService.getUserDisplayName();
  }

  Future<String?> getAccessToken() async {
    try {
      return await GoogleAuthService.getAccessToken();
    } catch (e) {
      print('❌ Error getting access token: $e');
      return null;
    }
  }

  static Future<List<String>> getAvailableAgents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/agents'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((agent) => agent['name'] as String).toList();
      } else {
        return ['Error loading agents'];
      }
    } catch (e) {
      return ['Connection error'];
    }
  }

  Future<Map<String, dynamic>> sendConfirmedEmail({
    required String to,
    required String subject,
    required String body,
    String? sessionId,
  }) async {
    try {
      print('📧 Sending confirmed email to: $to');
      
      final requestBody = {
        'to': to,
        'subject': subject,
        'body': body,
        'session_id': sessionId,
      };
      
      // Add Google access token if signed in
      if (GoogleAuthService.isSignedIn()) {
        final accessToken = await GoogleAuthService.getAccessToken();
        if (accessToken != null) {
          requestBody['google_access_token'] = accessToken;
        }
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/send-confirmed-email'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );
      
      print('📧 Email send response: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'message': responseData['message'] ?? 'Email enviado com sucesso!',
        };
      } else {
        return {
          'success': false,
          'message': 'Erro ao enviar email. Código: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error sending confirmed email: $e');
      return {
        'success': false,
        'message': 'Erro de conexão ao enviar email.',
      };
    }
  }

  static Future<bool> checkServerHealth() async {
    // 🎯 PRIORIDADE: Verificar backend AIA avançado primeiro
    print('🔍 Checking AIA advanced backend health...');
    final aiaHealthy = await AIAApiService.healthCheck();
    if (aiaHealthy) {
      print('✅ AIA Backend is healthy and available');
      return true;
    }
    
    // 🔄 FALLBACK: Verificar backend simples local
    try {
      print('🔍 Checking simple backend health at: $baseUrl/health');
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print('✅ Simple backend response: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Simple backend health check failed: $e');
      print('ℹ️ No backends available - app will work with limited functionality');
      return false;
    }
  }
}
