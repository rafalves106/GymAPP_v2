import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/domain/entities/training_exercise.dart';
import 'package:gym_app/presentation/providers/session_provider.dart';
import 'package:gym_app/presentation/widgets/haptic_helper.dart';

class ActiveTrainingScreen extends ConsumerStatefulWidget {
  const ActiveTrainingScreen({super.key});

  @override
  ConsumerState<ActiveTrainingScreen> createState() =>
      _ActiveTrainingScreenState();
}

class _ActiveTrainingScreenState extends ConsumerState<ActiveTrainingScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activeSessionProvider);
    final notifier = ref.read(activeSessionProvider.notifier);

    if (state.isFinished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/training-summary');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!state.hasActiveSession) {
      return const Scaffold(
        body: Center(child: Text('No active training')),
      );
    }

    final training = state.training!;
    final exercise = state.currentExerciseIndex < training.exercises.length
        ? training.exercises[state.currentExerciseIndex]
        : null;

    if (exercise == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/training-summary');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final completedSets =
        state.session?.progressFor(exercise.exerciseId)?.completedSets ?? 0;
    final totalSetsForExercise = exercise.series;
    final isPaused = !state.isRunning;

    return Scaffold(
      appBar: AppBar(
        title: Text(isPaused ? 'Paused' : 'Active Training'),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.xmark),
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
              notifier.cancelSession();
              context.go('/home/work/today');
            }
          },
        ),
        actions: [
          if (isPaused)
            IconButton(
              icon: const Icon(CupertinoIcons.play_fill),
              onPressed: () {
                HapticFeedbackHelper.light();
                notifier.resumeSession();
              },
            )
          else
            IconButton(
              icon: const Icon(CupertinoIcons.pause_fill),
              onPressed: () {
                HapticFeedbackHelper.light();
                notifier.pauseSession();
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _ElapsedTimeHeader(
              elapsedTime: state.elapsedTime,
              isPaused: isPaused,
            ),
            const SizedBox(height: 16),
            _ActiveExerciseCard(
              exercise: exercise,
              completedSets: completedSets,
              totalSets: totalSetsForExercise,
              isResting: state.isResting,
              restTimeRemaining: state.restTimeRemaining,
              isPaused: isPaused,
              onCompleteSet: isPaused
                  ? null
                  : () {
                      HapticFeedbackHelper.success();
                      notifier.incrementSet();
                    },
              onDecrementSet: isPaused
                  ? null
                  : () {
                      HapticFeedbackHelper.light();
                      notifier.decrementSet();
                    },
              onSkipRest: isPaused
                  ? null
                  : () {
                      HapticFeedbackHelper.light();
                      notifier.skipRest();
                    },
            ),
            const SizedBox(height: 16),
            _ProgressBar(
              completedSets: completedSets,
              totalSets: totalSetsForExercise,
              exerciseIndex: state.currentExerciseIndex,
              totalExercises: training.exercises.length,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _NextExercisesSection(
                exercises: training.exercises,
                currentIndex: state.currentExerciseIndex,
                session: state.session,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ElapsedTimeHeader extends StatelessWidget {
  final Duration elapsedTime;
  final bool isPaused;

  const _ElapsedTimeHeader({
    required this.elapsedTime,
    required this.isPaused,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: isPaused
          ? colorScheme.errorContainer.withValues(alpha: 0.3)
          : colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isPaused) ...[
            Icon(
              CupertinoIcons.pause_circle_fill,
              color: colorScheme.error,
              size: 16,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            _formatDuration(elapsedTime),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isPaused ? colorScheme.error : null,
            ),
          ),
        ],
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

class _ActiveExerciseCard extends StatelessWidget {
  final TrainingExercise exercise;
  final int completedSets;
  final int totalSets;
  final bool isResting;
  final int restTimeRemaining;
  final bool isPaused;
  final VoidCallback? onCompleteSet;
  final VoidCallback? onDecrementSet;
  final VoidCallback? onSkipRest;

  const _ActiveExerciseCard({
    required this.exercise,
    required this.completedSets,
    required this.totalSets,
    required this.isResting,
    required this.restTimeRemaining,
    required this.isPaused,
    this.onCompleteSet,
    this.onDecrementSet,
    this.onSkipRest,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  exercise.exerciseName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${exercise.reps} reps',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SetCounterButton(
                      icon: CupertinoIcons.minus,
                      onPressed: onDecrementSet,
                      enabled: completedSets > 0 && !isPaused,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      children: [
                        Text(
                          '$completedSets',
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        Text(
                          'of $totalSets sets',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    _SetCounterButton(
                      icon: CupertinoIcons.plus,
                      onPressed: onCompleteSet,
                      enabled: completedSets < totalSets && !isPaused,
                      isPrimary: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isResting) ...[
            const SizedBox(height: 12),
            _RestTimer(
              remaining: restTimeRemaining,
              total: exercise.restTime,
              onSkip: onSkipRest,
            ),
          ],
        ],
      ),
    );
  }
}

class _SetCounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool isPrimary;

  const _SetCounterButton({
    required this.icon,
    this.onPressed,
    this.enabled = true,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: enabled
              ? (isPrimary
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerHigh)
              : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: enabled
                ? (isPrimary
                    ? colorScheme.primary
                    : colorScheme.outlineVariant)
                : colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Icon(
          icon,
          color: enabled
              ? (isPrimary ? colorScheme.onPrimary : colorScheme.onSurface)
              : colorScheme.onSurface.withValues(alpha: 0.3),
          size: 24,
        ),
      ),
    );
  }
}

class _RestTimer extends StatelessWidget {
  final int remaining;
  final int total;
  final VoidCallback? onSkip;

  const _RestTimer({
    required this.remaining,
    required this.total,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = total > 0 ? remaining / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Rest',
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    backgroundColor: colorScheme.primaryContainer,
                    color: colorScheme.primary,
                  ),
                ),
                Text(
                  '${remaining}s',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 120,
            height: 36,
            child: OutlinedButton(
              onPressed: onSkip,
              child: const Text('Skip'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int completedSets;
  final int totalSets;
  final int exerciseIndex;
  final int totalExercises;

  const _ProgressBar({
    required this.completedSets,
    required this.totalSets,
    required this.exerciseIndex,
    required this.totalExercises,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final totalAllSets = totalExercises * totalSets;
    final completedAllSets = exerciseIndex * totalSets + completedSets;
    final percentage =
        totalAllSets > 0 ? (completedAllSets / totalAllSets * 100).round() : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Exercise ${exerciseIndex + 1} of $totalExercises',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '$completedAllSets / $totalAllSets sets ($percentage%)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: totalAllSets > 0 ? completedAllSets / totalAllSets : 0,
              minHeight: 6,
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }
}

class _NextExercisesSection extends StatelessWidget {
  final List<TrainingExercise> exercises;
  final int currentIndex;
  final dynamic session;

  const _NextExercisesSection({
    required this.exercises,
    required this.currentIndex,
    this.session,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final nextExercises = exercises
        .asMap()
        .entries
        .where((e) => e.key > currentIndex)
        .toList();

    if (nextExercises.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Next',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: nextExercises.length,
              itemBuilder: (context, index) {
                final entry = nextExercises[index];
                final exercise = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: colorScheme.surfaceContainerHigh,
                          child: Text(
                            '${entry.key + 1}',
                            style: theme.textTheme.labelSmall,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise.exerciseName,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${exercise.series}×${exercise.reps}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
