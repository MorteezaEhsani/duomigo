// lib/screens/question_picker_screen.dart
import 'package:duomigo/widgets/tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/prompt.dart';
import '../widgets/practice_session_sheet.dart';
import '../services/api.dart';
import 'feedback_screen.dart';

class QuestionPickerScreen extends StatelessWidget {
  const QuestionPickerScreen({super.key});

  Api _api() {
    const backend = String.fromEnvironment(
      'BACKEND_URL',
      defaultValue: 'http://127.0.0.1:8000', // Android emulator: 10.0.2.2
    );
    return Api(backend);
  }

  Future<void> _runPrompt(BuildContext context, Prompt p) async {
    final path = await showPracticeSessionSheet(context, p);
    if (path == null) return;

    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final api = _api();
      final userId = Supabase.instance.client.auth.currentUser?.id;

      final attemptId = await api.createAttempt(
        promptId: p.id,
        prepSec: p.prepSeconds,
        speakSec: p.maxSeconds,
        userId: userId,
      );
      await api.uploadAudio(attemptId, path);
      final feedback = await api.analyze(attemptId);

      if (!context.mounted) return;
      Navigator.of(context).pop(); // close loading
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => FeedbackScreen(data: feedback)));
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Analysis failed: $e')));
    }
  }

  // ---- Helpers to start each type (now fetched from backend) ----

  Future<void> _withSpinner(
    BuildContext context,
    Future<void> Function() task,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await task();
    } finally {
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _startListenThenSpeak(BuildContext context) async {
    Map<String, dynamic>? p;
    await _withSpinner(context, () async {
      p = await _api().fetchNextPrompt('listenThenSpeak');
    });

    if (p == null || !context.mounted) return;

    await _runPrompt(
      context,
      Prompt.listenThenSpeak(
        id: p!['id'] as String,
        text: p!['text'] as String,
        prepSeconds: p!['prepSeconds'] as int? ?? 20,
        minSeconds: p!['minSeconds'] as int? ?? 30,
        maxSeconds: p!['maxSeconds'] as int? ?? 90,
      ),
    );
  }

  Future<void> _startSpeakAboutPhoto(BuildContext context) async {
    Map<String, dynamic>? p;
    await _withSpinner(context, () async {
      p = await _api().fetchNextPrompt('speakAboutPhoto');
    });

    if (p == null || !context.mounted) return;

    await _runPrompt(
      context,
      Prompt.speakAboutPhoto(
        id: p!['id'] as String,
        imageUrl: p!['imageUrl'] as String,
        prepSeconds: p!['prepSeconds'] as int? ?? 20,
        minSeconds: p!['minSeconds'] as int? ?? 30,
        maxSeconds: p!['maxSeconds'] as int? ?? 90,
      ),
    );
  }

  Future<void> _startReadThenSpeak(BuildContext context) async {
    Map<String, dynamic>? p;
    await _withSpinner(context, () async {
      p = await _api().fetchNextPrompt('readThenSpeak');
    });

    if (p == null || !context.mounted) return;

    await _runPrompt(
      context,
      Prompt.readThenSpeak(
        id: p!['id'] as String,
        text: p!['text'] as String,
        prepSeconds: p!['prepSeconds'] as int? ?? 20,
        minSeconds: p!['minSeconds'] as int? ?? 30,
        maxSeconds: p!['maxSeconds'] as int? ?? 90,
      ),
    );
  }

  Future<void> _startSpeakingSample(BuildContext context) async {
    Map<String, dynamic>? p;
    await _withSpinner(context, () async {
      p = await _api().fetchNextPrompt('speakingSample');
    });

    if (p == null || !context.mounted) return;

    await _runPrompt(
      context,
      Prompt.speakingSample(
        id: p!['id'] as String,
        text: p!['text'] as String,
        prepSeconds: p!['prepSeconds'] as int? ?? 30,
        minSeconds: p!['minSeconds'] as int? ?? 60,
        maxSeconds: p!['maxSeconds'] as int? ?? 180,
      ),
    );
  }

  // Custom Prompt (local dialog)
  Future<void> _startCustomPrompt(BuildContext context) async {
    final cfg = await showDialog<_CustomConfig>(
      context: context,
      builder: (_) => const _CustomPromptDialog(),
    );
    if (cfg == null) return;

    await _runPrompt(
      context,
      Prompt.custom(
        id: 'q5-${DateTime.now().millisecondsSinceEpoch}',
        text: cfg.text,
        speakSeconds: cfg.seconds,
        prepSeconds: 20,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Grid items (excluding Custom Prompt)
    final gridTiles = <GridItem>[
      GridItem(
        title: 'Listen, Then Speak',
        assetPath: 'assets/icons/listen.png',
        onTap: () async => await _startListenThenSpeak(context),
      ),
      GridItem(
        title: 'Speak About the Photo',
        assetPath: 'assets/icons/photo.png',
        onTap: () async => await _startSpeakAboutPhoto(context),
      ),
      GridItem(
        title: 'Read, Then Speak',
        assetPath: 'assets/icons/read.png',
        onTap: () async => await _startReadThenSpeak(context),
      ),
      GridItem(
        title: 'Speaking Sample',
        assetPath: 'assets/icons/sample.png',
        onTap: () async => await _startSpeakingSample(context),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'duomigo',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Grid for main question types
              Expanded(
                child: MasonryGridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  itemCount: gridTiles.length,
                  itemBuilder: (_, i) => TileCard(item: gridTiles[i]),
                ),
              ),

              // Custom Prompt as a full-width ListTile below the grid
              Card(
                child: ListTile(
                  leading: Image.asset(
                    'assets/icons/custom.png',
                    width: 40,
                    height: 40,
                  ),
                  title: Text(
                    'Custom Prompt',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    'Create your own speaking challenge',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () async => await _startCustomPrompt(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Custom Prompt dialog ----------

class _CustomConfig {
  final String? text;
  final int seconds;
  const _CustomConfig(this.text, this.seconds);
}

class _CustomPromptDialog extends StatefulWidget {
  const _CustomPromptDialog();

  @override
  State<_CustomPromptDialog> createState() => _CustomPromptDialogState();
}

class _CustomPromptDialogState extends State<_CustomPromptDialog> {
  final _textCtrl = TextEditingController();
  final _durCtrl = TextEditingController(text: '120');

  @override
  void dispose() {
    _textCtrl.dispose();
    _durCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Custom Prompt'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _textCtrl,
            decoration: const InputDecoration(
              labelText: 'Prompt (optional)',
              hintText: 'Topic or question',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _durCtrl,
            decoration: const InputDecoration(
              labelText: 'Speak time (seconds)',
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final secs = int.tryParse(_durCtrl.text.trim()) ?? 90;
            final cleaned = _textCtrl.text.trim();
            Navigator.pop(
              context,
              _CustomConfig(cleaned.isEmpty ? null : cleaned, secs),
            );
          },
          child: const Text('Start'),
        ),
      ],
    );
  }
}
