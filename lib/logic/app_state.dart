import 'package:flutter/material.dart';
import '../data/local_db.dart';
import '../data/models/app_notification.dart';
import '../data/models/booking_record.dart';
import '../data/repositories/mock_data.dart';

class AppState extends ChangeNotifier {
  AppState()
      : _notifications = [...MockData.initialNotifications()] {
    _loadBookings();
  }

  final List<AppNotification> _notifications;
  final List<BookingRecord> _busBookings = [];
  final LocalDb _db = LocalDb.instance;

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  List<BookingRecord> get busBookings => List.unmodifiable(_busBookings);

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

  Future<void> updateBookingWorkflow({
    required String ticketId,
    required WorkflowStatus workflowStatus,
    String? assignedTo,
    List<String>? internalNotes,
  }) async {
    final index = _busBookings.indexWhere((b) => b.ticketId == ticketId);
    if (index == -1) return;
    _busBookings[index] = _busBookings[index].copyWith(
      workflowStatus: workflowStatus,
      assignedTo: assignedTo,
      internalNotes: internalNotes,
    );
    notifyListeners();
    await _db.updateBookingWorkflow(
      ticketId: ticketId,
      workflowStatus: workflowStatus,
      assignedTo: assignedTo,
      internalNotes: internalNotes,
    );
  }


  Future<void> _loadBookings() async {
    final records = await _db.fetchBookings();
    _busBookings
      ..clear()
      ..addAll(records);
    notifyListeners();
  }
}
