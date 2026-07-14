import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/presentation/providers/exercises_provider.dart';
import 'package:gym_app/domain/enums/muscle_group_type.dart';
import 'package:gym_app/domain/enums/difficulty_level.dart';

void main() {
  group('ExerciseFilter', () {
    test('initial filter has no values', () {
      const filter = ExerciseFilter();
      expect(filter.muscleGroup, isNull);
      expect(filter.difficulty, isNull);
      expect(filter.searchQuery, isNull);
    });

    test('copyWith updates values', () {
      const filter = ExerciseFilter();
      final updated = filter.copyWith(
        muscleGroup: MuscleGroupType.chest,
        difficulty: DifficultyLevel.advanced,
        searchQuery: 'bench',
      );

      expect(updated.muscleGroup, MuscleGroupType.chest);
      expect(updated.difficulty, DifficultyLevel.advanced);
      expect(updated.searchQuery, 'bench');
    });

    test('copyWith clears values', () {
      const filter = ExerciseFilter(
        muscleGroup: MuscleGroupType.chest,
        difficulty: DifficultyLevel.advanced,
        searchQuery: 'bench',
      );

      final cleared = filter.copyWith(
        clearMuscleGroup: true,
        clearDifficulty: true,
        clearSearchQuery: true,
      );

      expect(cleared.muscleGroup, isNull);
      expect(cleared.difficulty, isNull);
      expect(cleared.searchQuery, isNull);
    });
  });
}
