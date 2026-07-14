import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/config/router.dart';
import 'package:gym_app/config/theme.dart';
import 'package:gym_app/data/datasources/api_client.dart';
import 'package:gym_app/data/datasources/secure_storage_datasource.dart';
import 'package:gym_app/data/repositories/auth_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final secureStorageProvider = Provider<SecureStorageDataSource>(
  (ref) => SecureStorageDataSource(),
);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    apiClient: ref.watch(apiClientProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
});

final authStateProvider = FutureProvider<String?>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  return await repo.getToken();
});

final routerProvider = Provider.family<GoRouter, String?>((ref, token) {
  return createRouter(token: token);
});

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class GymApp extends ConsumerWidget {
  final ThemeMode initialThemeMode;

  const GymApp({super.key, required this.initialThemeMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final authAsync = ref.watch(authStateProvider);
    final token = authAsync.valueOrNull;

    final router = ref.watch(routerProvider(token));

    return MaterialApp.router(
      title: 'GymApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);

  void setMode(ThemeMode mode) {
    state = mode;
    AppTheme.saveThemeMode(mode);
  }
}
