import 'package:gym_app/domain/entities/training.dart';
import 'training_exercise_model.dart';

class TrainingModel extends Training {
  const TrainingModel({
    required super.id,
    required super.name,
    super.description,
    required super.exercises,
    super.scheduledDay,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TrainingModel.fromJson(Map<String, dynamic> json) {
    return TrainingModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      exercises: (json['exercises'] as List?)
              ?.map((e) => TrainingExerciseModel.fromJson(e))
              .toList() ??
          [],
      scheduledDay: Training.apiDayToFlutter(json['scheduledDay'] as int?),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'exercises': exercises
          .map((e) => TrainingExerciseModel.fromEntity(e).toJson())
          .toList(),
    };
  }

  Map<String, dynamic> toFullJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'scheduledDay': scheduledDay,
      'exercises': exercises
          .map((e) => TrainingExerciseModel.fromEntity(e).toJson())
          .toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TrainingModel.fromEntity(Training entity) {
    return TrainingModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      exercises: entity.exercises,
      scheduledDay: entity.scheduledDay,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
