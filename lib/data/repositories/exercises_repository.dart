import '../datasources/api_client.dart';
import '../models/exercise_model.dart';
import '../../config/constants.dart';
import '../../domain/enums/muscle_group_type.dart';
import '../../domain/enums/difficulty_level.dart';

class ExercisesRepository {
  final ApiClient _apiClient;

  ExercisesRepository({required ApiClient apiClient})
      : _apiClient = apiClient;

  Future<List<ExerciseModel>> getAll() async {
    final response = await _apiClient.dio.get(ApiConstants.exercises);
    return (response.data as List)
        .map((e) => ExerciseModel.fromJson(e))
        .toList();
  }

  Future<ExerciseModel> getById(String id) async {
    final response =
        await _apiClient.dio.get(ApiConstants.exerciseById(id));
    return ExerciseModel.fromJson(response.data);
  }

  Future<List<ExerciseModel>> getByMuscleGroup(MuscleGroupType group) async {
    final response = await _apiClient.dio
        .get(ApiConstants.exercisesByMuscleGroup(group.name));
    return (response.data as List)
        .map((e) => ExerciseModel.fromJson(e))
        .toList();
  }

  Future<List<ExerciseModel>> getByDifficulty(DifficultyLevel level) async {
    final response = await _apiClient.dio
        .get(ApiConstants.exercisesByDifficulty(level.name));
    return (response.data as List)
        .map((e) => ExerciseModel.fromJson(e))
        .toList();
  }

  Future<List<ExerciseModel>> search(String name) async {
    final response =
        await _apiClient.dio.get(ApiConstants.exercisesSearch(name));
    return (response.data as List)
        .map((e) => ExerciseModel.fromJson(e))
        .toList();
  }

  Future<ExerciseModel> create(ExerciseModel exercise) async {
    final response = await _apiClient.dio.post(
      ApiConstants.exercises,
      data: exercise.toJson(),
    );
    return ExerciseModel.fromJson(response.data);
  }

  Future<ExerciseModel> update(String id, ExerciseModel exercise) async {
    final response = await _apiClient.dio.put(
      ApiConstants.exerciseById(id),
      data: exercise.toJson(),
    );
    return ExerciseModel.fromJson(response.data);
  }

  Future<void> delete(String id) async {
    await _apiClient.dio.delete(ApiConstants.exerciseById(id));
  }
}
