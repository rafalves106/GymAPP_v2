import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_app/app.dart';
import 'package:gym_app/data/models/user_model.dart';

final authProvider =
    AsyncNotifierProvider<AuthNotifier, UserModel?>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    return null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.login(email, password);
      ref.invalidate(authStateProvider);
      return user;
    });
  }

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      ref.invalidate(authStateProvider);
      return user;
    });
  }

  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    ref.invalidate(authStateProvider);
    state = const AsyncData(null);
  }
}
