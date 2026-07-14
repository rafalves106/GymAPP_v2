import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/presentation/providers/trainings_provider.dart';
import 'package:gym_app/presentation/providers/session_provider.dart';
import 'package:gym_app/presentation/widgets/haptic_helper.dart';

class TrainingDetailScreen extends ConsumerWidget {
  final String id;
  const TrainingDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainingsAsync = ref.watch(trainingsProvider);

    return trainingsAsync.when(
      data: (trainings) {
        final training = trainings.where((t) => t.id == id).firstOrNull;
        if (training == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Training')),
            body: const Center(child: Text('Training not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(training.name),
            actions: [
              IconButton(
                icon: const Icon(CupertinoIcons.pencil),
                onPressed: () =>
                    context.push('/home/work/trainings/$id/edit'),
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.trash),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Training'),
                      content: Text(
                          'Delete "${training.name}"?'),
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
                        .read(trainingsProvider.notifier)
                        .deleteTraining(id);
                    if (context.mounted) context.pop();
                  }
                },
              ),
            ],
          ),
          body: Column(
            children: [
              if (training.description != null &&
                  training.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    training.description!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: training.exercises.length,
                  itemBuilder: (context, index) {
                    final te = training.exercises[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text(te.exerciseName),
                        subtitle: Text(
                          '${te.series} series × ${te.reps} reps • ${te.restTime}s rest',
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: training.exercises.isEmpty
                        ? null
                        : () {
                            HapticFeedbackHelper.heavy();
                            ref
                                .read(activeSessionProvider.notifier)
                                .startSession(training);
                            context.push('/active-training');
                          },
                    icon: const Icon(CupertinoIcons.play_arrow_solid),
                    label: const Text('Start Training'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}
