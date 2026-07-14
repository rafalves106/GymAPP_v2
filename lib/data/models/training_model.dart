import 'package:gym_app/domain/entities/training.dart';
import 'training_exercise_model.dart';

class TrainingModel extends Training {
  const TrainingModel({
    required super.id,
    required super.name,
    super.description,
    required super.exercises,
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
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
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
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
