#!/bin/bash

# Flutter run script with Supabase configuration
# Usage: ./run_app.sh

# Load environment variables from backend .env if it exists
if [ -f "../duomigo-backend/.env" ]; then
    echo "Loading environment from ../duomigo-backend/.env"
    export $(cat ../duomigo-backend/.env | grep -v '^#' | xargs)
fi

# Check if required variables are set
if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
    echo "❌ Error: SUPABASE_URL and SUPABASE_ANON_KEY must be set!"
    echo ""
    echo "Option 1: Set them in your shell:"
    echo "  export SUPABASE_URL=https://your-project.supabase.co"
    echo "  export SUPABASE_ANON_KEY=your_anon_key"
    echo ""
    echo "Option 2: Update lib/config/app_config.dart directly"
    echo ""
    echo "Option 3: Create ../duomigo-backend/.env with:"
    echo "  SUPABASE_URL=https://your-project.supabase.co"
    echo "  SUPABASE_ANON_KEY=your_anon_key"
    exit 1
fi

# Backend URL (default to localhost, use 10.0.2.2 for Android emulator)
BACKEND_URL=${BACKEND_URL:-"http://127.0.0.1:8000"}

echo "🚀 Starting Flutter app with:"
echo "   SUPABASE_URL: $SUPABASE_URL"
echo "   SUPABASE_ANON_KEY: ${SUPABASE_ANON_KEY:0:20}..."
echo "   BACKEND_URL: $BACKEND_URL"
echo ""

# Run Flutter with environment variables
flutter run \
    --dart-define=SUPABASE_URL="$SUPABASE_URL" \
    --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
    --dart-define=BACKEND_URL="$BACKEND_URL"