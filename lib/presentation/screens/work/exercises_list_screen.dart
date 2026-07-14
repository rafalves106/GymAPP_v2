import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/presentation/providers/exercises_provider.dart';
import 'package:gym_app/presentation/widgets/exercise_card.dart';
import 'package:gym_app/presentation/widgets/empty_state.dart';
import 'package:gym_app/presentation/widgets/error_state.dart';
import 'package:gym_app/presentation/widgets/loading_shimmer.dart';
import 'package:gym_app/presentation/widgets/haptic_helper.dart';
import 'package:gym_app/presentation/widgets/search_bar.dart' as custom;

class ExercisesListScreen extends ConsumerStatefulWidget {
  const ExercisesListScreen({super.key});

  @override
  ConsumerState<ExercisesListScreen> createState() =>
      _ExercisesListScreenState();
}

class _ExercisesListScreenState extends ConsumerState<ExercisesListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(filteredExercisesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercises'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: custom.GymSearchBar(
              controller: _searchController,
              hint: 'Search exercises...',
              onChanged: (value) {
                ref.read(exerciseFilterProvider.notifier).state =
                    ref.read(exerciseFilterProvider).copyWith(
                          searchQuery: value,
                          clearSearchQuery: value.isEmpty,
                        );
              },
            ),
          ),
        ),
      ),
      body: exercisesAsync.when(
        data: (exercises) {
          if (exercises.isEmpty) {
            return EmptyState(
              icon: Icons.fitness_center,
              title: 'No exercises found',
              subtitle: _searchController.text.isNotEmpty
                  ? 'Try a different search term'
                  : 'Create your first exercise to get started',
              actionLabel: _searchController.text.isEmpty ? 'Add Exercise' : null,
              onAction: _searchController.text.isEmpty
                  ? () => context.push('/home/work/exercises/new')
                  : null,
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              HapticFeedbackHelper.light();
              await ref.read(exercisesProvider.notifier).refresh();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                return ExerciseCard(
                  exercise: exercise,
                  onTap: () {
                    HapticFeedbackHelper.selection();
                    context.push('/home/work/exercises/${exercise.id}');
                  },
                  onDelete: () {
                    HapticFeedbackHelper.medium();
                    ref
                        .read(exercisesProvider.notifier)
                        .deleteExercise(exercise.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${exercise.name} deleted'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            ref
                                .read(exercisesProvider.notifier)
                                .createExercise(exercise);
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
          onRetry: () => ref.read(exercisesProvider.notifier).refresh(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedbackHelper.light();
          context.push('/home/work/exercises/new');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
