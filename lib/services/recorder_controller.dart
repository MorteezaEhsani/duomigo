import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

class RecorderController {
  final AudioRecorder _rec = AudioRecorder();
  String? _path;

  Future<bool> hasMicPermission() async {
    return await _rec.hasPermission();
  }

  /// Starts recording to a temporary .m4a file. Returns the target path.
  Future<String> start({int sampleRate = 44100, int bitrate = 128000}) async {
    if (!await _rec.hasPermission()) {
      throw Exception('Microphone permission required');
    }
    final dir = await getTemporaryDirectory();
    final id = const Uuid().v4();
    _path = '${dir.path}/$id.m4a';

    await _rec.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 44100,
        bitRate: 128000,
      ),
      path: _path!,
    );
    return _path!;
  }

  /// Stops recording and returns the final file path (or null if not recording).
  Future<String?> stop() async {
    final path = await _rec.stop();
    _path = path;
    return path;
  }

  Future<bool> isRecording() => _rec.isRecording();
  Future<void> dispose() async => _rec.dispose();
}
