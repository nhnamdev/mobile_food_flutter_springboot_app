import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Supabase credentials từ dashboard
  static const String supabaseUrl = 'https://nwagwvwydcggsbxqiwbo.supabase.co';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY'; // Lấy từ Supabase Dashboard > Settings > API
  
  // Database connection info (for reference)
  static const String databaseHost = 'db.nwagwvwydcggsbxqiwbo.supabase.co';
  static const String databasePort = '5432';
  static const String databaseName = 'postgres';
  static const String databaseUser = 'postgres';
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: true, // Bật debug mode để xem logs
    );
  }
  
  // Getter để dễ dàng truy cập Supabase client
  static SupabaseClient get client => Supabase.instance.client;
}
