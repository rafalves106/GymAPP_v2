import 'package:flutter/material.dart';
import 'package:gym_app/domain/enums/muscle_group_type.dart';

class MuscleGroupChip extends StatelessWidget {
  final MuscleGroupType muscleGroup;
  const MuscleGroupChip({super.key, required this.muscleGroup});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(muscleGroup.label),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }
}
