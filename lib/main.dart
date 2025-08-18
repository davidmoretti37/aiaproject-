import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'clean_app_flow.dart';
import 'services/simple_auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Carregar variáveis de ambiente
  await dotenv.load(fileName: ".env");
  
  // Inicializar serviço de autenticação simplificado (sem Supabase)
  await SimpleAuthService.initialize();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIA Experience',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CleanAppFlow(), // Back to normal app flow: intro -> sign-in -> orb -> chat
      debugShowCheckedModeBanner: false,
    );
  }
}
