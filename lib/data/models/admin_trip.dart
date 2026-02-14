class AdminTrip {
  final String id;
  final String fromRegion;
  final String toRegion;
  final String time;
  final double priceSar;
  final int seats;
  final bool enabled;

  const AdminTrip({
    required this.id,
    required this.fromRegion,
    required this.toRegion,
    required this.time,
    required this.priceSar,
    required this.seats,
    required this.enabled,
  });

  String get route => '$fromRegion → $toRegion';

  AdminTrip copyWith({
    String? fromRegion,
    String? toRegion,
    String? time,
    double? priceSar,
    int? seats,
    bool? enabled,
  }) {
    return AdminTrip(
      id: id,
      fromRegion: fromRegion ?? this.fromRegion,
      toRegion: toRegion ?? this.toRegion,
      time: time ?? this.time,
      priceSar: priceSar ?? this.priceSar,
      seats: seats ?? this.seats,
      enabled: enabled ?? this.enabled,
    );
  }
}
