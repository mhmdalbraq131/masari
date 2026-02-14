enum BookedTripStatus { upcoming, completed, cancelled }

class BookedTrip {
  final String id;
  final String title;
  final String location;
  final String imageUrl;
  final String priceLabel;
  final BookedTripStatus status;
  final DateTime bookedAt;

  const BookedTrip({
    required this.id,
    required this.title,
    required this.location,
    required this.imageUrl,
    required this.priceLabel,
    required this.status,
    required this.bookedAt,
  });

  BookedTrip copyWith({
    String? title,
    String? location,
    String? imageUrl,
    String? priceLabel,
    BookedTripStatus? status,
    DateTime? bookedAt,
  }) {
    return BookedTrip(
      id: id,
      title: title ?? this.title,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      priceLabel: priceLabel ?? this.priceLabel,
      status: status ?? this.status,
      bookedAt: bookedAt ?? this.bookedAt,
    );
  }
}
