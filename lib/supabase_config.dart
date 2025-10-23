import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SupabaseConfig {
  static Future<void> initialize() async {
    String supabaseUrl;
    String supabaseAnonKey;

    if (kIsWeb) {
      // For web builds, use build-time environment variables
      // Build with: flutter build web --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
      supabaseUrl = const String.fromEnvironment('SUPABASE_URL');
      supabaseAnonKey = const String.fromEnvironment('SUPABASE_ANON_KEY');
      print('🌐 Using build-time environment variables');
    } else {
      // For local development, use .env file
      await dotenv.load(fileName: ".env");
      supabaseUrl = dotenv.env['supabase_url'] ?? '';
      supabaseAnonKey = dotenv.env['anon_key'] ?? '';
      print('📱 Using .env file');
    }

    print('🔍 DEBUG: Supabase URL: $supabaseUrl');
    print('🔍 DEBUG: Has Secret Key: ${supabaseAnonKey.isNotEmpty}');

    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
        'Supabase credentials must be provided. '
        'For web: Use --dart-define flags. For local: Use .env file',
      );
    }

    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    print('✅ Supabase initialized successfully');
  }

  static SupabaseClient get client => Supabase.instance.client;
}
