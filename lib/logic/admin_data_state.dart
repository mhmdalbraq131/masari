import 'package:flutter/material.dart';
import '../data/local_db.dart';
import '../data/models/admin_company.dart';
import '../data/models/admin_price.dart';
import '../data/models/admin_trip.dart';
import '../data/models/admin_user.dart';

class AdminDataState extends ChangeNotifier {
  AdminDataState() {
    _loadFromDb();
  }

  final LocalDb _db = LocalDb.instance;
  final List<AdminCompany> _companies = [];
  final List<AdminTrip> _trips = [];
  final List<AdminPrice> _prices = [];
  final List<AdminUser> _users = [];

  List<AdminCompany> get companies => List.unmodifiable(_companies);
  List<AdminTrip> get trips => List.unmodifiable(_trips);
  List<AdminPrice> get prices => List.unmodifiable(_prices);
  List<AdminUser> get users => List.unmodifiable(_users);

  Future<void> _loadFromDb() async {
    final companies = await _db.fetchAdminCompanies();
    final trips = await _db.fetchAdminTrips();
    final prices = await _db.fetchAdminPrices();
    final users = await _db.fetchAdminUsers();

    _companies
      ..clear()
      ..addAll(companies);
    _trips
      ..clear()
      ..addAll(trips);
    _prices
      ..clear()
      ..addAll(prices);
    _users
      ..clear()
      ..addAll(users);
    notifyListeners();
  }

  Future<void> addCompany(AdminCompany company) async {
    _companies.add(company);
    notifyListeners();
    await _db.upsertAdminCompany(company);
  }

  Future<void> updateCompany(String id, AdminCompany updated) async {
    final index = _companies.indexWhere((c) => c.id == id);
    if (index == -1) return;
    _companies[index] = updated;
    notifyListeners();
    await _db.upsertAdminCompany(updated);
  }

  Future<void> deleteCompany(String id) async {
    _companies.removeWhere((c) => c.id == id);
    notifyListeners();
    await _db.deleteAdminCompany(id);
  }

  Future<void> addTrip(AdminTrip trip) async {
    _trips.add(trip);
    notifyListeners();
    await _db.upsertAdminTrip(trip);
  }

  Future<void> updateTrip(String id, AdminTrip updated) async {
    final index = _trips.indexWhere((t) => t.id == id);
    if (index == -1) return;
    _trips[index] = updated;
    notifyListeners();
    await _db.upsertAdminTrip(updated);
  }

  Future<void> toggleTrip(String id, bool enabled) async {
    final index = _trips.indexWhere((t) => t.id == id);
    if (index == -1) return;
    _trips[index] = _trips[index].copyWith(enabled: enabled);
    notifyListeners();
    await _db.upsertAdminTrip(_trips[index]);
  }

  Future<void> addPrice(AdminPrice price) async {
    _prices.add(price);
    notifyListeners();
    await _db.upsertAdminPrice(price);
  }

  Future<void> updatePrice(String id, AdminPrice updated) async {
    final index = _prices.indexWhere((p) => p.id == id);
    if (index == -1) return;
    _prices[index] = updated;
    notifyListeners();
    await _db.upsertAdminPrice(updated);
  }

  Future<void> updateUser(String id, AdminUser updated) async {
    final index = _users.indexWhere((u) => u.id == id);
    if (index == -1) return;
    _users[index] = updated;
    notifyListeners();
    await _db.upsertAdminUser(updated);
  }
}
