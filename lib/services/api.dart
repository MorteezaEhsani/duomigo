// lib/services/api.dart
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Api {
  final String baseUrl;
  final dio.Dio _dio;

  Api(this.baseUrl)
    : _dio = dio.Dio(
        dio.BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 60),
        ),
      ) {
    // Add interceptor to include JWT token if available
    _dio.interceptors.add(dio.InterceptorsWrapper(
      onRequest: (options, handler) {
        // Get the current session from Supabase
        try {
          final session = Supabase.instance.client.auth.currentSession;
          if (session != null) {
            options.headers['Authorization'] = 'Bearer ${session.accessToken}';
          }
        } catch (e) {
          // Supabase not initialized or no session, continue without auth header
        }
        handler.next(options);
      },
    ));
  }

  // ---- Attempts flow --------------------------------------------------------

  Future<String> createAttempt({
    required String promptId,
    required int prepSec,
    required int speakSec,
    String? userId,
  }) async {
    final form = dio.FormData.fromMap({
      'promptId': promptId,
      'prepSec': prepSec,
      'speakSec': speakSec,
      if (userId != null) 'userId': userId,
    });

    final res = await _dio.post('/api/attempts', data: form);
    if (res.statusCode != 200 || res.data == null) {
      throw Exception('Failed to create attempt (${res.statusCode})');
    }
    final data = (res.data as Map).cast<String, dynamic>();
    return data['attemptId'] as String;
  }

  Future<void> uploadAudio(String attemptId, String filePath) async {
    final form = dio.FormData.fromMap({
      'file': await dio.MultipartFile.fromFile(filePath, filename: 'audio.m4a'),
    });

    final res = await _dio.post('/api/attempts/$attemptId/upload', data: form);
    if (res.statusCode != 200) {
      throw Exception('Upload failed (${res.statusCode})');
    }
  }

  Future<Map<String, dynamic>> analyze(String attemptId) async {
    final res = await _dio.post('/api/attempts/$attemptId/analyze');
    if (res.statusCode != 200 || res.data == null) {
      throw Exception('Analyze failed (${res.statusCode})');
    }
    return (res.data as Map).cast<String, dynamic>();
  }

  // ---- Prompts & TTS --------------------------------------------------------

  /// Get a new prompt for a given type.
  /// Types: listenThenSpeak, readThenSpeak, speakingSample, speakAboutPhoto
  Future<Map<String, dynamic>> fetchNextPrompt(String type) async {
    final res = await _dio.get(
      '/api/prompts/next',
      queryParameters: {'type': type},
    );
    if (res.statusCode != 200 || res.data == null) {
      throw Exception('Prompt fetch failed (${res.statusCode})');
    }
    return (res.data as Map).cast<String, dynamic>();
  }

  /// Ask backend to generate OpenAI TTS for a promptId and return local file path.
  Future<String> fetchTtsByPromptId(
    String promptId, {
    String voice = 'alloy',
    String format = 'mp3',
  }) async {
    final res = await _dio.post<List<int>>(
      '/api/tts',
      data: {
        'promptId': promptId,
        'voice': voice,
        'format': format,
      },
      options: dio.Options(
        responseType: dio.ResponseType.bytes,
      ),
    );

    if (res.statusCode != 200 || res.data == null) {
      throw Exception('TTS failed (${res.statusCode})');
    }

    final bytes = res.data!;
    final dir = await getTemporaryDirectory();
    final ext = format.toLowerCase() == 'wav' ? 'wav' : 'mp3';
    final file = File(
      '${dir.path}/tts_${DateTime.now().millisecondsSinceEpoch}.$ext',
    );
    await file.writeAsBytes(bytes);
    return file.path;
  }
}
