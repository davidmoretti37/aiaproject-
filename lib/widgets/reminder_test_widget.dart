import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/chat_service.dart';
import '../services/integrated_auth_service.dart';

class ReminderTestWidget extends StatefulWidget {
  const ReminderTestWidget({Key? key}) : super(key: key);

  @override
  _ReminderTestWidgetState createState() => _ReminderTestWidgetState();
}

class _ReminderTestWidgetState extends State<ReminderTestWidget> {
  final TextEditingController _eventController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  
  bool _isLoading = false;
  String _resultMessage = '';

  @override
  void initState() {
    super.initState();
    _timeController.text = 'em 5 segundos'; // Valor padrão para teste rápido
  }

  Future<void> _createReminder() async {
    final eventName = _eventController.text.trim();
    final timeExpression = _timeController.text.trim();
    
    if (eventName.isEmpty) {
      setState(() {
        _resultMessage = 'Por favor, digite o nome do evento!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _resultMessage = 'Criando lembrete...';
    });

    try {
      // Verificar se usuário está logado
      if (!IntegratedAuthService.isSignedIn()) {
        setState(() {
          _resultMessage = '❌ Você precisa fazer login primeiro!';
          _isLoading = false;
        });
        return;
      }

      final userId = IntegratedAuthService.getUserId();
      print('👤 Usuário logado: $userId');

      final response = await ChatService.createReminder(
        eventName: eventName,
        timeExpression: timeExpression,
      );

      if (response != null) {
        setState(() {
          _resultMessage = response['response'] ?? 'Resposta vazia';
          _isLoading = false;
        });
        
        if (response['success'] == true) {
          _eventController.clear();
          print('✅ Lembrete criado com sucesso!');
        } else {
          print('❌ Falha ao criar lembrete: ${response['response']}');
        }
      } else {
        setState(() {
          _resultMessage = '❌ Erro na comunicação com o servidor';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _resultMessage = '❌ Erro: $e';
        _isLoading = false;
      });
      print('❌ Erro ao criar lembrete: $e');
    }
  }

  Future<void> _listReminders() async {
    setState(() {
      _isLoading = true;
      _resultMessage = 'Buscando lembretes...';
    });

    try {
      final response = await ChatService.listReminders();
      if (response != null) {
        setState(() {
          _resultMessage = response['response'] ?? 'Nenhuma resposta';
          _isLoading = false;
        });
      } else {
        setState(() {
          _resultMessage = '❌ Erro ao buscar lembretes';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _resultMessage = '❌ Erro: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _resultMessage = 'Testando conexão...';
    });

    try {
      final isConnected = await ChatService.testConnection();
      final userInfo = await IntegratedAuthService.getStoredUserInfo();
      
      setState(() {
        _resultMessage = '''
🔗 Conexão Backend: ${isConnected ? '✅ OK' : '❌ Falhou'}
👤 Usuário: ${IntegratedAuthService.isSignedIn() ? '✅ Logado' : '❌ Não logado'}
📧 Email: ${userInfo['email'] ?? 'N/A'}
🆔 Supabase ID: ${userInfo['supabase_user_id'] ?? 'N/A'}
🔑 Google ID: ${userInfo['google_user_id'] ?? 'N/A'}
''';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _resultMessage = '❌ Erro no teste: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Título
          Text(
            '🔔 Teste de Lembretes',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 20),
          
          // Campo do evento
          TextField(
            controller: _eventController,
            style: GoogleFonts.inter(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Nome do Evento',
              labelStyle: GoogleFonts.inter(color: Colors.white70),
              hintText: 'Ex: fazer exercício',
              hintStyle: GoogleFonts.inter(color: Colors.white54),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white30),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white30),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
          ),
          
          const SizedBox(height: 15),
          
          // Campo do tempo
          TextField(
            controller: _timeController,
            style: GoogleFonts.inter(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Quando Lembrar',
              labelStyle: GoogleFonts.inter(color: Colors.white70),
              hintText: 'Ex: em 2 horas, em 30 minutos',
              hintStyle: GoogleFonts.inter(color: Colors.white54),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white30),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.white30),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Botões
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _createReminder,
                  icon: _isLoading 
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(Icons.add_alarm, color: Colors.white),
                  label: Text(
                    'Criar Lembrete',
                    style: GoogleFonts.inter(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 10),
              
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _listReminders,
                  icon: Icon(Icons.list, color: Colors.white),
                  label: Text(
                    'Listar',
                    style: GoogleFonts.inter(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 10),
          
          // Botão de teste de conexão
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _testConnection,
            icon: Icon(Icons.wifi_find, color: Colors.white),
            label: Text(
              'Testar Conexão',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Resultado
          if (_resultMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                _resultMessage,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _eventController.dispose();
    _timeController.dispose();
    super.dispose();
  }
}
