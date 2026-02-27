import 'package:flutter/material.dart';
import '../data/local_db.dart';
import '../data/models/audit_log.dart';

class AuditLogService extends ChangeNotifier {
  final LocalDb _db = LocalDb.instance;
  final List<AuditLog> _items = [];
  bool _loaded = false;

  List<AuditLog> get items => List.unmodifiable(_items);

  Future<void> load({int limit = 200}) async {
    if (_loaded) return;
    _loaded = true;
    await refresh(limit: limit);
  }

  Future<void> refresh({int limit = 200}) async {
    final logs = await _db.fetchAuditLogs(limit: limit);
    _items
      ..clear()
      ..addAll(logs);
    notifyListeners();
  }

  Future<void> log({
    required String actor,
    required String action,
    required String targetType,
    required String targetId,
    required String details,
  }) async {
    final entry = AuditLog(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      actor: actor,
      action: action,
      targetType: targetType,
      targetId: targetId,
      details: details,
      createdAt: DateTime.now(),
    );
    await _db.insertAuditLog(entry);
    _items.insert(0, entry);
    notifyListeners();
  }
}
