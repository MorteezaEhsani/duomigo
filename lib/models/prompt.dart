// lib/models/prompt.dart
enum QuestionType {
  listenThenSpeak,
  speakAboutPhoto,
  readThenSpeak,
  speakingSample,
  customPrompt,
}

class Prompt {
  final String id;
  final QuestionType type;

  /// For text-based prompts (incl. Listen-Then-Speak where we TTS the text)
  final String? text;

  /// Not used anymore for Listen-Then-Speak (we TTS), but kept for completeness
  final String? audioUrl;

  /// For photo prompts (nullable because API may omit temporarily)
  final String? imageUrl;

  /// Timing knobs
  final int prepSeconds;
  final int minSeconds;
  final int maxSeconds;

  /// Whether the prep screen shows a “NEXT” button
  final bool allowNextDuringPrep;

  const Prompt({
    required this.id,
    required this.type,
    this.text,
    this.audioUrl,
    this.imageUrl,
    this.prepSeconds = 20,
    this.minSeconds = 30,
    this.maxSeconds = 90,
    this.allowNextDuringPrep = true,
  });

  // ---------- FACTORY CONSTRUCTORS ----------
  //
  // All factories below accept optional overrides for timings so you can pass
  // values coming from the backend response (prepSeconds / minSeconds / maxSeconds).
  // Also note text/imageUrl are nullable to match API shapes.

  factory Prompt.listenThenSpeak({
    required String id,
    String? text, // TTS text from API (nullable to match your parsing)
    int? prepSeconds,
    int? minSeconds,
    int? maxSeconds,
    bool allowNextDuringPrep = true,
  }) {
    return Prompt(
      id: id,
      type: QuestionType.listenThenSpeak,
      text: text,
      prepSeconds: prepSeconds ?? 20,
      minSeconds: minSeconds ?? 30,
      maxSeconds: maxSeconds ?? 90,
      allowNextDuringPrep: allowNextDuringPrep,
    );
  }

  factory Prompt.speakAboutPhoto({
    required String id,
    String? imageUrl, // allow nullable from API
    int? prepSeconds,
    int? minSeconds,
    int? maxSeconds,
    bool allowNextDuringPrep = true,
  }) {
    return Prompt(
      id: id,
      type: QuestionType.speakAboutPhoto,
      imageUrl: imageUrl,
      prepSeconds: prepSeconds ?? 20,
      minSeconds: minSeconds ?? 30,
      maxSeconds: maxSeconds ?? 90,
      allowNextDuringPrep: allowNextDuringPrep,
    );
  }

  factory Prompt.readThenSpeak({
    required String id,
    String? text,
    int? prepSeconds,
    int? minSeconds,
    int? maxSeconds,
    bool allowNextDuringPrep = true,
  }) {
    return Prompt(
      id: id,
      type: QuestionType.readThenSpeak,
      text: text,
      prepSeconds: prepSeconds ?? 20,
      minSeconds: minSeconds ?? 30,
      maxSeconds: maxSeconds ?? 90,
      allowNextDuringPrep: allowNextDuringPrep,
    );
  }

  factory Prompt.speakingSample({
    required String id,
    String? text,
    int? prepSeconds,
    int? minSeconds,
    int? maxSeconds,
    bool allowNextDuringPrep = true,
  }) {
    return Prompt(
      id: id,
      type: QuestionType.speakingSample,
      text: text,
      prepSeconds: prepSeconds ?? 30,
      minSeconds: minSeconds ?? 60,
      maxSeconds: maxSeconds ?? 180,
      allowNextDuringPrep: allowNextDuringPrep,
    );
  }

  factory Prompt.custom({
    required String id,
    String? text,
    required int speakSeconds,
    int prepSeconds = 20,
    bool allowNextDuringPrep = true,
  }) {
    return Prompt(
      id: id,
      type: QuestionType.customPrompt,
      text: text,
      prepSeconds: prepSeconds,
      minSeconds: (speakSeconds / 3).round(),
      maxSeconds: speakSeconds,
      allowNextDuringPrep: allowNextDuringPrep,
    );
  }
}
