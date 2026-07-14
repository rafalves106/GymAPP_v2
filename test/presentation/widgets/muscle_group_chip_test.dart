import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/domain/enums/muscle_group_type.dart';
import 'package:gym_app/presentation/widgets/muscle_group_chip.dart';

void main() {
  group('MuscleGroupChip', () {
    testWidgets('renders muscle group label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MuscleGroupChip(muscleGroup: MuscleGroupType.chest),
          ),
        ),
      );
      expect(find.text('Chest'), findsOneWidget);
    });

    testWidgets('renders full body label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MuscleGroupChip(muscleGroup: MuscleGroupType.fullBody),
          ),
        ),
      );
      expect(find.text('Full Body'), findsOneWidget);
    });
  });
}
