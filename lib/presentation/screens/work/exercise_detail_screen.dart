import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/presentation/providers/exercises_provider.dart';
import 'package:gym_app/presentation/widgets/difficulty_badge.dart';
import 'package:gym_app/presentation/widgets/muscle_group_chip.dart';
import 'package:gym_app/presentation/widgets/haptic_helper.dart';
import 'package:gym_app/domain/enums/equipment_type.dart';

class ExerciseDetailScreen extends ConsumerWidget {
  final String id;
  const ExerciseDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercisesAsync = ref.watch(exercisesProvider);

    return exercisesAsync.when(
      data: (exercises) {
        final exercise = exercises.where((e) => e.id == id).firstOrNull;
        if (exercise == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Exercise')),
            body: const Center(child: Text('Exercise not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(exercise.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () =>
                    context.push('/home/work/exercises/$id/edit'),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Exercise'),
                      content: Text(
                          'Are you sure you want to delete "${exercise.name}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    HapticFeedbackHelper.medium();
                    ref
                        .read(exercisesProvider.notifier)
                        .deleteExercise(id);
                    if (context.mounted) context.pop();
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                DifficultyBadge(level: exercise.difficultyLevel),
                const SizedBox(height: 16),
                if (exercise.description.isNotEmpty) ...[
                  Text(
                    exercise.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  'Muscle Groups',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: exercise.muscleGroups
                      .map((mg) => MuscleGroupChip(muscleGroup: mg))
                      .toList(),
                ),
                const SizedBox(height: 16),
                Text(
                  'Equipment',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: exercise.equipments
                      .map((eq) => Chip(label: Text(eq.label)))
                      .toList(),
                ),
                if (exercise.videoUrl != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Video',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    exercise.videoUrl!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}
