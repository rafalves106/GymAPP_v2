import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:gym_app/data/datasources/api_client.dart';
import 'package:gym_app/data/models/exercise_model.dart';
import 'package:gym_app/data/repositories/exercises_repository.dart';
import 'package:gym_app/domain/enums/difficulty_level.dart';

class MockApiClient extends Mock implements ApiClient {}
class MockDio extends Mock implements Dio {}
class MockResponse extends Mock implements Response {}

void main() {
  late ExercisesRepository repository;
  late MockApiClient mockApiClient;
  late MockDio mockDio;

  setUp(() {
    mockApiClient = MockApiClient();
    mockDio = MockDio();
    when(() => mockApiClient.dio).thenReturn(mockDio);
    repository = ExercisesRepository(apiClient: mockApiClient);
  });

  final now = DateTime.now();

  Map<String, dynamic> exerciseJson(String id) => {
        'id': id,
        'name': 'Bench Press',
        'description': 'Chest exercise',
        'muscleGroups': [1, 5],
        'equipments': [1],
        'difficultyLevel': 2,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

  group('ExercisesRepository', () {
    test('getAll returns list of exercises', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn([
        exerciseJson('1'),
        exerciseJson('2'),
      ]);
      when(() => mockDio.get(any())).thenAnswer((_) async => response);

      final exercises = await repository.getAll();

      expect(exercises.length, 2);
      expect(exercises[0].name, 'Bench Press');
    });

    test('getById returns single exercise', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn(exerciseJson('1'));
      when(() => mockDio.get(any())).thenAnswer((_) async => response);

      final exercise = await repository.getById('1');

      expect(exercise.id, '1');
    });

    test('create returns created exercise', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn(exerciseJson('new-id'));
      when(() => mockDio.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => response);

      final exercise = await repository.create(
        ExerciseModel(
          id: '',
          name: 'Bench Press',
          description: 'Chest exercise',
          muscleGroups: [],
          equipments: [],
          difficultyLevel: DifficultyLevel.intermediate,
          createdAt: now,
          updatedAt: now,
        ),
      );

      expect(exercise.id, 'new-id');
    });

    test('delete calls dio.delete', () async {
      when(() => mockDio.delete(any())).thenAnswer((_) async => MockResponse());

      await repository.delete('1');

      verify(() => mockDio.delete('/api/exercises/1')).called(1);
    });
  });
}
