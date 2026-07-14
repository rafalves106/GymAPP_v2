import 'package:gym_app/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.token,
    required super.email,
    required super.fullName,
    required super.expiresAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      token: json['token'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String? ??
          '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : DateTime.now().add(const Duration(hours: 1)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'email': email,
      'fullName': fullName,
      'expiresAt': expiresAt.toIso8601String(),
    };
  }
}
