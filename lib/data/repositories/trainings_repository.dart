import '../datasources/api_client.dart';
import '../models/training_model.dart';
import '../../config/constants.dart';

class TrainingsRepository {
  final ApiClient _apiClient;

  TrainingsRepository({required ApiClient apiClient})
      : _apiClient = apiClient;

  Future<List<TrainingModel>> getAll() async {
    final response = await _apiClient.dio.get(ApiConstants.trainings);
    return (response.data as List)
        .map((e) => TrainingModel.fromJson(e))
        .toList();
  }

  Future<TrainingModel> getById(String id) async {
    final response =
        await _apiClient.dio.get(ApiConstants.trainingById(id));
    return TrainingModel.fromJson(response.data);
  }

  Future<TrainingModel> create(TrainingModel training) async {
    final response = await _apiClient.dio.post(
      ApiConstants.trainings,
      data: training.toJson(),
    );
    return TrainingModel.fromJson(response.data);
  }

  Future<TrainingModel> update(String id, TrainingModel training) async {
    final response = await _apiClient.dio.put(
      ApiConstants.trainingById(id),
      data: training.toJson(),
    );
    return TrainingModel.fromJson(response.data);
  }

  Future<void> delete(String id) async {
    await _apiClient.dio.delete(ApiConstants.trainingById(id));
  }
}
