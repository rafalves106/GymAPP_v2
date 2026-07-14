import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/domain/entities/training_exercise.dart';

void main() {
  group('TrainingExercise validation', () {
    test('validateRestTime clamps to 0-120', () {
      expect(TrainingExercise.validateRestTime(-5), 0);
      expect(TrainingExercise.validateRestTime(0), 0);
      expect(TrainingExercise.validateRestTime(60), 60);
      expect(TrainingExercise.validateRestTime(150), 120);
    });

    test('validateReps clamps to 1-30', () {
      expect(TrainingExercise.validateReps(0), 1);
      expect(TrainingExercise.validateReps(1), 1);
      expect(TrainingExercise.validateReps(15), 15);
      expect(TrainingExercise.validateReps(50), 30);
    });

    test('validateSeries clamps to 1-15', () {
      expect(TrainingExercise.validateSeries(0), 1);
      expect(TrainingExercise.validateSeries(1), 1);
      expect(TrainingExercise.validateSeries(10), 10);
      expect(TrainingExercise.validateSeries(20), 15);
    });
  });

  group('TrainingExercise copyWith', () {
    test('copies with new values', () {
      const te = TrainingExercise(
        exerciseId: '1',
        exerciseName: 'Bench',
        orderIndex: 0,
        restTime: 60,
        reps: 10,
        series: 3,
      );

      final updated = te.copyWith(reps: 12, series: 4);
      expect(updated.reps, 12);
      expect(updated.series, 4);
      expect(updated.exerciseId, '1');
    });
  });
}
