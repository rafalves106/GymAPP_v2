import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/presentation/providers/active_training_provider.dart';
import 'package:gym_app/presentation/widgets/haptic_helper.dart';

class ActiveTrainingScreen extends ConsumerWidget {
  const ActiveTrainingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activeTrainingProvider);
    final notifier = ref.read(activeTrainingProvider.notifier);

    if (state.isFinished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/training-summary');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final exercise = state.currentExercise;
    if (exercise == null) {
      return const Scaffold(
        body: Center(child: Text('No active training')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Training'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('End Training?'),
                content: const Text('Are you sure you want to end this training?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('End'),
                  ),
                ],
              ),
            );
            if (confirmed == true && context.mounted) {
              notifier.reset();
              context.go('/home/work/exercises');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Elapsed time
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                _formatDuration(state.elapsedTime),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            // Exercise info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    exercise.exerciseName,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Set ${state.currentSet} of ${exercise.series}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${exercise.reps} reps',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Rest timer or complete button
            if (state.isResting)
              Column(
                children: [
                  Text(
                    'Rest: ${state.restTimeRemaining}s',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 200,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        HapticFeedbackHelper.light();
                        notifier.skipRest();
                      },
                      child: const Text('Skip Rest'),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: 200,
                height: 72,
                child: FilledButton(
                  onPressed: () {
                    HapticFeedbackHelper.success();
                    notifier.completeSet();
                  },
                  child: const Text(
                    'Complete Set',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            const Spacer(),
            // Exercise progress
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  exercise.series,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      index < state.currentSet
                          ? Icons.check_circle
                          :                       Icons.radio_button_unchecked,
                      color: index < state.currentSet
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
