// Bus Company Model
class BusCompany {
  final String id;
  final String name;
  final String arabicName;
  final String logo; // Asset path
  final String description;
  final double rating;

  const BusCompany({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.logo,
    required this.description,
    required this.rating,
  });
}

// Bus Trip Model
class BusTrip {
  final String id;
  final String companyId;
  final String company;
  final String fromCity;
  final String toCity;
  final DateTime date;
  final String departureTime;
  final String arrivalTime;
  final int availableSeats;
  final double priceYER;
  final double priceSAR;
  final int totalSeats;
  final String busType; // e.g., "شاحن", "سياحي"
  final List<String> amenities; // e.g., ["WiFi", "مكيف", "وسائد"]

  const BusTrip({
    required this.id,
    required this.companyId,
    required this.company,
    required this.fromCity,
    required this.toCity,
    required this.date,
    required this.departureTime,
    required this.arrivalTime,
    required this.availableSeats,
    required this.priceYER,
    required this.priceSAR,
    required this.totalSeats,
    this.busType = 'شاحن',
    this.amenities = const [],
  });

  // Helper to check if seats are low
  bool get isLowSeats => availableSeats <= 5;

  // Helper to get seat percentage
  double get seatPercentage => (availableSeats / totalSeats) * 100;
}

// Passenger Information Model
class PassengerInfo {
  final String fullName;
  final String phone;
  final String reasonForTravel;
  final String visaType;
  final String? passportImagePath;
  final DateTime createdAt;

  PassengerInfo({
    required this.fullName,
    required this.phone,
    required this.reasonForTravel,
    required this.visaType,
    this.passportImagePath,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Validation
  bool get isValid =>
      fullName.isNotEmpty &&
      phone.isNotEmpty &&
      reasonForTravel.isNotEmpty &&
      visaType.isNotEmpty &&
      passportImagePath != null;
}

// Bus Booking Model
class BusBooking {
  final String id;
  final BusTrip trip;
  final PassengerInfo passenger;
  final DateTime bookingDate;
  final String status; // pending, confirmed, cancelled
  final String? confirmationNumber;

  const BusBooking({
    required this.id,
    required this.trip,
    required this.passenger,
    required this.bookingDate,
    this.status = 'pending',
    this.confirmationNumber,
  });
}

// Search Request Model
class BusSearchRequest {
  final String fromCity;
  final String toCity;
  final DateTime date;
  final int passengerCount;
  final String? selectedCompanyId;

  const BusSearchRequest({
    required this.fromCity,
    required this.toCity,
    required this.date,
    required this.passengerCount,
    this.selectedCompanyId,
  });
}

// Visa Types
class BusConstants {
  static const List<String> visaTypes = [
    'تأشيرة سياحية',
    'تأشيرة عمل',
    'تأشيرة زيارة عائلية',
    'تأشيرة علاجية',
    'تأشيرة تجارية',
    'تأشيرة أخرى',
  ];

  static const List<String> travelReasons = [
    'سياحة',
    'عمل',
    'زيارة عائلية',
    'علاج',
    'تجارة',
    'إجازة',
    'أخرى',
  ];

  static const List<String> saudiCities = [
    'الرياض',
    'جدة',
    'الدمام',
    'المدينة المنورة',
    'مكة المكرمة',
    'أبها',
    'الخبر',
    'الكويت',
    'الدقم',
    'نجران',
  ];

  static const List<String> yemenCities = [
    'صنعاء',
    'عدن',
    'تعز',
    'إب',
    'المكلا',
    'الحديدة',
    'ذمار',
    'مأرب',
  ];

  static const List<String> busCompanies = [
    'المتصدر',
    'البركة',
    'الأفضل',
    'العديات',
    'الكهلي',
    'البراق',
    'رواف',
  ];
}
