import '../enums/muscle_group_type.dart';
import '../enums/difficulty_level.dart';
import '../enums/equipment_type.dart';

class Exercise {
  final String id;
  final String name;
  final String description;
  final List<MuscleGroupType> muscleGroups;
  final List<EquipmentType> equipments;
  final DifficultyLevel difficultyLevel;
  final String? videoUrl;
  final String? externalApiId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.muscleGroups,
    required this.equipments,
    required this.difficultyLevel,
    this.videoUrl,
    this.externalApiId,
    required this.createdAt,
    this.updatedAt,
  });

  Exercise copyWith({
    String? id,
    String? name,
    String? description,
    List<MuscleGroupType>? muscleGroups,
    List<EquipmentType>? equipments,
    DifficultyLevel? difficultyLevel,
    String? videoUrl,
    String? externalApiId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      muscleGroups: muscleGroups ?? this.muscleGroups,
      equipments: equipments ?? this.equipments,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      videoUrl: videoUrl ?? this.videoUrl,
      externalApiId: externalApiId ?? this.externalApiId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
