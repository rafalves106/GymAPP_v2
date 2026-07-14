import 'package:gym_app/domain/entities/session.dart';

class SessionModel extends Session {
  const SessionModel({
    required super.id,
    required super.trainingId,
    required super.status,
    required super.startedAt,
    super.finishedAt,
    super.progress,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String,
      trainingId: json['workoutId'] as String? ?? json['trainingId'] as String? ?? '',
      status: SessionStatus.fromString(json['status'] as String),
      startedAt: DateTime.parse(json['startedAt'] as String),
      finishedAt: json['finishedAt'] != null
          ? DateTime.parse(json['finishedAt'] as String)
          : null,
      progress: (json['progress'] as List?)
              ?.map((e) => ExerciseProgress(
                    exerciseId: e['exerciseId'] as String,
                    completedSets: e['completedSets'] as int,
                  ))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trainingId': trainingId,
      'status': status.name,
      'startedAt': startedAt.toIso8601String(),
      'finishedAt': finishedAt?.toIso8601String(),
      'progress': progress
          .map((p) => {
                'exerciseId': p.exerciseId,
                'completedSets': p.completedSets,
              })
          .toList(),
    };
  }

  factory SessionModel.fromEntity(Session entity) {
    return SessionModel(
      id: entity.id,
      trainingId: entity.trainingId,
      status: entity.status,
      startedAt: entity.startedAt,
      finishedAt: entity.finishedAt,
      progress: entity.progress,
    );
  }
}
