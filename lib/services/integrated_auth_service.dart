import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/supabase_config.dart';

class IntegratedAuthService {
  static const String _clientId = '1059033516426-hbk4lgpue8qocsha8a36suo1jlgk2lt6.apps.googleusercontent.com';
  
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: _clientId,
    scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/gmail.send',
      'https://www.googleapis.com/auth/calendar',
    ],
  );

  static GoogleSignInAccount? _currentGoogleUser;
  static String? _accessToken;

  /// Inicializa o serviço de autenticação
  static Future<void> initialize() async {
    await SupabaseConfig.initialize();
    
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      _currentGoogleUser = account;
    });

    // Tenta login silencioso
    try {
      await _googleSignIn.signInSilently();
    } catch (error) {
      print('Silent sign-in failed: $error');
    }
  }

  /// Login com Google + Supabase
  static Future<Map<String, dynamic>?> signIn() async {
    try {
      // 1. Faz login com Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      // 2. Pega os tokens do Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      _currentGoogleUser = googleUser;
      _accessToken = googleAuth.accessToken;

      // 3. Autentica no Supabase com o token do Google
      final AuthResponse supabaseResponse = await SupabaseConfig.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      if (supabaseResponse.user != null) {
        // 4. Salva as informações do usuário
        final userInfo = {
          'supabase_user_id': supabaseResponse.user!.id, // ← ID principal para o banco
          'google_user_id': googleUser.id,
          'email': googleUser.email,
          'name': googleUser.displayName ?? '',
          'access_token': _accessToken,
        };

        await _saveUserInfo(userInfo);

        // 5. Cria ou atualiza perfil do usuário na tabela user_profiles
        await _createOrUpdateUserProfile(supabaseResponse.user!.id, googleUser);

        return userInfo;
      }
    } catch (error) {
      print('Sign-in failed: $error');
    }
    return null;
  }

  /// Sair da conta
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await SupabaseConfig.client.auth.signOut();
      _currentGoogleUser = null;
      _accessToken = null;
      await _clearUserInfo();
    } catch (error) {
      print('Sign-out failed: $error');
    }
  }

  /// Pega o USER ID principal (Supabase UUID)
  static String? getUserId() {
    final supabaseUser = SupabaseConfig.client.auth.currentUser;
    return supabaseUser?.id; // ← Este é o ID que vai para o banco de lembretes!
  }

  /// Pega o usuário atual do Supabase
  static User? getCurrentUser() {
    return SupabaseConfig.client.auth.currentUser;
  }

  /// Verifica se está logado
  static bool isSignedIn() {
    return SupabaseConfig.client.auth.currentUser != null;
  }

  /// Pega email do usuário
  static String? getUserEmail() {
    return SupabaseConfig.client.auth.currentUser?.email;
  }

  /// Pega nome do usuário
  static String? getUserName() {
    return SupabaseConfig.client.auth.currentUser?.userMetadata?['full_name'] ?? 
           SupabaseConfig.client.auth.currentUser?.userMetadata?['name'];
  }

  /// Pega token do Google para APIs
  static Future<String?> getGoogleAccessToken() async {
    if (_currentGoogleUser == null) return null;
    
    try {
      final GoogleSignInAuthentication auth = await _currentGoogleUser!.authentication;
      return auth.accessToken;
    } catch (error) {
      print('Failed to get access token: $error');
      return null;
    }
  }

  /// Cria ou atualiza perfil do usuário
  static Future<void> _createOrUpdateUserProfile(String userId, GoogleSignInAccount googleUser) async {
    try {
      await SupabaseConfig.client
          .from('user_profiles')
          .upsert({
            'id': userId,
            'voice_preferences': {},
          });
    } catch (e) {
      print('Erro ao criar/atualizar perfil: $e');
    }
  }

  /// Salva informações do usuário localmente
  static Future<void> _saveUserInfo(Map<String, dynamic> userInfo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('supabase_user_id', userInfo['supabase_user_id']);
    await prefs.setString('google_user_id', userInfo['google_user_id']);
    await prefs.setString('user_email', userInfo['email']);
    await prefs.setString('user_name', userInfo['name']);
    await prefs.setString('google_access_token', userInfo['access_token'] ?? '');
  }

  /// Limpa informações do usuário
  static Future<void> _clearUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('supabase_user_id');
    await prefs.remove('google_user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('google_access_token');
  }

  /// Pega informações salvas do usuário
  static Future<Map<String, String?>> getStoredUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'supabase_user_id': prefs.getString('supabase_user_id'),
      'google_user_id': prefs.getString('google_user_id'),
      'email': prefs.getString('user_email'),
      'name': prefs.getString('user_name'),
      'google_access_token': prefs.getString('google_access_token'),
    };
  }
}
