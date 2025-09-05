// lib/config/app_config.dart

class AppConfig {
  // Supabase configuration
  // Replace these with your actual Supabase project values
  static const String supabaseUrl = 'https://ayrxmujruxhrkzuwmflx.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF5cnhtdWpydXhocmt6dXdtZmx4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcwMjQ2MjMsImV4cCI6MjA3MjYwMDYyM30.sbuocXo_PwyvrjMzvAS3VtwvV0g7KoHDl99YsEWJp9w';

  // Backend configuration
  static const String backendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue:
        'http://127.0.0.1:8000', // Use 10.0.2.2:8000 for Android emulator
  );

  // You can also read from environment with defaults
  static String getSupabaseUrl() {
    const envUrl = String.fromEnvironment('SUPABASE_URL');
    return envUrl.isNotEmpty ? envUrl : supabaseUrl;
  }

  static String getSupabaseAnonKey() {
    const envKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    return envKey.isNotEmpty ? envKey : supabaseAnonKey;
  }
}
