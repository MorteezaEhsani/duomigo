// lib/widgets/practice_session_sheet.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../models/prompt.dart';
import '../services/recorder_controller.dart';
import '../services/api.dart';

/// Shows a full-height bottom sheet that drives the entire session.
/// Returns the recorded file path on success, or null if cancelled.
Future<String?> showPracticeSessionSheet(BuildContext context, Prompt prompt) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (_) => _PracticeSessionSheet(prompt: prompt),
  );
}

class _PracticeSessionSheet extends StatefulWidget {
  final Prompt prompt;
  const _PracticeSessionSheet({required this.prompt});

  @override
  State<_PracticeSessionSheet> createState() => _PracticeSessionSheetState();
}

class _PracticeSessionSheetState extends State<_PracticeSessionSheet> {
  final _rec = RecorderController();

  // TTS playback via backend (OpenAI) -> just_audio
  final _ttsPlayer = AudioPlayer();
  bool _isFetchingTts = false;
  bool _isPlayingTts = false;
  String? _ttsLocalPath; // cached local file path for prompt TTS

  Timer? _timer;
  String _phase = 'prep'; // prep | recording | done
  int _remaining = 0;
  int _elapsed = 0;
  String? _filePath;

  String? _promptError;

  Api get _api {
    const backend = String.fromEnvironment(
      'BACKEND_URL',
      defaultValue: 'http://127.0.0.1:8000', // Android emulator: 10.0.2.2
    );
    return Api(backend);
  }

  @override
  void initState() {
    super.initState();
    _remaining = widget.prompt.prepSeconds;

    // Track player state for button label
    _ttsPlayer.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlayingTts = state.playing;
      });
    });

    // When playback completes, make sure button returns to "Play prompt"
    _ttsPlayer.processingStateStream.listen((ps) async {
      if (!mounted) return;
      if (ps == ProcessingState.completed) {
        // keep the source and position, but reflect not-playing state
        await _ttsPlayer.stop();
        if (mounted) {
          setState(() {
            _isPlayingTts = false;
          });
        }
      }
    });

    _startPrep();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ttsPlayer.dispose();
    _rec.dispose();
    super.dispose();
  }

  void _startPrep() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_remaining <= 1) {
        t.cancel();
        _startRecording();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  Future<void> _startRecording() async {
    // stop/pause any prompt audio first
    try {
      await _ttsPlayer.pause();
    } catch (_) {}

    setState(() {
      _phase = 'recording';
      _remaining = widget.prompt.maxSeconds;
      _elapsed = 0;
    });

    await _rec.start();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (!mounted) return;
      if (_remaining <= 1) {
        t.cancel();
        await _stopRecording(autoStop: true);
      } else {
        setState(() {
          _remaining--;
          _elapsed++;
        });
      }
    });
  }

  Future<void> _stopRecording({bool autoStop = false}) async {
    final path = await _rec.stop();
    setState(() {
      _phase = 'done';
      _filePath = path;
    });
    if (!autoStop && _elapsed < widget.prompt.minSeconds && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Minimum ${widget.prompt.minSeconds}s not met (you spoke $_elapsed s).',
          ),
        ),
      );
    }
  }

  /// Fetch TTS for this promptId from backend and toggle playback.
  Future<void> _togglePromptPlayback(Prompt p) async {
    if (_isFetchingTts) return;

    try {
      // If already playing, pause
      if (_ttsPlayer.playing) {
        await _ttsPlayer.pause();
        return;
      }

      // If we already fetched the file before, just play it
      if (_ttsLocalPath != null) {
        await _ttsPlayer.setFilePath(_ttsLocalPath!);
        await _ttsPlayer.play();
        return;
      }

      // Else fetch TTS bytes from backend, save to temp, and play
      setState(() {
        _isFetchingTts = true;
        _promptError = null;
      });

      final path = await _api.fetchTtsByPromptId(p.id, voice: 'alloy');
      _ttsLocalPath = path;

      await _ttsPlayer.setFilePath(path);
      await _ttsPlayer.play();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _promptError = 'TTS error: $e';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('TTS failed: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingTts = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.prompt;
    final canUse = _elapsed >= p.minSeconds && _filePath != null;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.92,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: ListView(
            controller: controller,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _titleFor(p.type),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (_phase == 'prep') ...[
                Text('Recording starts automatically in $_remaining s.'),
                const SizedBox(height: 12),
                _prepContent(p),
                const SizedBox(height: 16),
                if (p.allowNextDuringPrep)
                  FilledButton(
                    onPressed: _startRecording,
                    child: const Text('NEXT'),
                  ),
              ] else if (_phase == 'recording') ...[
                Row(
                  children: [
                    const Icon(Icons.mic, color: Colors.red),
                    const SizedBox(width: 8),
                    Text('Elapsed: ${_elapsed}s'),
                    const Spacer(),
                    Text('Left: $_remaining s'),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: () => _stopRecording(autoStop: false),
                  child: Text(
                    'Stop${_elapsed < p.minSeconds ? ' (min ${p.minSeconds}s not met)' : ''}',
                  ),
                ),
              ] else ...[
                Text(
                  'Finished. You spoke for $_elapsed s. Minimum: ${p.minSeconds}s.',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: canUse
                            ? () => Navigator.pop(context, _filePath)
                            : null,
                        child: const Text('Use this take'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _phase = 'prep';
                          _filePath = null;
                          _remaining = p.prepSeconds;
                          // keep cached TTS so user can replay next round if desired
                        });
                        _startPrep();
                      },
                      child: const Text('Record again'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _prepContent(Prompt p) {
    switch (p.type) {
      case QuestionType.listenThenSpeak:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilledButton.tonal(
              onPressed: _isFetchingTts ? null : () => _togglePromptPlayback(p),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isFetchingTts)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  Text(_isPlayingTts ? 'Pause prompt' : 'Play prompt'),
                ],
              ),
            ),
            if (_promptError != null) ...[
              const SizedBox(height: 8),
              Text(
                _promptError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              p.text ?? 'Prompt will be spoken aloud.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            const Text('You may replay the prompt during prep.'),
          ],
        );

      case QuestionType.speakAboutPhoto:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (p.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  p.imageUrl!,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 8),
            const Text(
              'Describe what you see: people, objects, setting, relationships, and possible story.',
            ),
          ],
        );

      case QuestionType.readThenSpeak:
      case QuestionType.speakingSample:
      case QuestionType.customPrompt:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(p.text ?? 'Prepare your thoughts…'),
        );
    }
  }

  String _titleFor(QuestionType t) => switch (t) {
    QuestionType.listenThenSpeak => 'Listen, Then Speak',
    QuestionType.speakAboutPhoto => 'Speak About the Photo',
    QuestionType.readThenSpeak => 'Read, Then Speak',
    QuestionType.speakingSample => 'Speaking Sample',
    QuestionType.customPrompt => 'Custom Prompt',
  };
}
