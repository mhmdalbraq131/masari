import 'package:flutter/material.dart';
import '../data/models/favorite_trip_model.dart';
import '../models/trip_details.dart';

class FavoritesService extends ChangeNotifier {
  final List<FavoriteTrip> _items = [];

  List<FavoriteTrip> get items => List.unmodifiable(_items);

  bool isFavorite(String id) => _items.any((item) => item.id == id);

  void add(FavoriteTrip trip) {
    if (isFavorite(trip.id)) return;
    _items.add(trip);
    notifyListeners();
  }

  void addFromTripDetails(TripDetails trip) {
    add(
      FavoriteTrip(
        id: trip.id,
        title: trip.title,
        location: trip.location,
        imageUrl: trip.imageUrl,
        description: trip.description,
        priceLabel: trip.priceLabel,
      ),
    );
  }

  void remove(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
