import 'package:gym_app/domain/entities/training_exercise.dart';

class TrainingExerciseModel extends TrainingExercise {
  const TrainingExerciseModel({
    required super.exerciseId,
    required super.exerciseName,
    required super.orderIndex,
    required super.restTime,
    required super.reps,
    required super.series,
  });

  factory TrainingExerciseModel.fromJson(Map<String, dynamic> json) {
    return TrainingExerciseModel(
      exerciseId: json['exerciseId'] as String? ?? json['id'] as String? ?? '',
      exerciseName: json['exerciseName'] as String? ?? json['name'] as String? ?? '',
      orderIndex: json['orderIndex'] as int? ?? json['order'] as int? ?? 0,
      restTime: json['restTime'] as int? ?? json['restSeconds'] as int? ?? 0,
      reps: json['reps'] as int? ?? json['targetReps'] as int? ?? 0,
      series: json['series'] as int? ?? json['targetSets'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': exerciseName,
      'targetSets': series,
      'targetReps': reps,
      'restSeconds': restTime,
    };
  }

  factory TrainingExerciseModel.fromEntity(TrainingExercise entity) {
    return TrainingExerciseModel(
      exerciseId: entity.exerciseId,
      exerciseName: entity.exerciseName,
      orderIndex: entity.orderIndex,
      restTime: entity.restTime,
      reps: entity.reps,
      series: entity.series,
    );
  }
}
