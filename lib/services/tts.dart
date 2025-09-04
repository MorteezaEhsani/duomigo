// lib/services/tts.dart
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class TtsService {
  // private constructor
  TtsService._internal(this._dio);

  static TtsService? _instance;
  static TtsService get instance {
    _instance ??= TtsService._internal(
      Dio(
        BaseOptions(
          baseUrl: const String.fromEnvironment(
            'BACKEND_URL',
            defaultValue: 'http://127.0.0.1:8000', // change for emulator/device
          ),
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 60),
        ),
      ),
    );
    return _instance!;
  }

  final Dio _dio;
  final AudioPlayer _player = AudioPlayer();

  bool _isSpeaking = false;

  /// Speak text using OpenAI TTS via backend
  Future<void> speak(
    String text, {
    String voice = 'alloy',
    String format = 'mp3',
  }) async {
    await stop();

    try {
      final res = await _dio.post<List<int>>(
        '/api/tts',
        data: jsonEncode({"text": text, "voice": voice, "format": format}),
        options: Options(
          headers: {'Content-Type': 'application/json'},
          responseType: ResponseType.bytes,
        ),
      );

      if (res.statusCode != 200 || res.data == null) {
        throw Exception('TTS failed: ${res.statusCode}');
      }

      // save to temp file
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/tts_${DateTime.now().millisecondsSinceEpoch}.$format',
      );
      await file.writeAsBytes(res.data!);

      // play with just_audio
      await _player.setFilePath(file.path);
      await _player.play();
      _isSpeaking = true;
    } catch (e) {
      throw Exception('TTS error: $e');
    }
  }

  /// Stop speaking if currently active
  Future<void> stop() async {
    if (_isSpeaking) {
      await _player.stop();
      _isSpeaking = false;
    }
  }
}
