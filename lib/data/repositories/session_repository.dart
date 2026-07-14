import '../datasources/api_client.dart';
import '../models/session_model.dart';
import '../../config/constants.dart';

class SessionRepository {
  final ApiClient _apiClient;

  SessionRepository({required ApiClient apiClient})
      : _apiClient = apiClient;

  Future<SessionModel> start(String trainingId) async {
    final response = await _apiClient.dio.post(
      ApiConstants.sessionStart(trainingId),
    );
    return SessionModel.fromJson(response.data);
  }

  Future<SessionModel> pause(String id) async {
    final response = await _apiClient.dio.post(ApiConstants.sessionPause(id));
    return SessionModel.fromJson(response.data);
  }

  Future<SessionModel> resume(String id) async {
    final response = await _apiClient.dio.post(ApiConstants.sessionResume(id));
    return SessionModel.fromJson(response.data);
  }

  Future<SessionModel> stop(String id) async {
    final response = await _apiClient.dio.post(ApiConstants.sessionStop(id));
    return SessionModel.fromJson(response.data);
  }

  Future<SessionModel> cancel(String id) async {
    final response = await _apiClient.dio.post(ApiConstants.sessionCancel(id));
    return SessionModel.fromJson(response.data);
  }

  Future<SessionModel> incrementSet(String id, String exerciseId) async {
    final response = await _apiClient.dio.post(
      ApiConstants.sessionIncrement(id, exerciseId),
    );
    return SessionModel.fromJson(response.data);
  }

  Future<SessionModel> decrementSet(String id, String exerciseId) async {
    final response = await _apiClient.dio.post(
      ApiConstants.sessionDecrement(id, exerciseId),
    );
    return SessionModel.fromJson(response.data);
  }

  Future<SessionModel> getById(String id) async {
    final response = await _apiClient.dio.get(ApiConstants.sessionById(id));
    return SessionModel.fromJson(response.data);
  }
}
