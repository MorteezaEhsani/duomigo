# duomigo

A Flutter app for practicing English speaking skills with Duolingo-style exercises.

## Getting Started

### Prerequisites
- Flutter SDK installed
- Supabase project created with authentication enabled

### Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Run the app with Supabase environment variables:
```bash
flutter run --dart-define=SUPABASE_URL=your_supabase_url --dart-define=SUPABASE_ANON_KEY=your_supabase_anon_key
```

### Environment Variables

The app requires the following environment variables:
- `SUPABASE_URL`: Your Supabase project URL
- `SUPABASE_ANON_KEY`: Your Supabase anonymous/public key

You can find these values in your Supabase project settings under API Settings.

### Development

For development, you can create a launch configuration in VS Code or Android Studio to include the environment variables, or use a script to run the app with the required variables.
