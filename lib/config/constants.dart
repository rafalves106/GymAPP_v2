class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.15.144:5200',
  );

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

  // Workouts
  static const String trainings = '/api/workouts';

  static String trainingById(String id) => '/api/workouts/$id';
  static String trainingDay(String id) => '/api/workouts/$id/day';
  static const String trainingsToday = '/api/workouts/today';

  // Sessions
  static String sessionStart(String trainingId) =>
      '/api/sessions/start/$trainingId';
  static String sessionById(String id) => '/api/sessions/$id';
  static String sessionPause(String id) => '/api/sessions/$id/pause';
  static String sessionResume(String id) => '/api/sessions/$id/resume';
  static String sessionStop(String id) => '/api/sessions/$id/stop';
  static String sessionCancel(String id) => '/api/sessions/$id/cancel';
  static String sessionIncrement(String id, String exerciseId) =>
      '/api/sessions/$id/exercise/$exerciseId/increment';
  static String sessionDecrement(String id, String exerciseId) =>
      '/api/sessions/$id/exercise/$exerciseId/decrement';
}
