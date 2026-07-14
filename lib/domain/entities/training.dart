import 'training_exercise.dart';

class Training {
  final String id;
  final String name;
  final String? description;
  final List<TrainingExercise> exercises;
  final int? scheduledDay;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Training({
    required this.id,
    required this.name,
    this.description,
    required this.exercises,
    this.scheduledDay,
    required this.createdAt,
    required this.updatedAt,
  });

  Training copyWith({
    String? id,
    String? name,
    String? description,
    List<TrainingExercise>? exercises,
    int? scheduledDay,
    bool clearScheduledDay = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Training(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      scheduledDay:
          clearScheduledDay ? null : (scheduledDay ?? this.scheduledDay),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static const int maxExercises = 10;

  static const dayLabels = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const dayLabelsShort = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  String get dayLabel {
    if (scheduledDay == null) return 'Unassigned';
    return dayLabels[scheduledDay!];
  }

  String get dayLabelShort {
    if (scheduledDay == null) return 'None';
    return dayLabelsShort[scheduledDay!];
  }

  /// Converts Flutter day (0=Monday..6=Sunday) to API/C# DayOfWeek (0=Sunday..6=Saturday).
  static int? flutterDayToApi(int? flutterDay) {
    if (flutterDay == null) return null;
    return (flutterDay + 1) % 7;
  }

  /// Converts API/C# DayOfWeek (0=Sunday..6=Saturday) to Flutter day (0=Monday..6=Sunday).
  static int? apiDayToFlutter(int? apiDay) {
    if (apiDay == null) return null;
    return (apiDay + 6) % 7;
  }
}
