import '../datasources/api_client.dart';
import '../models/training_model.dart';
import '../../domain/entities/training.dart';
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

  Future<List<TrainingModel>> getToday(int flutterDay) async {
    final apiDay = Training.flutterDayToApi(flutterDay);
    final response = await _apiClient.dio.get(
      ApiConstants.trainingsToday,
      queryParameters: {'day': apiDay},
    );
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
    final created = TrainingModel.fromJson(response.data);

    if (training.scheduledDay != null) {
      await assignDay(created.id, training.scheduledDay);
      return TrainingModel.fromEntity(
        created.copyWith(scheduledDay: training.scheduledDay),
      );
    }

    return created;
  }

  Future<TrainingModel> update(String id, TrainingModel training) async {
    final response = await _apiClient.dio.put(
      ApiConstants.trainingById(id),
      data: training.toJson(),
    );
    final updated = TrainingModel.fromJson(response.data);

    await assignDay(id, training.scheduledDay);
    return TrainingModel.fromEntity(
      updated.copyWith(
        scheduledDay: training.scheduledDay,
        clearScheduledDay: training.scheduledDay == null,
      ),
    );
  }

  Future<void> delete(String id) async {
    await _apiClient.dio.delete(ApiConstants.trainingById(id));
  }

  Future<void> assignDay(String id, int? flutterDay) async {
    final apiDay = Training.flutterDayToApi(flutterDay);
    await _apiClient.dio.put(
      ApiConstants.trainingDay(id),
      data: {'day': apiDay},
    );
  }
}
