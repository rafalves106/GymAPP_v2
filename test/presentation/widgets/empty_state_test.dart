import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/presentation/widgets/empty_state.dart';

void main() {
  group('EmptyState', () {
    testWidgets('renders title and icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.fitness_center,
              title: 'No exercises',
            ),
          ),
        ),
      );

      expect(find.text('No exercises'), findsOneWidget);
      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
    });

    testWidgets('renders subtitle when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.fitness_center,
              title: 'No exercises',
              subtitle: 'Create one to get started',
            ),
          ),
        ),
      );

      expect(find.text('Create one to get started'), findsOneWidget);
    });

    testWidgets('renders action button when provided', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.fitness_center,
              title: 'No exercises',
              actionLabel: 'Add Exercise',
              onAction: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Add Exercise'), findsOneWidget);

      await tester.tap(find.text('Add Exercise'));
      expect(tapped, true);
    });
  });
}
