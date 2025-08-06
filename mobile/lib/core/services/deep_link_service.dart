import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:app_links/app_links.dart';
import 'package:go_router/go_router.dart';

/// DeepLinkService - Serviço para gerenciar deep links
///
/// Gerencia links recebidos pelo app e redireciona para as telas apropriadas.
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  GoRouter? _router;

  /// Inicializa o serviço de deep links
  Future<void> initialize(GoRouter router) async {
    _router = router;
    
    try {
      debugPrint('🔗 DEEP_LINK: Inicializando serviço de deep links');
      
      // Verificar se há um link inicial (app foi aberto através de um link)
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        debugPrint('🔗 DEEP_LINK: Link inicial encontrado: $initialLink');
        await _handleDeepLink(initialLink);
      }
      
      // Ouvir novos links (app já está aberto)
      _linkSubscription = _appLinks.uriLinkStream.listen(
        (Uri uri) {
          debugPrint('🔗 DEEP_LINK: Novo link recebido: $uri');
          _handleDeepLink(uri);
        },
        onError: (err) {
          debugPrint('❌ DEEP_LINK: Erro ao processar link: $err');
        },
      );
      
      debugPrint('✅ DEEP_LINK: Serviço inicializado com sucesso');
    } catch (e) {
      debugPrint('❌ DEEP_LINK: Erro ao inicializar: $e');
    }
  }

  /// Processa um deep link recebido
  Future<void> _handleDeepLink(Uri uri) async {
    try {
      debugPrint('🔗 DEEP_LINK: Processando link: $uri');
      debugPrint('🔗 DEEP_LINK: Scheme: ${uri.scheme}');
      debugPrint('🔗 DEEP_LINK: Host: ${uri.host}');
      debugPrint('🔗 DEEP_LINK: Path: ${uri.path}');
      debugPrint('🔗 DEEP_LINK: Query: ${uri.query}');

      if (_router == null) {
        debugPrint('❌ DEEP_LINK: Router não inicializado');
        return;
      }

      // Aguardar um momento para garantir que o app está pronto
      await Future.delayed(const Duration(milliseconds: 500));

      // Processar diferentes tipos de links
      if (uri.scheme == 'calma') {
        await _handleCustomSchemeLink(uri);
      } else if (uri.scheme == 'https' && uri.host == 'calma-app.vercel.app') {
        await _handleUniversalLink(uri);
      } else {
        debugPrint('⚠️ DEEP_LINK: Esquema de link não reconhecido: ${uri.scheme}');
      }
    } catch (e) {
      debugPrint('❌ DEEP_LINK: Erro ao processar link: $e');
    }
  }

  /// Processa links com esquema customizado (calma://)
  Future<void> _handleCustomSchemeLink(Uri uri) async {
    debugPrint('🔗 DEEP_LINK: Processando link customizado: $uri');

    switch (uri.host) {
      case 'email-confirmed':
        debugPrint('✅ DEEP_LINK: Email confirmado via deep link');
        await _handleEmailConfirmation(uri);
        break;
      
      case 'reset-password':
        debugPrint('🔑 DEEP_LINK: Reset de senha via deep link');
        await _handlePasswordReset(uri);
        break;
      
      case 'invite':
        debugPrint('👥 DEEP_LINK: Convite via deep link');
        await _handleInvite(uri);
        break;
      
      default:
        debugPrint('⚠️ DEEP_LINK: Host não reconhecido: ${uri.host}');
        // Para links de confirmação de email, tentar redirecionar para a tela de confirmação
        if (uri.toString().contains('email') || uri.toString().contains('confirm')) {
          debugPrint('📧 DEEP_LINK: Detectado link de email, redirecionando para confirmação');
          _router!.pushNamed('email-confirmation', queryParameters: {
            'email': '', // Email será detectado automaticamente
            'verified': 'true',
          });
        } else {
          // Redirecionar para home como fallback
          _router!.go('/home');
        }
    }
  }

  /// Processa Universal Links (https://calma-app.vercel.app/...)
  Future<void> _handleUniversalLink(Uri uri) async {
    debugPrint('🔗 DEEP_LINK: Processando Universal Link: $uri');

    switch (uri.path) {
      case '/email-confirmed':
        debugPrint('✅ DEEP_LINK: Email confirmado via Universal Link');
        await _handleEmailConfirmation(uri);
        break;
      
      case '/reset-password':
        debugPrint('🔑 DEEP_LINK: Reset de senha via Universal Link');
        await _handlePasswordReset(uri);
        break;
      
      case '/invite':
        debugPrint('👥 DEEP_LINK: Convite via Universal Link');
        await _handleInvite(uri);
        break;
      
      default:
        debugPrint('⚠️ DEEP_LINK: Path não reconhecido: ${uri.path}');
        // Para links de confirmação de email, tentar redirecionar para a tela de confirmação
        if (uri.toString().contains('email') || uri.toString().contains('confirm')) {
          debugPrint('📧 DEEP_LINK: Detectado link de email, redirecionando para confirmação');
          _router!.pushNamed('email-confirmation', queryParameters: {
            'email': '', // Email será detectado automaticamente
            'verified': 'true',
          });
        } else {
          // Redirecionar para home como fallback
          _router!.go('/home');
        }
    }
  }

  /// Trata confirmação de email
  Future<void> _handleEmailConfirmation(Uri uri) async {
    try {
      debugPrint('📧 DEEP_LINK: Processando confirmação de email');
      
      // Extrair parâmetros do link
      final queryParams = uri.queryParameters;
      final token = queryParams['token'];
      final type = queryParams['type'];
      
      debugPrint('📧 DEEP_LINK: Token: $token');
      debugPrint('📧 DEEP_LINK: Type: $type');

      // Sempre redirecionar para a tela de confirmação de email
      // A tela irá detectar automaticamente se o email foi verificado
      _router!.pushNamed('email-confirmation', queryParameters: {
        'email': '', // Email será detectado automaticamente pelo AuthViewModel
        'verified': 'true', // Indicar que veio de um link de verificação
      });
    } catch (e) {
      debugPrint('❌ DEEP_LINK: Erro ao processar confirmação de email: $e');
      _router!.go('/login');
    }
  }

  /// Trata reset de senha
  Future<void> _handlePasswordReset(Uri uri) async {
    try {
      debugPrint('🔑 DEEP_LINK: Processando reset de senha');
      
      final queryParams = uri.queryParameters;
      final accessToken = queryParams['access_token'];
      final refreshToken = queryParams['refresh_token'];
      final token = queryParams['token']; // Fallback para token simples
      
      debugPrint('🔑 DEEP_LINK: Access Token: ${accessToken?.substring(0, 20)}...');
      debugPrint('🔑 DEEP_LINK: Refresh Token: ${refreshToken?.substring(0, 20)}...');
      debugPrint('🔑 DEEP_LINK: Token: $token');
      
      if (accessToken != null && refreshToken != null) {
        // Navegar para tela de nova senha com tokens do Supabase
        _router!.pushNamed('reset-password', queryParameters: {
          'access_token': accessToken,
          'refresh_token': refreshToken,
        });
      } else if (token != null) {
        // Fallback para token simples
        _router!.pushNamed('reset-password', queryParameters: {
          'token': token,
        });
      } else {
        debugPrint('❌ DEEP_LINK: Nenhum token encontrado');
        _router!.go('/login');
      }
    } catch (e) {
      debugPrint('❌ DEEP_LINK: Erro ao processar reset de senha: $e');
      _router!.go('/login');
    }
  }

  /// Trata convites
  Future<void> _handleInvite(Uri uri) async {
    try {
      debugPrint('👥 DEEP_LINK: Processando convite');
      
      final queryParams = uri.queryParameters;
      final inviteCode = queryParams['code'];
      
      if (inviteCode != null) {
        // Navegar para tela de convite
        _router!.pushNamed('invite', queryParameters: {
          'code': inviteCode,
        });
      } else {
        _router!.go('/');
      }
    } catch (e) {
      debugPrint('❌ DEEP_LINK: Erro ao processar convite: $e');
      _router!.go('/');
    }
  }

  /// Libera recursos
  void dispose() {
    debugPrint('🔗 DEEP_LINK: Liberando recursos');
    _linkSubscription?.cancel();
    _linkSubscription = null;
    _router = null;
  }
}
