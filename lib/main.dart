// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/question_picker_screen.dart';
import 'screens/auth_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audio_session/audio_session.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with configuration
  final supabaseUrl = AppConfig.getSupabaseUrl();
  final supabaseAnonKey = AppConfig.getSupabaseAnonKey();
  
  // Check if configuration is valid
  if (supabaseUrl == 'https://YOUR_PROJECT_ID.supabase.co' || 
      supabaseAnonKey == 'YOUR_ANON_KEY') {
    print('⚠️ WARNING: Supabase credentials not configured!');
    print('Please update lib/config/app_config.dart with your Supabase project details');
    print('Or run with: flutter run --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key');
  }
  
  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    print('✅ Supabase initialized successfully');
  } catch (e) {
    print('❌ Failed to initialize Supabase: $e');
    print('URL: $supabaseUrl');
    print('Key: ${supabaseAnonKey.substring(0, 10)}...');
  }

  // Lock orientation to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Ensure playback works even with the iPhone mute switch on.
  final session = await AudioSession.instance;
  await session.configure(
    AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.duckOthers |
          AVAudioSessionCategoryOptions.mixWithOthers,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        usage: AndroidAudioUsage.media,
      ),
      androidWillPauseWhenDucked: true,
    ),
  );

  runApp(const DuomigoApp());
}

class DuomigoApp extends StatefulWidget {
  const DuomigoApp({super.key});

  @override
  State<DuomigoApp> createState() => _DuomigoAppState();
}

class _DuomigoAppState extends State<DuomigoApp> {
  final supabase = Supabase.instance.client;
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'duomigo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF58CC02),
          secondary: Color(0xFFFFD43B),
          surface: Color(0xFFFFFFFF),
          background: Color(0xFFFFFFFF),
          error: Color(0xFFFF4B4B),
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: Color(0xFF586380),
          onBackground: Color(0xFF586380),
          onError: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF58CC02),
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: GoogleFonts.baloo2(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        textTheme: TextTheme(
          headlineLarge: GoogleFonts.fredoka(
            fontSize: 32,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF586380),
          ),
          headlineMedium: GoogleFonts.fredoka(
            fontSize: 28,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF586380),
          ),
          headlineSmall: GoogleFonts.fredoka(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF586380),
          ),
          titleLarge: GoogleFonts.baloo2(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF586380),
          ),
          titleMedium: GoogleFonts.baloo2(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF586380),
          ),
          titleSmall: GoogleFonts.baloo2(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF586380),
          ),
          bodyLarge: GoogleFonts.nunitoSans(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF586380),
          ),
          bodyMedium: GoogleFonts.nunitoSans(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF586380),
          ),
          bodySmall: GoogleFonts.nunitoSans(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF586380),
          ),
          labelLarge: GoogleFonts.nunitoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF586380),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF58CC02),
            foregroundColor: Colors.white,
            textStyle: GoogleFonts.baloo2(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF58CC02),
            foregroundColor: Colors.white,
            textStyle: GoogleFonts.baloo2(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF58CC02),
            side: const BorderSide(color: Color(0xFF58CC02), width: 2),
            textStyle: GoogleFonts.baloo2(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
        ),
      ),
      home: StreamBuilder<AuthState>(
        stream: supabase.auth.onAuthStateChange,
        builder: (context, snapshot) {
          // Check if user is logged in
          if (supabase.auth.currentUser != null) {
            return const QuestionPickerScreen();
          }
          return const AuthPage();
        },
      ),
    );
  }
}
