import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/presentation/providers/session_provider.dart';

class TrainingSummaryScreen extends ConsumerWidget {
  const TrainingSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activeSessionProvider);
    final notifier = ref.read(activeSessionProvider.notifier);

    final training = state.training;
    final session = state.session;
    final totalTime = state.elapsedTime;
    final totalExercises = training?.exercises.length ?? 0;
    final completedSets = session?.completedSetsTotal ?? 0;
    final totalSets = training?.exercises.fold<int>(
          0,
          (sum, e) => sum + e.series,
        ) ??
        0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Training Complete'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.checkmark_circle_fill,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Great Job!',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 32),
              _StatCard(
                icon: CupertinoIcons.timer,
                label: 'Total Time',
                value: _formatDuration(totalTime),
              ),
              const SizedBox(height: 12),
              _StatCard(
                icon: CupertinoIcons.sportscourt,
                label: 'Exercises',
                value: '$totalExercises',
              ),
              const SizedBox(height: 12),
              _StatCard(
                icon: CupertinoIcons.repeat,
                label: 'Completed Sets',
                value: '$completedSets / $totalSets',
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    notifier.reset();
                    context.go('/home/work/today');
                  },
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    }
    return '${minutes}m ${seconds}s';
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Text(label, style: Theme.of(context).textTheme.bodyLarge),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
