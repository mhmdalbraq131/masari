import 'package:flutter/material.dart';
import '../data/local_db.dart';
import '../data/models/app_notification.dart';
import '../data/models/booking_record.dart';
import '../data/models/user_role.dart';
import '../data/repositories/secure_storage_mock.dart';
import '../data/repositories/mock_data.dart';

class AppState extends ChangeNotifier {
  AppState()
      : _notifications = [...MockData.initialNotifications()] {
    _loadRole();
    _loadBookings();
  }

  final List<AppNotification> _notifications;
  final List<BookingRecord> _busBookings = [];
  final SecureStorageMock _storage = SecureStorageMock();
  final LocalDb _db = LocalDb.instance;
  UserRole _role = UserRole.guest;
  bool _isLoggedIn = false;
  String? _username;
  bool _rememberMe = false;

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  List<BookingRecord> get busBookings => List.unmodifiable(_busBookings);
  UserRole get role => _role;
  bool get isLoggedIn => _isLoggedIn;
  String? get username => _username;
  bool get rememberMe => _rememberMe;

  int get unreadNotifications => _notifications.where((n) => !n.isRead).length;

  void markNotificationRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1) return;
    _notifications[index] = _notifications[index].copyWith(isRead: true);
    notifyListeners();
  }

  void markAllNotificationsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  Future<void> addBusBooking(BookingRecord record) async {
    _busBookings.insert(0, record);
    notifyListeners();
    await _db.insertBooking(record);
  }

  Future<void> updateBusBookingStatus(String ticketId, String status) async {
    final index = _busBookings.indexWhere((b) => b.ticketId == ticketId);
    if (index == -1) return;
    _busBookings[index] = _busBookings[index].copyWith(status: status);
    notifyListeners();
    await _db.updateBookingStatus(ticketId, status);
  }

  Future<void> login({
    required UserRole role,
    required String username,
    required bool remember,
  }) async {
    _role = role;
    _isLoggedIn = true;
    _username = username;
    _rememberMe = remember;
    await _storage.write('auth_role', role.name);
    await _storage.write('auth_logged_in', 'true');
    await _storage.write('auth_username', username);
    await _storage.write('auth_remember', remember ? 'true' : 'false');
    notifyListeners();
  }

  Future<void> loginGuest() async {
    _role = UserRole.guest;
    _isLoggedIn = false;
    _username = null;
    _rememberMe = false;
    await _storage.write('auth_role', 'guest');
    await _storage.write('auth_logged_in', 'false');
    await _storage.write('auth_username', '');
    await _storage.write('auth_remember', 'false');
    notifyListeners();
  }

  Future<void> logout() async {
    _role = UserRole.guest;
    _isLoggedIn = false;
    _username = null;
    _rememberMe = false;
    await _storage.clear();
    notifyListeners();
  }

  Future<void> _loadRole() async {
    final storedRole = await _storage.read('auth_role');
    final storedLogged = await _storage.read('auth_logged_in');
    final storedName = await _storage.read('auth_username');
    final storedRemember = await _storage.read('auth_remember');

    if (storedRole == null) return;
    _role = storedRole == 'admin'
        ? UserRole.admin
        : storedRole == 'user'
            ? UserRole.user
            : UserRole.guest;
    _isLoggedIn = storedLogged == 'true';
    _username = storedName?.isEmpty == true ? null : storedName;
    _rememberMe = storedRemember == 'true';
    notifyListeners();
  }

  Future<void> _loadBookings() async {
    final records = await _db.fetchBookings();
    _busBookings
      ..clear()
      ..addAll(records);
    notifyListeners();
  }
}
