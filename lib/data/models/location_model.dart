class LocationEntry {
  final String id;
  final String name;

  const LocationEntry({
    required this.id,
    required this.name,
  });

  LocationEntry copyWith({
    String? name,
  }) {
    return LocationEntry(
      id: id,
      name: name ?? this.name,
    );
  }
}
