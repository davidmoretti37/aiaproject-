import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// SupabaseService - Serviço para gerenciar a conexão com o Supabase
///
/// Fornece métodos para inicializar o Supabase e acessar o cliente.
class SupabaseService {
  static SupabaseClient? _client;
  static final _authStateChangeController = StreamController<AuthState>.broadcast();
  
  /// Stream para ouvir mudanças no estado de autenticação
  static Stream<AuthState> get authStateChanges => _authStateChangeController.stream;
  
  /// Inicializa o Supabase com as credenciais do arquivo .env
  static Future<void> initialize() async {
    try {
      final url = dotenv.env['SUPABASE_URL'];
      final key = dotenv.env['SUPABASE_ANON_KEY'];
      
      debugPrint("🔧 DEBUG: Inicializando Supabase");
      debugPrint("🔧 DEBUG: URL do Supabase: $url");
      if (key != null && key.isNotEmpty) {
        debugPrint("🔧 DEBUG: Chave anônima: ${key.substring(0, 5)}..."); // Mostra apenas parte da chave por segurança
      }
      
      if (url == null || key == null) {
        debugPrint("❌ ERRO: Credenciais do Supabase não encontradas no arquivo .env");
        debugPrint("❌ ERRO: Verifique se o arquivo .env existe e contém SUPABASE_URL e SUPABASE_ANON_KEY");
        throw Exception("Credenciais do Supabase não encontradas");
      }
      
      await Supabase.initialize(
        url: url,
        anonKey: key,
        debug: kDebugMode,
      );
      
      _client = Supabase.instance.client;
      
      // Configurar listener para mudanças de autenticação
      _client!.auth.onAuthStateChange.listen((data) {
        debugPrint("🔄 DEBUG: Mudança de estado de autenticação: ${data.event}");
        if (data.session != null) {
          debugPrint("🔄 DEBUG: Usuário: ${data.session!.user.id}");
        } else {
          debugPrint("🔄 DEBUG: Nenhuma sessão");
        }
        
        _authStateChangeController.add(
          AuthState(
            event: data.event,
            session: data.session,
          ),
        );
      });
      
      // Verificar sessão existente
      final session = _client!.auth.currentSession;
      if (session != null) {
        debugPrint("✅ DEBUG: Sessão existente encontrada: ${session.user.id}");
        debugPrint("✅ DEBUG: Expira em: ${session.expiresAt}");
      } else {
        debugPrint("⚠️ DEBUG: Nenhuma sessão existente encontrada");
      }
      
      debugPrint("✅ DEBUG: Supabase inicializado com sucesso");
    } catch (e) {
      debugPrint("❌ ERRO: Falha ao inicializar Supabase: $e");
      rethrow;
    }
  }
  
  /// Retorna o cliente Supabase para uso em toda a aplicação
  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase não inicializado. Chame initialize() primeiro.');
    }
    return _client!;
  }
  
  /// Método para limpar recursos ao fechar o app
  static void dispose() {
    _authStateChangeController.close();
  }
}

/// Classe para representar o estado de autenticação
class AuthState {
  final AuthChangeEvent event;
  final Session? session;
  
  AuthState({required this.event, this.session});
}
