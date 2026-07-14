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
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      orderIndex: json['orderIndex'] as int,
      restTime: json['restTime'] as int,
      reps: json['reps'] as int,
      series: json['series'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'orderIndex': orderIndex,
      'restTime': restTime,
      'reps': reps,
      'series': series,
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
