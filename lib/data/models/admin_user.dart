import 'user_role.dart';

class AdminUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final bool active;

  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.active,
  });

  AdminUser copyWith({
    String? name,
    String? email,
    UserRole? role,
    bool? active,
  }) {
    return AdminUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      active: active ?? this.active,
    );
  }
}
