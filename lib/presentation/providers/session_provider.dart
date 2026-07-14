import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_app/app.dart';
import 'package:gym_app/domain/entities/session.dart';
import 'package:gym_app/data/models/session_model.dart';
import 'package:gym_app/data/models/training_model.dart';
import 'package:gym_app/data/repositories/session_repository.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(apiClient: ref.watch(apiClientProvider));
});

class ActiveSessionState {
  final Session? session;
  final TrainingModel? training;
  final int currentExerciseIndex;
  final bool isResting;
  final int restTimeRemaining;
  final Duration elapsedTime;
  final bool isRunning;
  final Timer? _timer;
  final Timer? _restTimer;

  const ActiveSessionState({
    this.session,
    this.training,
    this.currentExerciseIndex = 0,
    this.isResting = false,
    this.restTimeRemaining = 0,
    this.elapsedTime = Duration.zero,
    this.isRunning = false,
    Timer? timer,
    Timer? restTimer,
  })  : _timer = timer,
        _restTimer = restTimer;

  bool get hasActiveSession => session != null && training != null;

  bool get isFinished {
    if (training == null || session == null) return false;
    return currentExerciseIndex >= training!.exercises.length;
  }

  int get totalExercises => training?.exercises.length ?? 0;

  ActiveSessionState copyWith({
    Session? session,
    TrainingModel? training,
    int? currentExerciseIndex,
    bool? isResting,
    int? restTimeRemaining,
    Duration? elapsedTime,
    bool? isRunning,
    Timer? timer,
    Timer? restTimer,
    bool clearSession = false,
    bool clearTimer = false,
    bool clearRestTimer = false,
  }) {
    return ActiveSessionState(
      session: clearSession ? null : (session ?? this.session),
      training: clearSession ? null : (training ?? this.training),
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      isResting: isResting ?? this.isResting,
      restTimeRemaining: restTimeRemaining ?? this.restTimeRemaining,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      isRunning: isRunning ?? this.isRunning,
      timer: clearTimer ? null : (timer ?? _timer),
      restTimer: clearRestTimer ? null : (restTimer ?? _restTimer),
    );
  }
}

class ActiveSessionNotifier extends StateNotifier<ActiveSessionState> {
  final Ref _ref;

  ActiveSessionNotifier(this._ref) : super(const ActiveSessionState());

  Future<void> startSession(TrainingModel training) async {
    try {
      final repo = _ref.read(sessionRepositoryProvider);
      final session = await repo.start(training.id);
      state = state.copyWith(
        session: session,
        training: training,
        currentExerciseIndex: 0,
        isRunning: true,
        elapsedTime: Duration.zero,
        clearTimer: false,
      );
      _startElapsedTimer();
    } catch (e) {
      state = state.copyWith(
        session: SessionModel(
          id: 'local-${DateTime.now().millisecondsSinceEpoch}',
          trainingId: training.id,
          status: SessionStatus.running,
          startedAt: DateTime.now(),
          progress: [],
        ),
        training: training,
        currentExerciseIndex: 0,
        isRunning: true,
        elapsedTime: Duration.zero,
      );
      _startElapsedTimer();
    }
  }

  void _startElapsedTimer() {
    state._timer?.cancel();
    final timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.isRunning) {
        state = state.copyWith(
          elapsedTime: state.elapsedTime + const Duration(seconds: 1),
        );
      }
    });
    state = state.copyWith(timer: timer);
  }

  Future<void> incrementSet() async {
    if (training == null || session == null) return;

    final exercise = training!.exercises[state.currentExerciseIndex];
    final repo = _ref.read(sessionRepositoryProvider);

    try {
      final updated = await repo.incrementSet(session!.id, exercise.exerciseId);
      state = state.copyWith(session: updated);
    } catch (_) {
      final currentProgress = session!.progressFor(exercise.exerciseId);
      final newCompleted = (currentProgress?.completedSets ?? 0) + 1;
      final newProgress = List<ExerciseProgress>.from(session!.progress);
      final existingIndex =
          newProgress.indexWhere((p) => p.exerciseId == exercise.exerciseId);
      if (existingIndex >= 0) {
        newProgress[existingIndex] = newProgress[existingIndex]
            .copyWith(completedSets: newCompleted);
      } else {
        newProgress.add(ExerciseProgress(
          exerciseId: exercise.exerciseId,
          completedSets: newCompleted,
        ));
      }
      state = state.copyWith(
        session: SessionModel.fromEntity(
          session!.copyWith(progress: newProgress),
        ),
      );
    }

    final completedSets =
        session!.progressFor(exercise.exerciseId)?.completedSets ?? 0;
    if (completedSets >= exercise.series) {
      _moveToNextExercise();
    } else {
      _startRestTimer(exercise.restTime);
    }
  }

  Future<void> decrementSet() async {
    if (training == null || session == null) return;

    final exercise = training!.exercises[state.currentExerciseIndex];
    final repo = _ref.read(sessionRepositoryProvider);

    try {
      final updated = await repo.decrementSet(session!.id, exercise.exerciseId);
      state = state.copyWith(session: updated);
    } catch (_) {
      final currentProgress = session!.progressFor(exercise.exerciseId);
      final newCompleted =
          (currentProgress?.completedSets ?? 1) - 1;
      if (newCompleted < 0) return;
      final newProgress = List<ExerciseProgress>.from(session!.progress);
      final existingIndex =
          newProgress.indexWhere((p) => p.exerciseId == exercise.exerciseId);
      if (existingIndex >= 0) {
        newProgress[existingIndex] = newProgress[existingIndex]
            .copyWith(completedSets: newCompleted);
      }
      state = state.copyWith(
        session: SessionModel.fromEntity(
          session!.copyWith(progress: newProgress),
        ),
      );
    }
  }

  void _startRestTimer(int seconds) {
    state._restTimer?.cancel();
    state = state.copyWith(
      isResting: true,
      restTimeRemaining: seconds,
      clearRestTimer: false,
    );
    final restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.restTimeRemaining <= 1) {
        timer.cancel();
        state = state.copyWith(
          isResting: false,
          restTimeRemaining: 0,
          clearRestTimer: true,
        );
      } else {
        state = state.copyWith(
          restTimeRemaining: state.restTimeRemaining - 1,
        );
      }
    });
    state = state.copyWith(restTimer: restTimer);
  }

  void skipRest() {
    state._restTimer?.cancel();
    state = state.copyWith(
      isResting: false,
      restTimeRemaining: 0,
      clearRestTimer: true,
    );
  }

  void _moveToNextExercise() {
    final nextIndex = state.currentExerciseIndex + 1;
    if (nextIndex >= (training?.exercises.length ?? 0)) {
      state = state.copyWith(currentExerciseIndex: nextIndex);
    } else {
      state = state.copyWith(
        currentExerciseIndex: nextIndex,
        isResting: false,
        restTimeRemaining: 0,
        clearRestTimer: true,
      );
    }
  }

  Future<void> pauseSession() async {
    if (session == null) return;
    try {
      final repo = _ref.read(sessionRepositoryProvider);
      final updated = await repo.pause(session!.id);
      state = state.copyWith(session: updated, isRunning: false);
    } catch (_) {
      state = state.copyWith(
        session: SessionModel.fromEntity(
          session!.copyWith(status: SessionStatus.paused),
        ),
        isRunning: false,
      );
    }
  }

  Future<void> resumeSession() async {
    if (session == null) return;
    try {
      final repo = _ref.read(sessionRepositoryProvider);
      final updated = await repo.resume(session!.id);
      state = state.copyWith(session: updated, isRunning: true);
    } catch (_) {
      state = state.copyWith(
        session: SessionModel.fromEntity(
          session!.copyWith(status: SessionStatus.running),
        ),
        isRunning: true,
      );
    }
  }

  Future<void> stopSession() async {
    if (session == null) return;
    state._timer?.cancel();
    state._restTimer?.cancel();
    try {
      final repo = _ref.read(sessionRepositoryProvider);
      await repo.stop(session!.id);
    } catch (_) {}
    state = state.copyWith(
      session: SessionModel.fromEntity(
        session!.copyWith(
          status: SessionStatus.completed,
          finishedAt: DateTime.now(),
          clearFinishedAt: false,
        ),
      ),
      isRunning: false,
      clearTimer: true,
      clearRestTimer: true,
    );
  }

  Future<void> cancelSession() async {
    if (session == null) return;
    state._timer?.cancel();
    state._restTimer?.cancel();
    try {
      final repo = _ref.read(sessionRepositoryProvider);
      await repo.cancel(session!.id);
    } catch (_) {}
    state = state.copyWith(
      session: SessionModel.fromEntity(
        session!.copyWith(status: SessionStatus.cancelled),
      ),
      isRunning: false,
      clearTimer: true,
      clearRestTimer: true,
    );
  }

  void reset() {
    state._timer?.cancel();
    state._restTimer?.cancel();
    state = const ActiveSessionState();
  }

  TrainingModel? get training => state.training;
  Session? get session => state.session;
}

final activeSessionProvider =
    StateNotifierProvider<ActiveSessionNotifier, ActiveSessionState>((ref) {
  return ActiveSessionNotifier(ref);
});
