import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_app/data/models/exercise_model.dart';
import 'package:gym_app/data/repositories/exercises_repository.dart';
import 'package:gym_app/domain/enums/muscle_group_type.dart';
import 'package:gym_app/domain/enums/difficulty_level.dart';
import 'auth_provider.dart';

final exercisesRepositoryProvider = Provider<ExercisesRepository>((ref) {
  return ExercisesRepository(apiClient: ref.watch(apiClientProvider));
});

final exerciseFilterProvider = StateProvider<ExerciseFilter>(
  (ref) => const ExerciseFilter(),
);

class ExerciseFilter {
  final MuscleGroupType? muscleGroup;
  final DifficultyLevel? difficulty;
  final String? searchQuery;

  const ExerciseFilter({
    this.muscleGroup,
    this.difficulty,
    this.searchQuery,
  });

  ExerciseFilter copyWith({
    MuscleGroupType? muscleGroup,
    DifficultyLevel? difficulty,
    String? searchQuery,
    bool clearMuscleGroup = false,
    bool clearDifficulty = false,
    bool clearSearchQuery = false,
  }) {
    return ExerciseFilter(
      muscleGroup: clearMuscleGroup ? null : (muscleGroup ?? this.muscleGroup),
      difficulty: clearDifficulty ? null : (difficulty ?? this.difficulty),
      searchQuery:
          clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
    );
  }
}

final exercisesProvider =
    AsyncNotifierProvider<ExercisesNotifier, List<ExerciseModel>>(
  ExercisesNotifier.new,
);

class ExercisesNotifier extends AsyncNotifier<List<ExerciseModel>> {
  @override
  Future<List<ExerciseModel>> build() async {
    final repo = ref.read(exercisesRepositoryProvider);
    return await repo.getAll();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(exercisesRepositoryProvider);
      return await repo.getAll();
    });
  }

  Future<void> createExercise(ExerciseModel exercise) async {
    final repo = ref.read(exercisesRepositoryProvider);
    final created = await repo.create(exercise);
    state = AsyncData([...state.value ?? [], created]);
  }

  Future<void> updateExercise(ExerciseModel exercise) async {
    final repo = ref.read(exercisesRepositoryProvider);
    final updated = await repo.update(exercise.id, exercise);
    state = AsyncData(
      (state.value ?? []).map((e) => e.id == updated.id ? updated : e).toList(),
    );
  }

  Future<void> deleteExercise(String id) async {
    final repo = ref.read(exercisesRepositoryProvider);
    await repo.delete(id);
    state = AsyncData(
      (state.value ?? []).where((e) => e.id != id).toList(),
    );
  }
}

final filteredExercisesProvider = Provider<AsyncValue<List<ExerciseModel>>>(
  (ref) {
    final filter = ref.watch(exerciseFilterProvider);
    final exercisesAsync = ref.watch(exercisesProvider);

    return exercisesAsync.whenData((exercises) {
      return exercises.where((e) {
        if (filter.muscleGroup != null &&
            !e.muscleGroups.contains(filter.muscleGroup)) {
          return false;
        }
        if (filter.difficulty != null &&
            e.difficultyLevel != filter.difficulty) {
          return false;
        }
        if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
          return e.name
              .toLowerCase()
              .contains(filter.searchQuery!.toLowerCase());
        }
        return true;
      }).toList();
    });
  },
);
