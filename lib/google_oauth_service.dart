import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleOAuthService {
  static const String baseUrl = 'http://192.168.3.54:8000';
  static const String _sessionKey = 'google_oauth_session';
  static const String _authStatusKey = 'google_auth_status';
  
  String? _sessionId;
  bool _isAuthenticated = false;
  
  // Singleton pattern
  static final GoogleOAuthService _instance = GoogleOAuthService._internal();
  factory GoogleOAuthService() => _instance;
  GoogleOAuthService._internal();
  
  bool get isAuthenticated => _isAuthenticated;
  String? get sessionId => _sessionId;
  
  /// Initialize the service and check existing authentication
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _sessionId = prefs.getString(_sessionKey);
    
    if (_sessionId != null) {
      // Check if the stored session is still valid
      await _checkAuthStatus();
    }
    
    // Generate new session ID if none exists
    if (_sessionId == null) {
      _sessionId = 'flutter_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(_sessionKey, _sessionId!);
    }
  }
  
  /// Check authentication status with backend
  Future<bool> _checkAuthStatus() async {
    if (_sessionId == null) return false;
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/status/$_sessionId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _isAuthenticated = data['authenticated'] ?? false;
        
        // Save auth status
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_authStatusKey, _isAuthenticated);
        
        return _isAuthenticated;
      }
    } catch (e) {
      print('Error checking auth status: $e');
    }
    
    return false;
  }
  
  /// Start Google OAuth flow
  Future<String?> startOAuthFlow() async {
    if (_sessionId == null) {
      await initialize();
    }
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/google?session_id=$_sessionId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['auth_url'];
      } else {
        final errorData = json.decode(response.body);
        throw Exception('OAuth setup error: ${errorData['detail'] ?? response.body}');
      }
    } catch (e) {
      print('Error starting OAuth flow: $e');
      return null;
    }
  }
  
  /// Launch OAuth URL in browser
  Future<bool> launchOAuthUrl(String authUrl) async {
    try {
      final uri = Uri.parse(authUrl);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }
      return false;
    } catch (e) {
      print('Error launching OAuth URL: $e');
      return false;
    }
  }
  
  /// Complete OAuth flow (call this after user returns from browser)
  Future<bool> completeOAuthFlow() async {
    // Poll for authentication status
    for (int i = 0; i < 30; i++) {
      await Future.delayed(const Duration(seconds: 2));
      
      if (await _checkAuthStatus()) {
        return true;
      }
    }
    
    return false;
  }
  
  /// Sign out and revoke access
  Future<bool> signOut() async {
    if (_sessionId == null) return true;
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/revoke/$_sessionId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        _isAuthenticated = false;
        
        // Clear stored data
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_authStatusKey);
        
        return true;
      }
    } catch (e) {
      print('Error signing out: $e');
    }
    
    return false;
  }
  
  /// Get user info if authenticated
  Future<Map<String, dynamic>?> getUserInfo() async {
    if (!_isAuthenticated || _sessionId == null) return null;
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/status/$_sessionId'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['user_info'];
      }
    } catch (e) {
      print('Error getting user info: $e');
    }
    
    return null;
  }
  
  /// Check if user needs to authenticate for Gmail/Calendar features
  bool needsAuthentication() {
    return !_isAuthenticated;
  }
  
  /// Show authentication dialog
  static Future<bool> showAuthDialog(BuildContext context) async {
    final service = GoogleOAuthService();
    
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Conectar com Google'),
          content: const Text(
            'Para usar recursos do Gmail e Calendar, você precisa conectar sua conta Google.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(true);
                await _handleAuthentication(context);
              },
              child: const Text('Conectar'),
            ),
          ],
        );
      },
    ) ?? false;
  }
  
  /// Handle the authentication process
  static Future<void> _handleAuthentication(BuildContext context) async {
    final service = GoogleOAuthService();
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Iniciando autenticação...'),
          ],
        ),
      ),
    );
    
    try {
      // Get auth URL
      final authUrl = await service.startOAuthFlow();
      
      if (authUrl != null) {
        // Close loading dialog
        Navigator.of(context).pop();
        
        // Show instruction dialog
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Autenticação Google'),
            content: const Text(
              'Você será redirecionado para o navegador para fazer login com sua conta Google. Após autorizar o acesso, volte para o app.',
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  
                  // Launch browser
                  await service.launchOAuthUrl(authUrl);
                  
                  // Show waiting dialog
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 20),
                          const Text('Aguardando autenticação...'),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancelar'),
                          ),
                        ],
                      ),
                    ),
                  );
                  
                  // Wait for authentication
                  final success = await service.completeOAuthFlow();
                  
                  // Close waiting dialog
                  Navigator.of(context).pop();
                  
                  // Show result
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success 
                          ? '✅ Conectado com sucesso!' 
                          : '❌ Falha na autenticação',
                      ),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                },
                child: const Text('Abrir Navegador'),
              ),
            ],
          ),
        );
      } else {
        // Close loading dialog
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Erro ao iniciar autenticação'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
