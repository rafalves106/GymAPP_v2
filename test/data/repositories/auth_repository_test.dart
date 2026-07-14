import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:gym_app/data/datasources/api_client.dart';
import 'package:gym_app/data/datasources/secure_storage_datasource.dart';
import 'package:gym_app/data/repositories/auth_repository.dart';

class MockApiClient extends Mock implements ApiClient {}
class MockSecureStorage extends Mock implements SecureStorageDataSource {}
class MockDio extends Mock implements Dio {}
class MockResponse extends Mock implements Response {}
class MockRequestOptions extends Mock implements RequestOptions {}

void main() {
  late AuthRepository repository;
  late MockApiClient mockApiClient;
  late MockSecureStorage mockSecureStorage;
  late MockDio mockDio;

  setUp(() {
    mockApiClient = MockApiClient();
    mockSecureStorage = MockSecureStorage();
    mockDio = MockDio();
    when(() => mockApiClient.dio).thenReturn(mockDio);
    repository = AuthRepository(
      apiClient: mockApiClient,
      secureStorage: mockSecureStorage,
    );
  });

  group('AuthRepository', () {
    test('login returns UserModel and saves token', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({
        'token': 'test-token',
        'email': 'test@test.com',
        'fullName': 'Test User',
        'expiresAt': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
      });
      when(() => mockDio.post(
        any(),
        data: any(named: 'data'),
      )).thenAnswer((_) async => response);
      when(() => mockSecureStorage.saveToken(any())).thenAnswer((_) async {});

      final user = await repository.login('test@test.com', 'password');

      expect(user.email, 'test@test.com');
      expect(user.token, 'test-token');
      verify(() => mockSecureStorage.saveToken('test-token')).called(1);
    });

    test('logout deletes token', () async {
      when(() => mockSecureStorage.deleteToken()).thenAnswer((_) async {});

      await repository.logout();

      verify(() => mockSecureStorage.deleteToken()).called(1);
    });

    test('getToken returns stored token', () async {
      when(() => mockSecureStorage.getToken())
          .thenAnswer((_) async => 'stored-token');

      final token = await repository.getToken();

      expect(token, 'stored-token');
    });
  });
}
