import 'package:gym_app/data/datasources/api_client.dart';
import 'package:gym_app/data/datasources/secure_storage_datasource.dart';
import 'package:gym_app/data/models/user_model.dart';
import 'package:gym_app/config/constants.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final SecureStorageDataSource _secureStorage;

  AuthRepository({
    required ApiClient apiClient,
    required SecureStorageDataSource secureStorage,
  })  : _apiClient = apiClient,
        _secureStorage = secureStorage;

  Future<UserModel> login(String usernameOrEmail, String password) async {
    final response = await _apiClient.dio.post(
      ApiConstants.login,
      data: {'usernameOrEmail': usernameOrEmail, 'password': password},
    );
    final user = UserModel.fromJson(response.data);
    await _secureStorage.saveToken(user.token);
    return user;
  }

  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.dio.post(
      ApiConstants.register,
      data: {
        'username': username,
        'email': email,
        'password': password,
      },
    );
    final user = UserModel.fromJson(response.data);
    await _secureStorage.saveToken(user.token);
    return user;
  }

  Future<void> logout() async {
    await _secureStorage.deleteToken();
  }

  Future<String?> getToken() async {
    return await _secureStorage.getToken();
  }
}
