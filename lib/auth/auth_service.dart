import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/local_db.dart';
import '../data/models/user_role.dart';
import 'auth_model.dart';

class AuthService extends ChangeNotifier {
  static const _sessionKey = 'auth_user_id';

  final LocalDb _db = LocalDb.instance;
  AuthUser? _currentUser;
  bool _guest = false;
  bool _restored = false;

  AuthUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isGuest => _guest;
  UserRole get role => _currentUser?.role ?? UserRole.guest;
  String? get username => _currentUser?.username;

  Future<bool> hasAdminUser() async {
    return _db.hasUserWithRole(UserRole.admin.name);
  }

  Future<void> restoreSession() async {
    if (_restored) return;
    _restored = true;
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_sessionKey);
    if (userId == null) {
      notifyListeners();
      return;
    }
    final row = await _db.getUserById(userId);
    if (row == null) {
      await prefs.remove(_sessionKey);
      notifyListeners();
      return;
    }
    _currentUser = _rowToUser(row);
    _guest = false;
    notifyListeners();
  }

  Future<AuthResult> register({
    required String username,
    required String password,
    UserRole role = UserRole.user,
    bool remember = true,
  }) async {
    final normalized = username.trim().toLowerCase();
    if (normalized.isEmpty || password.isEmpty) {
      return const AuthResult(success: false, message: 'يرجى إدخال اسم المستخدم وكلمة المرور');
    }
    final existing = await _db.getUserByUsername(normalized);
    if (existing != null) {
      return const AuthResult(success: false, message: 'اسم المستخدم مستخدم بالفعل');
    }
    final hash = _hashPassword(normalized, password);
    final id = await _db.insertUser(username: normalized, passwordHash: hash, role: role.name);
    _currentUser = AuthUser(id: id, username: normalized, role: role);
    _guest = false;
    await _persistSession(remember: remember);
    notifyListeners();
    return const AuthResult(success: true, message: 'تم إنشاء الحساب بنجاح');
  }

  Future<AuthResult> login({
    required String username,
    required String password,
    bool remember = true,
    UserRole? requiredRole,
  }) async {
    final normalized = username.trim().toLowerCase();
    if (normalized.isEmpty || password.isEmpty) {
      return const AuthResult(success: false, message: 'يرجى إدخال اسم المستخدم وكلمة المرور');
    }
    final row = await _db.getUserByUsername(normalized);
    if (row == null) {
      return const AuthResult(success: false, message: 'بيانات الدخول غير صحيحة');
    }
    final stored = row['password'] as String;
    final inputHash = _hashPassword(normalized, password);
    if (stored != inputHash && stored != password) {
      return const AuthResult(success: false, message: 'بيانات الدخول غير صحيحة');
    }
    final user = _rowToUser(row);
    if (requiredRole != null && user.role != requiredRole) {
      return const AuthResult(success: false, message: 'لا تملك صلاحية الدخول');
    }
    if (stored == password) {
      await _db.updateUserPassword(user.id, inputHash);
    }
    _currentUser = user;
    _guest = false;
    await _persistSession(remember: remember);
    notifyListeners();
    return const AuthResult(success: true, message: 'تم تسجيل الدخول');
  }

  Future<void> loginGuest() async {
    _currentUser = null;
    _guest = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    _guest = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    notifyListeners();
  }

  Future<void> _persistSession({required bool remember}) async {
    final prefs = await SharedPreferences.getInstance();
    if (!remember || _currentUser == null) {
      await prefs.remove(_sessionKey);
      return;
    }
    await prefs.setInt(_sessionKey, _currentUser!.id);
  }

  String _hashPassword(String username, String password) {
    final bytes = utf8.encode('$username::$password');
    return sha256.convert(bytes).toString();
  }

  AuthUser _rowToUser(Map<String, Object?> row) {
    final roleValue = row['role'] as String;
    final role = _roleFromString(roleValue);
    return AuthUser(
      id: row['id'] as int,
      username: row['username'] as String,
      role: role,
    );
  }

  UserRole _roleFromString(String value) {
    switch (value) {
      case 'admin':
        return UserRole.admin;
      case 'subAdmin':
        return UserRole.subAdmin;
      case 'bookingAgent':
        return UserRole.bookingAgent;
      case 'visaOfficer':
        return UserRole.visaOfficer;
      case 'supervisor':
        return UserRole.supervisor;
      case 'guest':
        return UserRole.guest;
      default:
        return UserRole.user;
    }
  }
}
