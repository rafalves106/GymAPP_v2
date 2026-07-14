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

  Future<void> assignDay(String id, int? day) async {
    final repo = ref.read(trainingsRepositoryProvider);
    await repo.assignDay(id, day);
    state = AsyncData(
      (state.value ?? []).map((e) {
        if (e.id == id) {
          return TrainingModel.fromEntity(
            e.copyWith(
              scheduledDay: day,
              clearScheduledDay: day == null,
            ),
          );
        }
        return e;
      }).toList(),
    );
  }

  List<TrainingModel> getForDay(int? day) {
    return (state.value ?? []).where((t) => t.scheduledDay == day).toList();
  }

  List<TrainingModel> getUnassigned() {
    return (state.value ?? []).where((t) => t.scheduledDay == null).toList();
  }
}

final todayTrainingsProvider = FutureProvider<List<TrainingModel>>((
  ref,
) async {
  final repo = ref.watch(trainingsRepositoryProvider);
  final now = DateTime.now().weekday - 1;
  try {
    return await repo.getToday(now);
  } catch (_) {
    final trainingsAsync = ref.watch(trainingsProvider);
    return trainingsAsync.when(
      data: (trainings) => trainings.where((t) => t.scheduledDay == now).toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  }
});
