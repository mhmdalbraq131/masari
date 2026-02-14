import 'package:masari/models/bus_model.dart';

abstract class BusService {
  /// Get all available bus companies
  Future<List<BusCompany>> getCompanies();

  /// Search for available bus trips based on criteria
  Future<List<BusTrip>> searchTrips(BusSearchRequest request);

  /// Book a bus trip for a passenger
  Future<BusBooking> bookTrip(BusTrip trip, PassengerInfo passenger);

  /// Get booking details
  Future<BusBooking?> getBooking(String bookingId);
}

class MockBusService implements BusService {
  static final List<BusCompany> _companies = [
    const BusCompany(
      id: '1',
      name: 'al-motasadder',
      arabicName: 'المتصدر',
      logo: 'assets/bus_companies/al_motasadder.png',
      description: 'شركة موثوقة بخدمات عالية الجودة',
      rating: 4.8,
    ),
    const BusCompany(
      id: '2',
      name: 'al-baraka',
      arabicName: 'البركة',
      logo: 'assets/bus_companies/al_baraka.png',
      description: 'رحلات مريحة وآمنة',
      rating: 4.6,
    ),
    const BusCompany(
      id: '3',
      name: 'al-afdal',
      arabicName: 'الأفضل',
      logo: 'assets/bus_companies/al_afdal.png',
      description: 'أسعار منافسة وخدمة ممتازة',
      rating: 4.5,
    ),
    const BusCompany(
      id: '4',
      name: 'al-odyat',
      arabicName: 'العديات',
      logo: 'assets/bus_companies/al_odyat.png',
      description: 'تجربة سفر راقية',
      rating: 4.7,
    ),
    const BusCompany(
      id: '5',
      name: 'al-kahli',
      arabicName: 'الكهلي',
      logo: 'assets/bus_companies/al_kahli.png',
      description: 'خدمة عملاء ممتازة',
      rating: 4.4,
    ),
    const BusCompany(
      id: '6',
      name: 'al-baraq',
      arabicName: 'البراق',
      logo: 'assets/bus_companies/al_baraq.png',
      description: 'رحلات سريعة وآنية',
      rating: 4.5,
    ),
    const BusCompany(
      id: '7',
      name: 'rawaf',
      arabicName: 'رواف',
      logo: 'assets/bus_companies/rawaf.png',
      description: 'تنقل آمن وموثوق',
      rating: 4.3,
    ),
  ];

  @override
  Future<List<BusCompany>> getCompanies() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _companies;
  }

  @override
  Future<List<BusTrip>> searchTrips(BusSearchRequest request) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return _generateMockTrips(request);
  }

  List<BusTrip> _generateMockTrips(BusSearchRequest request) {
    final trips = <BusTrip>[];
    final companies = request.selectedCompanyId != null
        ? [_companies.firstWhere((c) => c.id == request.selectedCompanyId)]
        : _companies;

    for (int i = 0; i < companies.length; i++) {
      final company = companies[i];
      final basePrice = 300.0 + (i * 25);

      trips.addAll([
        BusTrip(
          id: '${company.id}-trip-1',
          companyId: company.id,
          company: company.arabicName,
          fromCity: request.fromCity,
          toCity: request.toCity,
          date: request.date,
          departureTime: '08:30',
          arrivalTime: '12:45',
          availableSeats: 15,
          priceYER: basePrice * 150,
          priceSAR: basePrice,
          totalSeats: 50,
          amenities: const ['WiFi', 'مكيف', 'وسائد'],
        ),
        BusTrip(
          id: '${company.id}-trip-2',
          companyId: company.id,
          company: company.arabicName,
          fromCity: request.fromCity,
          toCity: request.toCity,
          date: request.date,
          departureTime: '12:15',
          arrivalTime: '16:30',
          availableSeats: 8,
          priceYER: (basePrice + 50) * 150,
          priceSAR: basePrice + 50,
          totalSeats: 50,
          amenities: const ['WiFi', 'مكيف', 'وسائد', 'شاي وقهوة'],
        ),
        BusTrip(
          id: '${company.id}-trip-3',
          companyId: company.id,
          company: company.arabicName,
          fromCity: request.fromCity,
          toCity: request.toCity,
          date: request.date,
          departureTime: '18:45',
          arrivalTime: '23:00',
          availableSeats: 22,
          priceYER: (basePrice - 25) * 150,
          priceSAR: basePrice - 25,
          totalSeats: 50,
          amenities: const ['WiFi', 'مكيف'],
        ),
      ]);
    }

    return trips;
  }

  @override
  Future<BusBooking> bookTrip(BusTrip trip, PassengerInfo passenger) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return BusBooking(
      id: 'BK-${DateTime.now().millisecondsSinceEpoch}',
      trip: trip,
      passenger: passenger,
      bookingDate: DateTime.now(),
      status: 'confirmed',
      confirmationNumber: 'BUS-${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}-${(Math.random() * 10000).toInt()}',
    );
  }

  @override
  Future<BusBooking?> getBooking(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return null;
  }
}

class ApiBusService implements BusService {
  final MockBusService _mockService = MockBusService();

  @override
  Future<List<BusCompany>> getCompanies() {
    // TODO: Replace with API call
    return _mockService.getCompanies();
  }

  @override
  Future<List<BusTrip>> searchTrips(BusSearchRequest request) {
    // TODO: Replace with API call
    return _mockService.searchTrips(request);
  }

  @override
  Future<BusBooking> bookTrip(BusTrip trip, PassengerInfo passenger) {
    // TODO: Replace with API call
    return _mockService.bookTrip(trip, passenger);
  }

  @override
  Future<BusBooking?> getBooking(String bookingId) {
    // TODO: Replace with API call
    return _mockService.getBooking(bookingId);
  }
}

// For demo purposes
class Math {
  static double random() => 0.5;
}
