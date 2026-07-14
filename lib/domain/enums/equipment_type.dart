enum EquipmentType {
  barbell,
  dumbbell,
  kettlebell,
  machine,
  cable,
  resistanceBand,
  pullUpBar,
  bench,
  smithMachine,
  bodyweight,
  medicineBall,
  foamRoller,
}

extension EquipmentTypeX on EquipmentType {
  int get apiValue => index + 1;

  static EquipmentType fromApiValue(int value) =>
      EquipmentType.values[value - 1];

  String get label {
    switch (this) {
      case EquipmentType.barbell:
        return 'Barbell';
      case EquipmentType.dumbbell:
        return 'Dumbbell';
      case EquipmentType.kettlebell:
        return 'Kettlebell';
      case EquipmentType.machine:
        return 'Machine';
      case EquipmentType.cable:
        return 'Cable';
      case EquipmentType.resistanceBand:
        return 'Resistance Band';
      case EquipmentType.pullUpBar:
        return 'Pull Up Bar';
      case EquipmentType.bench:
        return 'Bench';
      case EquipmentType.smithMachine:
        return 'Smith Machine';
      case EquipmentType.bodyweight:
        return 'Bodyweight';
      case EquipmentType.medicineBall:
        return 'Medicine Ball';
      case EquipmentType.foamRoller:
        return 'Foam Roller';
    }
  }
}
