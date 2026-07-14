class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://localhost:5200';

  // Auth
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';

  // Exercises
  static const String exercises = '/api/exercises';

  static String exerciseById(String id) => '/api/exercises/$id';
  static String exercisesByMuscleGroup(String group) =>
      '/api/exercises/muscle-group/$group';
  static String exercisesByDifficulty(String level) =>
      '/api/exercises/difficulty/$level';
  static String exercisesSearch(String name) =>
      '/api/exercises/search?name=$name';

  // Trainings
  static const String trainings = '/api/trainings';

  static String trainingById(String id) => '/api/trainings/$id';
}
