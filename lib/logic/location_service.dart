import 'package:flutter/material.dart';
import '../data/local_db.dart';
import '../data/models/location_model.dart';

class LocationService extends ChangeNotifier {
  final LocalDb _db = LocalDb.instance;
  final List<LocationEntry> _locations = [];
  bool _loaded = false;

  List<LocationEntry> get locations => List.unmodifiable(_locations);

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    await refresh();
  }

  Future<void> refresh() async {
    final items = await _db.fetchLocations();
    _locations
      ..clear()
      ..addAll(items);
    notifyListeners();
  }

  Future<void> upsert(LocationEntry entry) async {
    await _db.upsertLocation(entry);
    await refresh();
  }

  Future<void> delete(String id) async {
    await _db.deleteLocation(id);
    await refresh();
  }
}
