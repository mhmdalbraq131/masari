import 'package:flutter/foundation.dart';
import 'package:masari/models/bus_model.dart';
import 'package:masari/services/bus_service.dart';

/// State controller for bus booking flow
class BusBookingController extends ChangeNotifier {
  final BusService _busService;

  // UI State
  bool _isLoading = false;
  String? _errorMessage;

  // Data State
  List<BusCompany> _companies = [];
  List<BusTrip> _searchResults = [];
  BusTrip? _selectedTrip;
  BusCompany? _selectedCompany;
  PassengerInfo? _passengerInfo;
  BusBooking? _currentBooking;

  BusBookingController(this._busService);

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<BusCompany> get companies => _companies;
  List<BusTrip> get searchResults => _searchResults;
  BusTrip? get selectedTrip => _selectedTrip;
  BusCompany? get selectedCompany => _selectedCompany;
  PassengerInfo? get passengerInfo => _passengerInfo;
  BusBooking? get currentBooking => _currentBooking;
  bool get hasError => _errorMessage != null && _errorMessage!.isNotEmpty;

  /// Load all available bus companies
  Future<void> loadCompanies() async {
    _setLoading(true);
    _clearError();

    try {
      _companies = await _busService.getCompanies();
      notifyListeners();
    } catch (e) {
      _setError('فشل تحميل الشركات: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Select a bus company
  void selectCompany(BusCompany company) {
    _selectedCompany = company;
    notifyListeners();
  }

  /// Search for available trips
  Future<void> searchTrips(BusSearchRequest request) async {
    _setLoading(true);
    _clearError();

    try {
      _searchResults = await _busService.searchTrips(request);

      if (_searchResults.isEmpty) {
        _setError('لا توجد رحلات متاحة');
      }

      notifyListeners();
    } catch (e) {
      _setError('فشل البحث عن الرحلات: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Select a trip from search results
  void selectTrip(BusTrip trip) {
    _selectedTrip = trip;
    _clearError();
    notifyListeners();
  }

  /// Update passenger information
  void updatePassengerInfo(PassengerInfo info) {
    _passengerInfo = info;
    notifyListeners();
  }

  /// Complete the booking
  Future<bool> completeBooking() async {
    if (_selectedTrip == null || _passengerInfo == null) {
      _setError('بيانات غير كاملة');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      _currentBooking = await _busService.bookTrip(_selectedTrip!, _passengerInfo!);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('فشل إكمال الحجز: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Reset the entire booking flow
  void resetBooking() {
    _selectedTrip = null;
    _selectedCompany = null;
    _passengerInfo = null;
    _currentBooking = null;
    _searchResults = [];
    _clearError();
    notifyListeners();
  }

  /// Reset search only
  void resetSearch() {
    _searchResults = [];
    _selectedTrip = null;
    _clearError();
    notifyListeners();
  }

  // Private helpers
  void _setLoading(bool value) {
    _isLoading = value;
  }

  void _setError(String message) {
    _errorMessage = message;
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Check if booking flow is complete
  bool get isBookingComplete =>
      _selectedTrip != null &&
      _passengerInfo != null &&
      _passengerInfo!.isValid &&
      _currentBooking != null;
}
