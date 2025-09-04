import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../services/recorder_controller.dart';

class RecorderScreen extends StatefulWidget {
  final int prepSeconds;
  final int recordSeconds;
  const RecorderScreen({
    super.key,
    this.prepSeconds = 10,
    this.recordSeconds = 90,
  });

  @override
  State<RecorderScreen> createState() => _RecorderScreenState();
}

class _RecorderScreenState extends State<RecorderScreen> {
  final _rec = RecorderController();
  final _player = AudioPlayer();
  Timer? _timer;
  int _remaining = 0;
  String _phase = 'idle'; // idle | prep | recording | done
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _remaining = widget.prepSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player.dispose();
    _rec.dispose();
    super.dispose();
  }

  void _startPrep() async {
    if (!await _rec.hasMicPermission()) {
      // This triggers the OS permission dialog on first attempt via `start()`,
      // but we give an early heads-up to the user.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please allow microphone access')),
      );
    }
    setState(() {
      _phase = 'prep';
      _remaining = widget.prepSeconds;
    });
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
    setState(() {
      _phase = 'recording';
      _remaining = widget.recordSeconds;
    });
    await _rec.start(); // creates a temp .m4a path internally

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (!mounted) return;
      if (_remaining <= 1) {
        t.cancel();
        await _stopRecording();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  Future<void> _stopRecording() async {
    final path = await _rec.stop();
    setState(() {
      _phase = 'done';
      _filePath = path;
    });
  }

  Future<void> _playback() async {
    if (_filePath == null) return;
    await _player.setFilePath(_filePath!);
    await _player.play();
  }

  @override
  Widget build(BuildContext context) {
    final isPrep = _phase == 'prep';
    final isRec = _phase == 'recording';
    final isDone = _phase == 'done';

    return Scaffold(
      appBar: AppBar(title: const Text('Practice Recorder')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Phase title
            Text(
              isPrep
                  ? 'Get ready…'
                  : (isRec
                        ? 'Recording…'
                        : (isDone ? 'Finished!' : 'Tap Start')),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),

            // Big countdown
            if (_phase != 'idle')
              Text(
                '$_remaining s',
                style: Theme.of(context).textTheme.displaySmall,
              ),

            const SizedBox(height: 24),

            // Simple visual indicator
            if (isRec)
              const Icon(Icons.mic, size: 96, color: Colors.red)
            else if (isPrep)
              const Icon(Icons.timer, size: 96)
            else if (isDone)
              const Icon(Icons.check_circle, size: 96, color: Colors.green)
            else
              const Icon(Icons.mic_none, size: 96),

            const Spacer(),

            // Buttons
            if (_phase == 'idle')
              FilledButton(onPressed: _startPrep, child: const Text('Start'))
            else if (isPrep)
              OutlinedButton(
                onPressed: () {
                  _timer?.cancel();
                  setState(() {
                    _phase = 'idle';
                    _remaining = widget.prepSeconds;
                  });
                },
                child: const Text('Cancel'),
              )
            else if (isRec)
              FilledButton.tonal(
                onPressed: () async {
                  _timer?.cancel();
                  await _stopRecording();
                },
                child: const Text('Stop now'),
              )
            else if (isDone) ...[
              FilledButton(
                onPressed: _playback,
                child: const Text('Play recording'),
              ),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () {
                  // Return the file path to previous screen or proceed to upload/analyze
                  Navigator.of(context).pop(_filePath);
                },
                child: const Text('Use this take'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _phase = 'idle';
                    _remaining = widget.prepSeconds;
                    _filePath = null;
                  });
                },
                child: const Text('Record again'),
              ),
            ],

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
