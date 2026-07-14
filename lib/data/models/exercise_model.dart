import 'package:gym_app/domain/enums/muscle_group_type.dart';
import 'package:gym_app/domain/enums/difficulty_level.dart';
import 'package:gym_app/domain/enums/equipment_type.dart';
import 'package:gym_app/domain/entities/exercise.dart';

class ExerciseModel extends Exercise {
  const ExerciseModel({
    required super.id,
    required super.name,
    required super.description,
    required super.muscleGroups,
    required super.equipments,
    required super.difficultyLevel,
    super.videoUrl,
    super.externalApiId,
    required super.createdAt,
    super.updatedAt,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      muscleGroups: (json['muscleGroups'] as List?)
              ?.map((e) => MuscleGroupTypeX.fromApiValue(e as int))
              .toList() ??
          [],
      equipments: (json['equipments'] as List?)
              ?.map((e) => EquipmentTypeX.fromApiValue(e as int))
              .toList() ??
          [],
      difficultyLevel: DifficultyLevelX.fromApiValue(
        json['difficultyLevel'] as int? ?? 1,
      ),
      videoUrl: json['videoUrl'] as String?,
      externalApiId: json['externalApiId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'muscleGroups': muscleGroups.map((e) => e.apiValue).toList(),
      'equipments': equipments.map((e) => e.apiValue).toList(),
      'difficultyLevel': difficultyLevel.apiValue,
      if (videoUrl != null) 'videoUrl': videoUrl,
      if (externalApiId != null) 'externalApiId': externalApiId,
    };
  }

  factory ExerciseModel.fromEntity(Exercise entity) {
    return ExerciseModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      muscleGroups: entity.muscleGroups,
      equipments: entity.equipments,
      difficultyLevel: entity.difficultyLevel,
      videoUrl: entity.videoUrl,
      externalApiId: entity.externalApiId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
