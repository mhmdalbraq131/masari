import 'package:flutter/material.dart';
import '../data/models/booked_trip_model.dart';
import '../models/trip_details.dart';

class MyTripsService extends ChangeNotifier {
  final List<BookedTrip> _items = [];

  List<BookedTrip> get items => List.unmodifiable(_items);

  void add(BookedTrip trip) {
    _items.insert(0, trip);
    notifyListeners();
  }

  void addFromTripDetails(TripDetails trip) {
    add(
      BookedTrip(
        id: trip.id,
        title: trip.title,
        location: trip.location,
        imageUrl: trip.imageUrl,
        priceLabel: trip.priceLabel,
        status: BookedTripStatus.upcoming,
        bookedAt: DateTime.now(),
      ),
    );
  }

  void updateStatus(String id, BookedTripStatus status) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return;
    _items[index] = _items[index].copyWith(status: status);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
