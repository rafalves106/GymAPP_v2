import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/domain/enums/difficulty_level.dart';
import 'package:gym_app/presentation/widgets/difficulty_badge.dart';

void main() {
  group('DifficultyBadge', () {
    testWidgets('renders beginner badge', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DifficultyBadge(level: DifficultyLevel.beginner),
          ),
        ),
      );
      expect(find.text('Beginner'), findsOneWidget);
    });

    testWidgets('renders intermediate badge', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DifficultyBadge(level: DifficultyLevel.intermediate),
          ),
        ),
      );
      expect(find.text('Intermediate'), findsOneWidget);
    });

    testWidgets('renders advanced badge', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DifficultyBadge(level: DifficultyLevel.advanced),
          ),
        ),
      );
      expect(find.text('Advanced'), findsOneWidget);
    });
  });
}
