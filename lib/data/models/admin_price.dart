class AdminPrice {
  final String id;
  final String title;
  final double valueSar;
  final bool enabled;

  const AdminPrice({
    required this.id,
    required this.title,
    required this.valueSar,
    required this.enabled,
  });

  AdminPrice copyWith({
    String? title,
    double? valueSar,
    bool? enabled,
  }) {
    return AdminPrice(
      id: id,
      title: title ?? this.title,
      valueSar: valueSar ?? this.valueSar,
      enabled: enabled ?? this.enabled,
    );
  }
}
