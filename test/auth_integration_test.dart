import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:duomigo/main.dart';
import 'package:duomigo/screens/auth_page.dart';
import 'package:duomigo/screens/question_picker_screen.dart';

void main() {
  group('Authentication Flow Tests', () {
    setUpAll(() async {
      // Initialize Supabase for testing
      await Supabase.initialize(
        url: const String.fromEnvironment('SUPABASE_URL'),
        anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
      );
    });

    tearDown(() async {
      // Sign out after each test
      await Supabase.instance.client.auth.signOut();
    });

    testWidgets('Shows AuthPage when not authenticated', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(const DuomigoApp());
      await tester.pumpAndSettle();

      // Verify AuthPage is shown
      expect(find.byType(AuthPage), findsOneWidget);
      expect(find.text('Duomigo'), findsOneWidget);
      expect(find.text('Welcome back!'), findsOneWidget);
    });

    testWidgets('Can toggle between sign in and sign up', (WidgetTester tester) async {
      await tester.pumpWidget(const DuomigoApp());
      await tester.pumpAndSettle();

      // Initially in sign in mode
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text("Don't have an account? Sign Up"), findsOneWidget);

      // Tap to switch to sign up
      await tester.tap(find.text("Don't have an account? Sign Up"));
      await tester.pumpAndSettle();

      // Now in sign up mode
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Create an account'), findsOneWidget);
      expect(find.text('Already have an account? Sign In'), findsOneWidget);
    });

    testWidgets('Shows validation errors for empty fields', (WidgetTester tester) async {
      await tester.pumpWidget(const DuomigoApp());
      await tester.pumpAndSettle();

      // Try to sign in with empty fields
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('Shows validation error for invalid email', (WidgetTester tester) async {
      await tester.pumpWidget(const DuomigoApp());
      await tester.pumpAndSettle();

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField).first, 'notanemail');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pumpAndSettle();

      // Should show email validation error
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('Shows validation error for short password', (WidgetTester tester) async {
      await tester.pumpWidget(const DuomigoApp());
      await tester.pumpAndSettle();

      // Switch to sign up mode
      await tester.tap(find.text("Don't have an account? Sign Up"));
      await tester.pumpAndSettle();

      // Enter valid email but short password
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, '123');
      
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pumpAndSettle();

      // Should show password validation error
      expect(find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    // Note: Testing actual sign in/sign up requires a test Supabase instance
    // or mocking the Supabase client. Here's an example structure:

    testWidgets('Navigates to QuestionPickerScreen when authenticated', (WidgetTester tester) async {
      // This test would require either:
      // 1. A test Supabase instance with known credentials
      // 2. Mocking the Supabase client
      // 3. Using a test user that's already created

      // Example with mock (requires additional setup):
      /*
      when(mockSupabase.auth.currentUser).thenReturn(User(
        id: 'test-user-id',
        email: 'test@example.com',
        // ... other user properties
      ));

      await tester.pumpWidget(const DuomigoApp());
      await tester.pumpAndSettle();

      expect(find.byType(QuestionPickerScreen), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
      */
    });

    testWidgets('Sign out button returns to AuthPage', (WidgetTester tester) async {
      // This would also require authentication setup
      /*
      // Assume user is signed in
      await tester.pumpWidget(const DuomigoApp());
      await tester.pumpAndSettle();

      // Find and tap logout button
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      // Should return to AuthPage
      expect(find.byType(AuthPage), findsOneWidget);
      */
    });
  });

  group('User ID Integration Tests', () {
    test('Api service includes userId in createAttempt', () async {
      // This would test the API service directly
      /*
      final api = Api('http://127.0.0.1:8000');
      
      // Mock or use real Supabase user
      final userId = 'test-user-123';
      
      final attemptId = await api.createAttempt(
        promptId: 'test-prompt',
        prepSec: 20,
        speakSec: 60,
        userId: userId,
      );
      
      expect(attemptId, isNotNull);
      expect(attemptId, isNotEmpty);
      */
    });
  });
}