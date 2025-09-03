import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'clean_app_flow.dart';
import 'services/background_service.dart';
import 'services/simple_auth_service.dart';
import 'services/navigator_service.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Carregar variáveis de ambiente
  await dotenv.load(fileName: ".env");

  // Inicializar Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
  // Inicializar serviço de autenticação simplificado (sem Supabase)
  await SimpleAuthService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIA Experience',
      navigatorKey: NavigatorService.navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const PermissionScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({Key? key}) : super(key: key);

  @override
  _PermissionScreenState createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) {
      await BackgroundService.initialize();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const CleanAppFlow()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permission Request'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final status = await Permission.microphone.request();
            if (status.isGranted) {
              await BackgroundService.initialize();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const CleanAppFlow()),
              );
            }
          },
          child: const Text('Request Microphone Permission'),
        ),
      ),
    );
  }
}
