import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleAuthService {
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

  static GoogleSignInAccount? _currentUser;
  static String? _accessToken;

  // Initialize the service
  static Future<void> initialize() async {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      _currentUser = account;
      if (account != null) {
        _saveUserInfo(account);
      }
    });

    // Try to sign in silently
    try {
      await _googleSignIn.signInSilently();
    } catch (error) {
      print('Silent sign-in failed: $error');
    }
  }

  // Sign in with Google
  static Future<GoogleSignInAccount?> signIn() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        _currentUser = account;
        // Get access token and store it
        final auth = await account.authentication;
        _accessToken = auth.accessToken;
        await _saveUserInfo(account);
        return account;
      }
    } catch (error) {
      print('Sign-in failed: $error');
    }
    return null;
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
      _accessToken = null;
      await _clearUserInfo();
    } catch (error) {
      print('Sign-out failed: $error');
    }
  }

  // Get access token for API calls
  static Future<String?> getAccessToken() async {
    if (_currentUser == null) return null;
    
    try {
      final GoogleSignInAuthentication auth = await _currentUser!.authentication;
      _accessToken = auth.accessToken;
      return _accessToken;
    } catch (error) {
      print('Failed to get access token: $error');
      return null;
    }
  }

  // Get current user
  static GoogleSignInAccount? getCurrentUser() {
    return _currentUser;
  }

  // Check if user is signed in
  static bool isSignedIn() {
    return _currentUser != null;
  }

  // Get user email
  static String? getUserEmail() {
    return _currentUser?.email;
  }

  // Get user display name
  static String? getUserDisplayName() {
    return _currentUser?.displayName;
  }

  // Save user info to shared preferences
  static Future<void> _saveUserInfo(GoogleSignInAccount account) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', account.email);
    await prefs.setString('user_name', account.displayName ?? '');
    await prefs.setString('user_id', account.id);
  }

  // Clear user info from shared preferences
  static Future<void> _clearUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.remove('user_id');
  }

  // Get stored user info
  static Future<Map<String, String?>> getStoredUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString('user_email'),
      'name': prefs.getString('user_name'),
      'id': prefs.getString('user_id'),
    };
  }
}
