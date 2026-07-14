class User {
  final String token;
  final String email;
  final String fullName;
  final DateTime expiresAt;

  const User({
    required this.token,
    required this.email,
    required this.fullName,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
