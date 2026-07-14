enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
}

extension DifficultyLevelX on DifficultyLevel {
  int get apiValue => index + 1;

  static DifficultyLevel fromApiValue(int value) =>
      DifficultyLevel.values[value - 1];

  String get label {
    switch (this) {
      case DifficultyLevel.beginner:
        return 'Beginner';
      case DifficultyLevel.intermediate:
        return 'Intermediate';
      case DifficultyLevel.advanced:
        return 'Advanced';
    }
  }
}
