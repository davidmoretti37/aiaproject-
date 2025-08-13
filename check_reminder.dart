import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Inicializar Supabase
  await Supabase.initialize(
    url: 'https://xkkxylouvyjdymnpxzld.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhra3h5bG91dnlqZHltbnB4emxkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE0Njg3MDEsImV4cCI6MjA2NzA0NDcwMX0.c5SRJPpm9VzEHh0PeNqVRamYn5BfGOtgbg9F36d2ew8',
  );

  final client = Supabase.instance.client;
  
  try {
    // Buscar lembretes do usuário específico
    final userId = 'fafbfa82-2fde-443a-b8d9-c9bfd5eb6005';
    
    print('🔍 Buscando lembretes para o usuário: $userId');
    
    // Verificar se a tabela reminders existe e buscar os dados
    final response = await client
        .from('reminders')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(10);
    
    print('📋 Lembretes encontrados: ${response.length}');
    
    if (response.isEmpty) {
      print('❌ Nenhum lembrete encontrado para este usuário');
      
      // Verificar se existem lembretes de qualquer usuário
      final allReminders = await client
          .from('reminders')
          .select()
          .limit(5);
      
      print('📊 Total de lembretes na tabela: ${allReminders.length}');
      if (allReminders.isNotEmpty) {
        print('🔍 Últimos lembretes (qualquer usuário):');
        for (var reminder in allReminders) {
          print('  - ID: ${reminder['id']}, User: ${reminder['user_id']}, Event: ${reminder['event_name']}');
        }
      }
    } else {
      print('✅ Lembretes encontrados:');
      for (var reminder in response) {
        print('  - ID: ${reminder['id']}');
        print('    Evento: ${reminder['event_name']}');
        print('    Data/Hora: ${reminder['reminder_datetime']}');
        print('    Criado em: ${reminder['created_at']}');
        print('    Status: ${reminder['status']}');
        print('');
      }
    }
  } catch (e) {
    print('❌ Erro ao consultar banco de dados: $e');
    
    // Verificar se a tabela existe
    try {
      final tables = await client.rpc('get_table_names');
      print('📋 Tabelas disponíveis: $tables');
    } catch (e2) {
      print('❌ Erro ao listar tabelas: $e2');
    }
  }
}
