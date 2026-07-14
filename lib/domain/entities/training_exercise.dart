class TrainingExercise {
  final String exerciseId;
  final String exerciseName;
  final int orderIndex;
  final int restTime;
  final int reps;
  final int series;

  const TrainingExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.orderIndex,
    required this.restTime,
    required this.reps,
    required this.series,
  });

  TrainingExercise copyWith({
    String? exerciseId,
    String? exerciseName,
    int? orderIndex,
    int? restTime,
    int? reps,
    int? series,
  }) {
    return TrainingExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      orderIndex: orderIndex ?? this.orderIndex,
      restTime: restTime ?? this.restTime,
      reps: reps ?? this.reps,
      series: series ?? this.series,
    );
  }

  static int validateRestTime(int value) => value.clamp(0, 120);
  static int validateReps(int value) => value.clamp(1, 30);
  static int validateSeries(int value) => value.clamp(1, 15);
}
