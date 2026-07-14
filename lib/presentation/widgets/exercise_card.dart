import 'package:flutter/material.dart';
import 'package:gym_app/domain/entities/exercise.dart';
import 'package:gym_app/presentation/widgets/difficulty_badge.dart';
import 'package:gym_app/presentation/widgets/muscle_group_chip.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ExerciseCard({
    super.key,
    required this.exercise,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(exercise.id),
      direction: onDelete != null ? DismissDirection.endToStart : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Theme.of(context).colorScheme.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          onTap: onTap,
          title: Text(exercise.name),
          subtitle: Row(
            children: [
              DifficultyBadge(level: exercise.difficultyLevel),
              const SizedBox(width: 8),
              if (exercise.muscleGroups.isNotEmpty)
                MuscleGroupChip(muscleGroup: exercise.muscleGroups.first),
            ],
          ),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
