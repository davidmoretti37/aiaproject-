import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:calma_flutter/core/theme/app_theme.dart';
import 'package:calma_flutter/presentation/navigation/app_router.dart';
import 'package:calma_flutter/core/services/supabase_service.dart';
import 'package:calma_flutter/core/services/deep_link_service.dart';
import 'package:calma_flutter/core/services/notification_service.dart';
import 'package:calma_flutter/core/di/injection.dart';

/// Ponto de entrada principal do aplicativo C'Alma
/// 
/// Inicializa o aplicativo configurando orientação, tema, e rotas.
/// Estruturado seguindo os princípios de Clean Architecture e SOLID.
void main() async {
  // Garante que o binding do Flutter seja inicializado
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega as variáveis de ambiente
  await dotenv.load(fileName: ".env");
  
  // Inicializa o Supabase
  await SupabaseService.initialize();
  
  // Inicializa o serviço de notificações
  await NotificationService.initialize();
  
  // Configura a injeção de dependência
  setupInjection();

  // Configura a aplicação para funcionar apenas na orientação vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Inicializa o aplicativo com o novo nome
  runApp(const AIAApp());
}

/// AIAApp - Widget raiz do aplicativo AIA
/// 
/// Configura a aplicação com tema escuro e sistema de navegação.
class AIAApp extends StatefulWidget {
  const AIAApp({super.key});

  @override
  State<AIAApp> createState() => _AIAAppState();
}

class _AIAAppState extends State<AIAApp> {
  @override
  void initState() {
    super.initState();
    _initializeDeepLinks();
  }

  /// Inicializa o serviço de deep links
  void _initializeDeepLinks() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DeepLinkService().initialize(AppRouter.router);
    });
  }

  @override
  void dispose() {
    DeepLinkService().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "AIA",
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
    );
  }
}
