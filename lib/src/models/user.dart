// lib/src/models/user.dart
class AppUser {
  final int userId;
  final String email;
  final String name;
  final String role; // 'CLIENT' or 'SHOP_OWNER'

  AppUser({
    required this.userId,
    required this.email,
    required this.name,
    required this.role,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      userId: json['userId'],
      email: json['email'],
      name: json['name'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'email': email, 'name': name, 'role': role};
  }
}
