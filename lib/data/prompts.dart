import 'dart:math';

final _rand = Random();

/// Pick a random item from a list
T randomOf<T>(List<T> items) => items[_rand.nextInt(items.length)];

/// ---- Listen, Then Speak ----
const listenPrompts = <String>[
  'Talk about a memorable teacher and what you learned from them.',
  'Describe your ideal city to live in and explain why.',
  'Explain a hobby you enjoy and how it benefits you.',
  'Describe a place from your childhood that you remember well.',
  'Talk about a goal you achieved and how you reached it.',
];

/// ---- Read, Then Speak ----
const readPrompts = <String>[
  'Do you agree that technology has made life better? Provide two reasons and examples.',
  'Some people think students should wear uniforms. Do you agree or disagree? Explain.',
  'Should governments spend more money on space exploration? Why or why not?',
];

/// ---- Speaking Sample ----
const speakingSamplePrompts = <String>[
  'Describe a challenge you faced and how you overcame it. Include specific details.',
  'Talk about a time you helped someone. How did it make you feel?',
  'What is one achievement you are proud of? Describe the experience.',
];

/// ---- Photo Prompts ---- (you can expand this with curated images)
const photoPrompts = <String>[
  'https://picsum.photos/800/600',
  'https://picsum.photos/id/237/800/600',
  'https://picsum.photos/id/1025/800/600',
];
