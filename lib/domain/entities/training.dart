import 'training_exercise.dart';

class Training {
  final String id;
  final String name;
  final String? description;
  final List<TrainingExercise> exercises;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Training({
    required this.id,
    required this.name,
    this.description,
    required this.exercises,
    required this.createdAt,
    required this.updatedAt,
  });

  Training copyWith({
    String? id,
    String? name,
    String? description,
    List<TrainingExercise>? exercises,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Training(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static const int maxExercises = 10;
}
