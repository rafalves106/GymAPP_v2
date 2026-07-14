import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/domain/entities/training.dart';
import 'package:gym_app/presentation/providers/trainings_provider.dart';
import 'package:gym_app/presentation/widgets/empty_state.dart';
import 'package:gym_app/presentation/widgets/error_state.dart';
import 'package:gym_app/presentation/widgets/loading_shimmer.dart';
import 'package:gym_app/presentation/widgets/haptic_helper.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayAsync = ref.watch(todayTrainingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
      ),
      body: todayAsync.when(
        data: (trainings) {
          if (trainings.isEmpty) {
            return EmptyState(
              icon: CupertinoIcons.today,
              title: 'No workouts today',
              subtitle: 'Schedule a training for today in the Schedule tab',
              actionLabel: 'Go to Schedule',
              onAction: () => context.go('/home/work/trainings'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              HapticFeedbackHelper.light();
              ref.invalidate(todayTrainingsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: trainings.length,
              itemBuilder: (context, index) {
                final training = trainings[index];
                return _TodayTrainingCard(training: training);
              },
            ),
          );
        },
        loading: () => const ListShimmer(),
        error: (e, _) => ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(todayTrainingsProvider),
        ),
      ),
    );
  }
}

class _TodayTrainingCard extends StatelessWidget {
  final Training training;

  const _TodayTrainingCard({required this.training});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          HapticFeedbackHelper.selection();
          context.push('/home/work/trainings/${training.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  CupertinoIcons.sportscourt,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      training.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${training.exercises.length} exercise${training.exercises.length != 1 ? 's' : ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                color: colorScheme.onSurfaceVariant,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
