enum SessionStatus {
  running,
  paused,
  completed,
  cancelled;

  String get label {
    switch (this) {
      case SessionStatus.running:
        return 'Running';
      case SessionStatus.paused:
        return 'Paused';
      case SessionStatus.completed:
        return 'Completed';
      case SessionStatus.cancelled:
        return 'Cancelled';
    }
  }

  static SessionStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'running':
        return SessionStatus.running;
      case 'paused':
        return SessionStatus.paused;
      case 'completed':
        return SessionStatus.completed;
      case 'cancelled':
        return SessionStatus.cancelled;
      default:
        return SessionStatus.running;
    }
  }
}

class ExerciseProgress {
  final String exerciseId;
  final int completedSets;

  const ExerciseProgress({
    required this.exerciseId,
    required this.completedSets,
  });

  ExerciseProgress copyWith({int? completedSets}) {
    return ExerciseProgress(
      exerciseId: exerciseId,
      completedSets: completedSets ?? this.completedSets,
    );
  }
}

class Session {
  final String id;
  final String trainingId;
  final SessionStatus status;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final List<ExerciseProgress> progress;

  const Session({
    required this.id,
    required this.trainingId,
    required this.status,
    required this.startedAt,
    this.finishedAt,
    this.progress = const [],
  });

  int get completedSetsTotal =>
      progress.fold(0, (sum, p) => sum + p.completedSets);

  ExerciseProgress? progressFor(String exerciseId) {
    try {
      return progress.firstWhere((p) => p.exerciseId == exerciseId);
    } catch (_) {
      return null;
    }
  }

  Session copyWith({
    String? id,
    String? trainingId,
    SessionStatus? status,
    DateTime? startedAt,
    DateTime? finishedAt,
    bool clearFinishedAt = false,
    List<ExerciseProgress>? progress,
  }) {
    return Session(
      id: id ?? this.id,
      trainingId: trainingId ?? this.trainingId,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      finishedAt:
          clearFinishedAt ? null : (finishedAt ?? this.finishedAt),
      progress: progress ?? this.progress,
    );
  }
}
