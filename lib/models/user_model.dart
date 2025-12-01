import 'dart:convert';

class UserModel {
  final String email;
  final String token;
  final String role;

  UserModel({
    required this.email,
    required this.token,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> m) {
    return UserModel(
      email: m['email'] ?? "",
      token: m['token'] ?? "",
      role: m['role'] ?? "developer",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'token': token,
      'role': role,
    };
  }

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());
}
