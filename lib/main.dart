// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/question_picker_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audio_session/audio_session.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

class DuomigoApp extends StatelessWidget {
  const DuomigoApp({super.key});
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
      home: const QuestionPickerScreen(),
    );
  }
}
