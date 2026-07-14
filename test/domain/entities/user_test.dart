import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/domain/entities/user.dart';

void main() {
  group('User', () {
    test('isExpired returns true when expiresAt is in the past', () {
      final user = User(
        token: 'abc',
        email: 'test@test.com',
        fullName: 'Test',
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
      );
      expect(user.isExpired, true);
    });

    test('isExpired returns false when expiresAt is in the future', () {
      final user = User(
        token: 'abc',
        email: 'test@test.com',
        fullName: 'Test',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(user.isExpired, false);
    });
  });
}
