class User {
  final String token;
  final String? email;
  final String? fullName;
  final DateTime? expiresAt;

  const User({
    required this.token,
    this.email,
    this.fullName,
    this.expiresAt,
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }
}
