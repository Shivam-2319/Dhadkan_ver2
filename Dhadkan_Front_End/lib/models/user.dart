import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 1) // ⚠️ UNIQUE and FIXED
class User {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String mobile;

  @HiveField(3)
  final String email;

  @HiveField(4)
  final String role;

  User({
    required this.id,
    required this.name,
    required this.mobile,
    required this.email,
    required this.role,
  });

  // ---------- Backend → App ----------
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      mobile: json['mobile'],
      email: json['email'],
      role: json['role'],
    );
  }

  // ---------- App → Backend ----------
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'mobile': mobile,
      'email': email,
      'role': role,
    };
  }
}
