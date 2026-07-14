import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_app/app.dart';
import 'package:gym_app/data/models/training_model.dart';
import 'package:gym_app/data/repositories/trainings_repository.dart';

final trainingsRepositoryProvider = Provider<TrainingsRepository>((ref) {
  return TrainingsRepository(apiClient: ref.watch(apiClientProvider));
});

final trainingsProvider =
    AsyncNotifierProvider<TrainingsNotifier, List<TrainingModel>>(
  TrainingsNotifier.new,
);

class TrainingsNotifier extends AsyncNotifier<List<TrainingModel>> {
  @override
  Future<List<TrainingModel>> build() async {
    final repo = ref.read(trainingsRepositoryProvider);
    return await repo.getAll();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(trainingsRepositoryProvider);
      return await repo.getAll();
    });
  }

  Future<void> createTraining(TrainingModel training) async {
    final repo = ref.read(trainingsRepositoryProvider);
    final created = await repo.create(training);
    state = AsyncData([...state.value ?? [], created]);
  }

  Future<void> updateTraining(TrainingModel training) async {
    final repo = ref.read(trainingsRepositoryProvider);
    final updated = await repo.update(training.id, training);
    state = AsyncData(
      (state.value ?? []).map((e) => e.id == updated.id ? updated : e).toList(),
    );
  }

  Future<void> deleteTraining(String id) async {
    final repo = ref.read(trainingsRepositoryProvider);
    await repo.delete(id);
    state = AsyncData(
      (state.value ?? []).where((e) => e.id != id).toList(),
    );
  }
}
