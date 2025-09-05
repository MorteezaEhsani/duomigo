# Duomigo Flutter App Setup Guide

## Quick Fix for "No host specified in URI" Error

This error occurs when the Supabase URL and Anon Key are not properly configured. Here are three ways to fix it:

## Option 1: Update app_config.dart (Easiest)

1. Open `lib/config/app_config.dart`
2. Replace the placeholder values with your actual Supabase credentials:

```dart
static const String supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
static const String supabaseAnonKey = 'YOUR_ANON_KEY';
```

You can find these values in your Supabase Dashboard:
- Go to Settings → API
- Copy **Project URL** for `supabaseUrl`
- Copy **anon public** key for `supabaseAnonKey`

## Option 2: Use Environment Variables

### Method A: Using the run script
```bash
# Set environment variables
export SUPABASE_URL="https://your-project.supabase.co"
export SUPABASE_ANON_KEY="your_anon_key_here"

# Run using the script
./run_app.sh
```

### Method B: Direct flutter run
```bash
flutter run \
  --dart-define=SUPABASE_URL="https://your-project.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="your_anon_key_here"
```

## Option 3: Use Backend .env File

If you have the backend `.env` configured:
1. The `run_app.sh` script will automatically load variables from `../duomigo-backend/.env`
2. Just run: `./run_app.sh`

## For Different Platforms

### iOS Simulator
Use `127.0.0.1:8000` for backend URL

### Android Emulator
Use `10.0.2.2:8000` for backend URL:
```bash
flutter run --dart-define=BACKEND_URL="http://10.0.2.2:8000" \
  --dart-define=SUPABASE_URL="your_url" \
  --dart-define=SUPABASE_ANON_KEY="your_key"
```

### Physical Device
Use your computer's IP address:
```bash
flutter run --dart-define=BACKEND_URL="http://192.168.1.100:8000" \
  --dart-define=SUPABASE_URL="your_url" \
  --dart-define=SUPABASE_ANON_KEY="your_key"
```

## Verify Configuration

After running the app, check the console for:
- ✅ Supabase initialized successfully
- Or warning messages indicating what needs to be configured

## VS Code Launch Configuration

Create `.vscode/launch.json`:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "duomigo",
      "request": "launch",
      "type": "dart",
      "args": [
        "--dart-define=SUPABASE_URL=https://your-project.supabase.co",
        "--dart-define=SUPABASE_ANON_KEY=your_anon_key",
        "--dart-define=BACKEND_URL=http://127.0.0.1:8000"
      ]
    }
  ]
}
```

## Android Studio Run Configuration

1. Edit Configurations → Flutter
2. Additional run args:
```
--dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your_key
```

## Troubleshooting

If you still see the error:
1. Check that the URL starts with `https://` (not just the domain)
2. Ensure there are no spaces or quotes in the URL in app_config.dart
3. Try hardcoding values temporarily to test
4. Check Flutter console output for initialization messages