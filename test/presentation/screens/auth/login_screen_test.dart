import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_app/presentation/screens/auth/login_screen.dart';

void main() {
  Widget makeTestable() {
    return const ProviderScope(
      child: MaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  group('LoginScreen', () {
    testWidgets('renders login form with email and password fields', (tester) async {
      await tester.pumpWidget(makeTestable());
      await tester.pump();

      expect(find.text('GymApp'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('shows email validation error after interaction', (tester) async {
      await tester.pumpWidget(makeTestable());
      await tester.pump();

      // Focus the email field and submit empty
      await tester.enterText(find.byType(TextFormField).first, '');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('shows invalid email format error', (tester) async {
      await tester.pumpWidget(makeTestable());
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).first, 'not-an-email');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(find.text('Invalid email format'), findsOneWidget);
    });

    testWidgets('shows password too short error', (tester) async {
      await tester.pumpWidget(makeTestable());
      await tester.pump();

      await tester.enterText(find.byType(TextFormField).last, '123');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
    });

    testWidgets('has register navigation link', (tester) async {
      await tester.pumpWidget(makeTestable());
      await tester.pump();

      expect(
        find.text("Don't have an account? Register"),
        findsOneWidget,
      );
    });

    testWidgets('has password visibility toggle', (tester) async {
      await tester.pumpWidget(makeTestable());
      await tester.pump();

      expect(find.byIcon(Icons.visibility), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });
  });
}
