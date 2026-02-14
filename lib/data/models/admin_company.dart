class AdminCompany {
  final String id;
  final String name;
  final String description;
  final String? logoPath;

  const AdminCompany({
    required this.id,
    required this.name,
    required this.description,
    this.logoPath,
  });

  AdminCompany copyWith({
    String? name,
    String? description,
    String? logoPath,
  }) {
    return AdminCompany(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoPath: logoPath ?? this.logoPath,
    );
  }
}
