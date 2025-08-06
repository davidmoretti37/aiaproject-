import 'package:http/http.dart' as http;
import 'dart:convert';
import 'google_auth_service.dart';

class AIService {
  final String _baseUrl = 'http://localhost:8000';

  Future<String> getResponse(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['response'];
      } else {
        return 'Error: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  // Google Authentication Methods
  final GoogleAuthService _authService = GoogleAuthService();

  Future<bool> signInWithGoogle() async {
    try {
      final account = await _authService.signInWithGoogle();
      return account != null;
    } catch (e) {
      print('❌ Google sign-in failed: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  // These methods are not available in the GoogleAuthService, so I will comment them out for now.
  // bool isSignedIn() {
  //   return _authService.isSignedIn();
  // }

  // String? getUserEmail() {
  //   return _authService.getUserEmail();
  // }

  // String? getUserDisplayName() {
  //   return _authService.getUserDisplayName();
  // }

  // Future<String?> getAccessToken() async {
  //   try {
  //     return await _authService.getAccessToken();
  //   } catch (e) {
  //     print('❌ Error getting access token: $e');
  //     return null;
  //   }
  // }
}
