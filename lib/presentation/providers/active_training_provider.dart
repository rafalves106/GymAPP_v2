import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_app/domain/entities/training_exercise.dart';

final activeTrainingProvider =
    StateNotifierProvider<ActiveTrainingNotifier, ActiveTrainingState>(
  (ref) => ActiveTrainingNotifier(),
);

class ActiveTrainingState {
  final List<TrainingExercise> exercises;
  final int currentExerciseIndex;
  final int currentSet;
  final bool isResting;
  final int restTimeRemaining;
  final Duration elapsedTime;
  final bool isRunning;

  const ActiveTrainingState({
    this.exercises = const [],
    this.currentExerciseIndex = 0,
    this.currentSet = 1,
    this.isResting = false,
    this.restTimeRemaining = 0,
    this.elapsedTime = Duration.zero,
    this.isRunning = false,
  });

  TrainingExercise? get currentExercise =>
      exercises.isNotEmpty && currentExerciseIndex < exercises.length
          ? exercises[currentExerciseIndex]
          : null;

  bool get isFinished =>
      exercises.isNotEmpty && currentExerciseIndex >= exercises.length;

  ActiveTrainingState copyWith({
    List<TrainingExercise>? exercises,
    int? currentExerciseIndex,
    int? currentSet,
    bool? isResting,
    int? restTimeRemaining,
    Duration? elapsedTime,
    bool? isRunning,
  }) {
    return ActiveTrainingState(
      exercises: exercises ?? this.exercises,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      currentSet: currentSet ?? this.currentSet,
      isResting: isResting ?? this.isResting,
      restTimeRemaining: restTimeRemaining ?? this.restTimeRemaining,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}

class ActiveTrainingNotifier extends StateNotifier<ActiveTrainingState> {
  Timer? _elapsedTimer;
  Timer? _restTimer;

  ActiveTrainingNotifier() : super(const ActiveTrainingState());

  void startTraining(List<TrainingExercise> exercises) {
    _cancelTimers();
    state = ActiveTrainingState(
      exercises: exercises,
      isRunning: true,
    );
    _startElapsedTimer();
  }

  void completeSet() {
    final exercise = state.currentExercise;
    if (exercise == null) return;

    if (state.currentSet < exercise.series) {
      state = state.copyWith(
        currentSet: state.currentSet + 1,
        isResting: true,
        restTimeRemaining: exercise.restTime,
      );
      _startRestTimer();
    } else {
      _moveToNextExercise();
    }
  }

  void skipRest() {
    _restTimer?.cancel();
    state = state.copyWith(
      isResting: false,
      restTimeRemaining: 0,
    );
  }

  void _moveToNextExercise() {
    final nextIndex = state.currentExerciseIndex + 1;
    if (nextIndex >= state.exercises.length) {
      _cancelTimers();
      state = state.copyWith(
        currentExerciseIndex: nextIndex,
        isRunning: false,
      );
    } else {
      state = state.copyWith(
        currentExerciseIndex: nextIndex,
        currentSet: 1,
        isResting: false,
        restTimeRemaining: 0,
      );
    }
  }

  void _startElapsedTimer() {
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(
        elapsedTime: state.elapsedTime + const Duration(seconds: 1),
      );
    });
  }

  void _startRestTimer() {
    _restTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.restTimeRemaining <= 1) {
        _restTimer?.cancel();
        state = state.copyWith(
          isResting: false,
          restTimeRemaining: 0,
        );
      } else {
        state = state.copyWith(
          restTimeRemaining: state.restTimeRemaining - 1,
        );
      }
    });
  }

  void _cancelTimers() {
    _elapsedTimer?.cancel();
    _restTimer?.cancel();
  }

  void reset() {
    _cancelTimers();
    state = const ActiveTrainingState();
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }
}
