import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://xkkxylouvyjdymnpxzld.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhra3h5bG91dnlqZHltbnB4emxkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE0Njg3MDEsImV4cCI6MjA2NzA0NDcwMX0.c5SRJPpm9VzEHh0PeNqVRamYn5BfGOtgbg9F36d2ew8';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
