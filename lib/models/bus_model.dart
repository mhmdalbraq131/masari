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

  factory BusCompany.fromJson(Map<String, dynamic> json) {
    return BusCompany(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      arabicName: json['arabic_name']?.toString() ??
          json['arabicName']?.toString() ??
          '',
      logo: json['logo']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'arabic_name': arabicName,
      'logo': logo,
      'description': description,
      'rating': rating,
    };
  }
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

  factory BusTrip.fromJson(Map<String, dynamic> json) {
    final parsedDate = DateTime.tryParse(json['date']?.toString() ?? '');
    return BusTrip(
      id: json['id']?.toString() ?? '',
      companyId: json['company_id']?.toString() ??
          json['companyId']?.toString() ??
          '',
      company: json['company']?.toString() ?? '',
      fromCity: json['from_city']?.toString() ??
          json['fromCity']?.toString() ??
          '',
      toCity: json['to_city']?.toString() ??
          json['toCity']?.toString() ??
          '',
      date: parsedDate ?? DateTime.now(),
      departureTime: json['departure_time']?.toString() ??
          json['departureTime']?.toString() ??
          '',
      arrivalTime: json['arrival_time']?.toString() ??
          json['arrivalTime']?.toString() ??
          '',
      availableSeats: (json['available_seats'] ?? json['availableSeats'] ?? 0)
          as int,
      priceYER: (json['price_yer'] ?? json['priceYER'] ?? 0).toDouble(),
      priceSAR: (json['price_sar'] ?? json['priceSAR'] ?? 0).toDouble(),
      totalSeats: (json['total_seats'] ?? json['totalSeats'] ?? 0) as int,
      busType: json['bus_type']?.toString() ??
          json['busType']?.toString() ??
          'شاحن',
      amenities: (json['amenities'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'company': company,
      'from_city': fromCity,
      'to_city': toCity,
      'date': date.toIso8601String().split('T').first,
      'departure_time': departureTime,
      'arrival_time': arrivalTime,
      'available_seats': availableSeats,
      'price_yer': priceYER,
      'price_sar': priceSAR,
      'total_seats': totalSeats,
      'bus_type': busType,
      'amenities': amenities,
    };
  }

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

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'phone': phone,
      'reason_for_travel': reasonForTravel,
      'visa_type': visaType,
      'passport_image_path': passportImagePath,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PassengerInfo.fromJson(Map<String, dynamic> json) {
    return PassengerInfo(
      fullName: json['full_name']?.toString() ??
          json['fullName']?.toString() ??
          '',
      phone: json['phone']?.toString() ?? '',
      reasonForTravel: json['reason_for_travel']?.toString() ??
          json['reasonForTravel']?.toString() ??
          '',
      visaType: json['visa_type']?.toString() ??
          json['visaType']?.toString() ??
          '',
      passportImagePath: json['passport_image_path']?.toString() ??
          json['passportImagePath']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }

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

  factory BusBooking.fromJson(Map<String, dynamic> json) {
    return BusBooking(
      id: json['id']?.toString() ?? '',
      trip: BusTrip.fromJson(
          (json['trip'] as Map?)?.cast<String, dynamic>() ?? {}),
      passenger: PassengerInfo.fromJson(
          (json['passenger'] as Map?)?.cast<String, dynamic>() ?? {}),
      bookingDate:
          DateTime.tryParse(json['booking_date']?.toString() ?? '') ??
              DateTime.now(),
      status: json['status']?.toString() ?? 'pending',
      confirmationNumber: json['confirmation_number']?.toString() ??
          json['confirmationNumber']?.toString(),
    );
  }
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

  Map<String, dynamic> toJson() {
    return {
      'from_city': fromCity,
      'to_city': toCity,
      'date': date.toIso8601String(),
      'passenger_count': passengerCount,
      'selected_company_id': selectedCompanyId,
    };
  }
}

// Visa Types
class BusConstants {
  static const List<String> visaTypes = [
    'تأشيرة سياحية',
    'تأشيرة عمل',
    'تأشيرة زيارة عائلية',
    'تأشيرة علاجية',
    'تأشيرة عمرة',
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
