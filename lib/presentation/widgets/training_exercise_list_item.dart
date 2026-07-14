import 'package:flutter/material.dart';
import 'package:gym_app/domain/entities/training_exercise.dart';

class TrainingExerciseListItem extends StatelessWidget {
  final TrainingExercise exercise;
  final int index;
  final VoidCallback? onDelete;

  const TrainingExerciseListItem({
    super.key,
    required this.exercise,
    required this.index,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text('${index + 1}')),
        title: Text(exercise.exerciseName),
        subtitle: Text(
          '${exercise.series} × ${exercise.reps} reps • ${exercise.restTime}s rest',
        ),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: onDelete,
              )
            : null,
      ),
    );
  }
}
