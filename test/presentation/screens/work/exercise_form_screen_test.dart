import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_app/presentation/screens/work/exercise_form_screen.dart';

void main() {
  Widget makeTestable() {
    return const ProviderScope(
      child: MaterialApp(
        home: ExerciseFormScreen(),
      ),
    );
  }

  group('ExerciseFormScreen', () {
    testWidgets('renders new exercise form', (tester) async {
      await tester.pumpWidget(makeTestable());
      await tester.pump();

      expect(find.text('New Exercise'), findsOneWidget);
      expect(find.text('Create'), findsOneWidget);
    });

    testWidgets('shows validation error on empty name', (tester) async {
      await tester.pumpWidget(makeTestable());
      await tester.pump();

      // Scroll to make the button visible
      await tester.scrollUntilVisible(
        find.text('Create'),
        100,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.text('Create'));
      await tester.pump();

      expect(find.text('Name is required'), findsOneWidget);
    });

    testWidgets('has muscle group dropdown', (tester) async {
      await tester.pumpWidget(makeTestable());
      await tester.pump();

      expect(find.text('Muscle Group'), findsOneWidget);
    });

    testWidgets('has difficulty dropdown', (tester) async {
      await tester.pumpWidget(makeTestable());
      await tester.pump();

      expect(find.text('Difficulty'), findsOneWidget);
    });

    testWidgets('has equipment filter chips', (tester) async {
      await tester.pumpWidget(makeTestable());
      await tester.pump();

      expect(find.text('Equipment'), findsOneWidget);
      expect(find.byType(FilterChip), findsWidgets);
    });
  });
}
