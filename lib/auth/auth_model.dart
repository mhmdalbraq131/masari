import '../data/models/user_role.dart';

class AuthUser {
  final int id;
  final String username;
  final UserRole role;

  const AuthUser({
    required this.id,
    required this.username,
    required this.role,
  });
}

class AuthResult {
  final bool success;
  final String message;

  const AuthResult({required this.success, required this.message});
}
