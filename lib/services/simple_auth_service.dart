import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SimpleAuthService {
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

  /// Login com Google via Supabase OAuth
  static Future<Map<String, dynamic>?> signIn() async {
    try {
      print('🔑 Iniciando autenticação Google via Supabase...');
      
      // 1. Faz login com Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('❌ Login com Google cancelado pelo usuário');
        return null;
      }

      print('✅ Login Google realizado: ${googleUser.email}');

      // 2. Pega os tokens do Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      _currentGoogleUser = googleUser;
      _accessToken = googleAuth.accessToken;

      print('🔑 Tokens obtidos com sucesso');

      // 3. Autentica no Supabase com o token do Google
      try {
        final AuthResponse supabaseResponse = await Supabase.instance.client.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: googleAuth.idToken!,
          accessToken: googleAuth.accessToken!,
        );

        final supabaseUser = supabaseResponse.user;
        if (supabaseUser != null) {
          print('✅ Login Supabase realizado: ${supabaseUser.id}');
          
          // 4. Cria informações do usuário com UUID real do Supabase
          final userInfo = {
            'user_id': supabaseUser.id, // UUID real do Supabase
            'supabase_id': supabaseUser.id,
            'google_user_id': googleUser.id,
            'email': supabaseUser.email ?? googleUser.email,
            'name': supabaseUser.userMetadata?['full_name'] ?? googleUser.displayName ?? '',
            'access_token': _accessToken,
            'auth_provider': 'supabase_google',
          };

          await _saveUserInfo(userInfo);
          print('✅ Login completo realizado com sucesso!');
          print('   UUID Supabase: ${supabaseUser.id}');
          print('   Google ID: ${googleUser.id}');
          
          return userInfo;
        } else {
          print('❌ Falha na autenticação Supabase');
        }
      } catch (supabaseError) {
        print('❌ Erro no login Supabase: $supabaseError');
        
        // Fallback: usar apenas o Google (como antes)
        print('⚠️ Usando fallback: Google apenas');
        final userInfo = {
          'user_id': googleUser.id, // Fallback para Google ID
          'google_user_id': googleUser.id,
          'email': googleUser.email,
          'name': googleUser.displayName ?? '',
          'access_token': _accessToken,
          'auth_provider': 'google_only',
        };

        await _saveUserInfo(userInfo);
        return userInfo;
      }
      
    } catch (error) {
      print('❌ Erro na autenticação Google: $error');
    }
    return null;
  }

  /// Sair da conta
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _currentGoogleUser = null;
      _accessToken = null;
      await _clearUserInfo();
      print('✅ Logout realizado com sucesso');
    } catch (error) {
      print('❌ Erro no logout: $error');
    }
  }

  /// Verifica se está logado
  static bool isSignedIn() {
    return _currentGoogleUser != null;
  }

  /// Pega email do usuário
  static String? getUserEmail() {
    return _currentGoogleUser?.email;
  }

  /// Pega nome do usuário
  static String? getUserName() {
    return _currentGoogleUser?.displayName;
  }

  /// Pega ID do usuário
  static String? getUserId() {
    return _currentGoogleUser?.id;
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

  /// Salva informações do usuário localmente
  static Future<void> _saveUserInfo(Map<String, dynamic> userInfo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userInfo['user_id']);
    await prefs.setString('supabase_id', userInfo['supabase_id'] ?? userInfo['user_id']);
    await prefs.setString('google_user_id', userInfo['google_user_id']);
    await prefs.setString('user_email', userInfo['email']);
    await prefs.setString('user_name', userInfo['name']);
    await prefs.setString('google_access_token', userInfo['access_token'] ?? '');
    await prefs.setString('auth_provider', userInfo['auth_provider']);
  }

  /// Limpa informações do usuário
  static Future<void> _clearUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('supabase_id');
    await prefs.remove('google_user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('google_access_token');
    await prefs.remove('auth_provider');
  }

  /// Pega informações salvas do usuário
  static Future<Map<String, String?>> getStoredUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'user_id': prefs.getString('user_id'),
      'supabase_id': prefs.getString('supabase_id'),
      'google_user_id': prefs.getString('google_user_id'),
      'email': prefs.getString('user_email'),
      'name': prefs.getString('user_name'),
      'google_access_token': prefs.getString('google_access_token'),
      'auth_provider': prefs.getString('auth_provider'),
    };
  }

  /// Verifica se tem sessão salva
  static Future<bool> hasStoredSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id') != null;
  }

  /// Restaura sessão do usuário
  static Future<bool> restoreSession() async {
    try {
      // Tenta login silencioso no Google
      await _googleSignIn.signInSilently();
      
      // Verifica se tem informações salvas
      final hasStored = await hasStoredSession();
      
      return _currentGoogleUser != null && hasStored;
    } catch (error) {
      print('❌ Erro ao restaurar sessão: $error');
      return false;
    }
  }
}
