import 'dart:convert';

List<AppUser> appUserFromJson(String str) =>
    List<AppUser>.from(json.decode(str).map((x) => AppUser.fromJson(x)));

class AppUser {
  final String id;
  final String email;
  final String role;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json["_id"],
    email: json["email"],
    role: json["role"],
    createdAt: DateTime.parse(json["createdAt"]),
  );
}
