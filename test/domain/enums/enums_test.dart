import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/domain/enums/muscle_group_type.dart';
import 'package:gym_app/domain/enums/difficulty_level.dart';
import 'package:gym_app/domain/enums/equipment_type.dart';

void main() {
  group('MuscleGroupType', () {
    test('label returns correct display name', () {
      expect(MuscleGroupType.chest.label, 'Chest');
      expect(MuscleGroupType.fullBody.label, 'Full Body');
    });
  });

  group('DifficultyLevel', () {
    test('label returns correct display name', () {
      expect(DifficultyLevel.beginner.label, 'Beginner');
      expect(DifficultyLevel.intermediate.label, 'Intermediate');
      expect(DifficultyLevel.advanced.label, 'Advanced');
    });
  });

  group('EquipmentType', () {
    test('label returns correct display name', () {
      expect(EquipmentType.barbell.label, 'Barbell');
      expect(EquipmentType.bodyweight.label, 'Bodyweight');
      expect(EquipmentType.kettlebell.label, 'Kettlebell');
    });

    test('apiValue returns 1-indexed integer matching backend', () {
      expect(EquipmentType.barbell.apiValue, 1);
      expect(EquipmentType.dumbbell.apiValue, 2);
      expect(EquipmentType.kettlebell.apiValue, 3);
      expect(EquipmentType.machine.apiValue, 4);
      expect(EquipmentType.cable.apiValue, 5);
      expect(EquipmentType.resistanceBand.apiValue, 6);
      expect(EquipmentType.pullUpBar.apiValue, 7);
      expect(EquipmentType.bench.apiValue, 8);
      expect(EquipmentType.smithMachine.apiValue, 9);
      expect(EquipmentType.bodyweight.apiValue, 10);
      expect(EquipmentType.medicineBall.apiValue, 11);
      expect(EquipmentType.foamRoller.apiValue, 12);
    });
  });

  group('MuscleGroupType apiValue', () {
    test('returns 1-indexed integer matching backend', () {
      expect(MuscleGroupType.chest.apiValue, 1);
      expect(MuscleGroupType.back.apiValue, 2);
      expect(MuscleGroupType.shoulders.apiValue, 3);
      expect(MuscleGroupType.biceps.apiValue, 4);
      expect(MuscleGroupType.triceps.apiValue, 5);
      expect(MuscleGroupType.forearms.apiValue, 6);
      expect(MuscleGroupType.core.apiValue, 7);
      expect(MuscleGroupType.quadriceps.apiValue, 8);
      expect(MuscleGroupType.hamstrings.apiValue, 9);
      expect(MuscleGroupType.glutes.apiValue, 10);
      expect(MuscleGroupType.calves.apiValue, 11);
      expect(MuscleGroupType.fullBody.apiValue, 12);
    });
  });

  group('DifficultyLevel apiValue', () {
    test('returns 1-indexed integer matching backend', () {
      expect(DifficultyLevel.beginner.apiValue, 1);
      expect(DifficultyLevel.intermediate.apiValue, 2);
      expect(DifficultyLevel.advanced.apiValue, 3);
    });
  });
}
