// Example usage of the updated API with userId

import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/api.dart';

// Example function showing how to create an attempt with user authentication
Future<void> createAuthenticatedAttempt() async {
  // Initialize API client
  final api = Api('http://127.0.0.1:8000');
  
  // Get the current user ID from Supabase
  final userId = Supabase.instance.client.auth.currentUser?.id;
  
  // Create an attempt with the user ID
  final attemptId = await api.createAttempt(
    promptId: 'ls1',
    prepSec: 20,
    speakSec: 90,
    userId: userId, // Pass the user ID (can be null if not authenticated)
  );
  
  print('Created attempt: $attemptId for user: $userId');
}

// The userId is now optional in the API, so it works both with and without authentication:
// - If user is logged in: userId will be sent to backend
// - If user is not logged in: userId will be null and not sent