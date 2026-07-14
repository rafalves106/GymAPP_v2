import 'package:gym_app/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.token,
    super.email,
    super.fullName,
    super.expiresAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      token: json['token'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ??
          '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      if (email != null && email!.isNotEmpty) 'email': email,
      if (fullName != null && fullName!.isNotEmpty) 'fullName': fullName,
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }
}
