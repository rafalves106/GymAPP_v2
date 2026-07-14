enum MuscleGroupType {
  chest,
  back,
  shoulders,
  biceps,
  triceps,
  forearms,
  core,
  quadriceps,
  hamstrings,
  glutes,
  calves,
  fullBody,
}

extension MuscleGroupTypeX on MuscleGroupType {
  int get apiValue => index + 1;

  static MuscleGroupType fromApiValue(int value) =>
      MuscleGroupType.values[value - 1];

  String get label {
    switch (this) {
      case MuscleGroupType.chest:
        return 'Chest';
      case MuscleGroupType.back:
        return 'Back';
      case MuscleGroupType.shoulders:
        return 'Shoulders';
      case MuscleGroupType.biceps:
        return 'Biceps';
      case MuscleGroupType.triceps:
        return 'Triceps';
      case MuscleGroupType.forearms:
        return 'Forearms';
      case MuscleGroupType.core:
        return 'Core';
      case MuscleGroupType.quadriceps:
        return 'Quadriceps';
      case MuscleGroupType.hamstrings:
        return 'Hamstrings';
      case MuscleGroupType.glutes:
        return 'Glutes';
      case MuscleGroupType.calves:
        return 'Calves';
      case MuscleGroupType.fullBody:
        return 'Full Body';
    }
  }
}
