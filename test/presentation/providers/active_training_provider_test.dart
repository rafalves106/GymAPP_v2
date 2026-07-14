import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/presentation/providers/active_training_provider.dart';
import 'package:gym_app/domain/entities/training_exercise.dart';

void main() {
  group('ActiveTrainingNotifier', () {
    late ActiveTrainingNotifier notifier;

    setUp(() {
      notifier = ActiveTrainingNotifier();
    });

    final exercises = [
      const TrainingExercise(
        exerciseId: '1',
        exerciseName: 'Bench Press',
        orderIndex: 0,
        restTime: 60,
        reps: 10,
        series: 3,
      ),
      const TrainingExercise(
        exerciseId: '2',
        exerciseName: 'Squat',
        orderIndex: 1,
        restTime: 90,
        reps: 8,
        series: 3,
      ),
    ];

    test('initial state is empty', () {
      expect(notifier.state.isRunning, false);
      expect(notifier.state.exercises, isEmpty);
    });

    test('startTraining sets exercises and starts timer', () {
      notifier.startTraining(exercises);
      expect(notifier.state.isRunning, true);
      expect(notifier.state.exercises.length, 2);
      expect(notifier.state.currentExerciseIndex, 0);
      expect(notifier.state.currentSet, 1);
    });

    test('completeSet increments set and starts rest', () {
      notifier.startTraining(exercises);
      notifier.completeSet();

      expect(notifier.state.currentSet, 2);
      expect(notifier.state.isResting, true);
      expect(notifier.state.restTimeRemaining, 60);
    });

    test('completeSet on last set moves to next exercise', () {
      notifier.startTraining(exercises);

      notifier.completeSet();
      notifier.skipRest();
      notifier.completeSet();
      notifier.skipRest();
      notifier.completeSet();

      expect(notifier.state.currentExerciseIndex, 1);
      expect(notifier.state.currentSet, 1);
    });

    test('completeSet on last exercise finishes training', () {
      notifier.startTraining([
        const TrainingExercise(
          exerciseId: '1',
          exerciseName: 'Bench',
          orderIndex: 0,
          restTime: 0,
          reps: 10,
          series: 1,
        ),
      ]);

      notifier.completeSet();

      expect(notifier.state.isFinished, true);
      expect(notifier.state.isRunning, false);
    });

    test('reset clears state', () {
      notifier.startTraining(exercises);
      notifier.reset();

      expect(notifier.state.isRunning, false);
      expect(notifier.state.exercises, isEmpty);
    });
  });
}
