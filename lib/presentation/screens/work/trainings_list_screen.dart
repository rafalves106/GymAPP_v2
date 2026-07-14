import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/presentation/providers/trainings_provider.dart';
import 'package:gym_app/presentation/widgets/training_card.dart';
import 'package:gym_app/presentation/widgets/empty_state.dart';
import 'package:gym_app/presentation/widgets/error_state.dart';
import 'package:gym_app/presentation/widgets/loading_shimmer.dart';
import 'package:gym_app/presentation/widgets/haptic_helper.dart';

class TrainingsListScreen extends ConsumerWidget {
  const TrainingsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainingsAsync = ref.watch(trainingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Trainings')),
      body: trainingsAsync.when(
        data: (trainings) {
          if (trainings.isEmpty) {
            return EmptyState(
              icon: Icons.playlist_play,
              title: 'No trainings yet',
              subtitle: 'Create your first training to start working out',
              actionLabel: 'Create Training',
              onAction: () => context.push('/home/work/trainings/new'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              HapticFeedbackHelper.light();
              await ref.read(trainingsProvider.notifier).refresh();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: trainings.length,
              itemBuilder: (context, index) {
                final training = trainings[index];
                return TrainingCard(
                  training: training,
                  onTap: () {
                    HapticFeedbackHelper.selection();
                    context.push('/home/work/trainings/${training.id}');
                  },
                  onDelete: () {
                    HapticFeedbackHelper.medium();
                    ref
                        .read(trainingsProvider.notifier)
                        .deleteTraining(training.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${training.name} deleted'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            ref
                                .read(trainingsProvider.notifier)
                                .createTraining(training);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
        loading: () => const ListShimmer(),
        error: (e, _) => ErrorState(
          message: e.toString(),
          onRetry: () => ref.read(trainingsProvider.notifier).refresh(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedbackHelper.light();
          context.push('/home/work/trainings/new');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
