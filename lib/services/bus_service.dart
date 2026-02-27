import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:masari/models/bus_model.dart';
import 'package:masari/services/api_config.dart';

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

  static List<BusCompany> seedCompanies() {
    return List<BusCompany>.from(_companies);
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
  ApiBusService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Map<String, dynamic> _decodeMap(String body) {
    final json = jsonDecode(body);
    return json is Map<String, dynamic> ? json : {};
  }

  List<dynamic> _decodeList(Map<String, dynamic> json) {
    final data = json['data'];
    return data is List ? data : const [];
  }

  @override
  Future<List<BusCompany>> getCompanies() async {
    final response = await _client.get(_uri('/api/bus/companies'));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load companies');
    }
    final json = _decodeMap(response.body);
    return _decodeList(json)
        .map((item) => BusCompany.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<BusTrip>> searchTrips(BusSearchRequest request) async {
    final response = await _client.post(
      _uri('/api/bus/trips/search'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to search trips');
    }
    final json = _decodeMap(response.body);
    return _decodeList(json)
        .map((item) => BusTrip.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<BusBooking> bookTrip(BusTrip trip, PassengerInfo passenger) async {
    final response = await _client.post(
      _uri('/api/bus/bookings'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'trip_id': trip.id,
        'from_city': trip.fromCity,
        'to_city': trip.toCity,
        'date': trip.date.toIso8601String(),
        'passenger': passenger.toJson(),
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to book trip');
    }
    final json = _decodeMap(response.body);
    final data = json['data'] as Map? ?? {};
    return BusBooking.fromJson(data.cast<String, dynamic>());
  }

  @override
  Future<BusBooking?> getBooking(String bookingId) async {
    final response = await _client.get(
      _uri('/api/bus/bookings?id=$bookingId'),
    );
    if (response.statusCode == 404) return null;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load booking');
    }
    final json = _decodeMap(response.body);
    final data = json['data'] as Map?;
    if (data == null) return null;
    return BusBooking.fromJson(data.cast<String, dynamic>());
  }
}

class FirestoreBusService implements BusService {
  FirestoreBusService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _companiesRef =>
      _firestore.collection('bus_companies');

  CollectionReference<Map<String, dynamic>> get _tripsRef =>
      _firestore.collection('bus_trips');

  CollectionReference<Map<String, dynamic>> get _bookingsRef =>
      _firestore.collection('bus_bookings');

  @override
  Future<List<BusCompany>> getCompanies() async {
    final snapshot = await _companiesRef.get();
    if (snapshot.docs.isEmpty) {
      final seed = MockBusService.seedCompanies();
      final batch = _firestore.batch();
      for (final company in seed) {
        batch.set(_companiesRef.doc(company.id), company.toJson());
      }
      await batch.commit();
      return seed;
    }

    return snapshot.docs
        .map((doc) => BusCompany.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  @override
  Future<List<BusTrip>> searchTrips(BusSearchRequest request) async {
    final dateKey = request.date.toIso8601String().split('T').first;
    Query<Map<String, dynamic>> query = _tripsRef
        .where('from_city', isEqualTo: request.fromCity)
        .where('to_city', isEqualTo: request.toCity)
        .where('date', isEqualTo: dateKey);

    if (request.selectedCompanyId != null) {
      query = query.where('company_id', isEqualTo: request.selectedCompanyId);
    }

    final snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs
          .map((doc) => BusTrip.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    }

    final companies = await getCompanies();
    final trips = _generateTrips(companies, request, dateKey);
    final batch = _firestore.batch();
    for (final trip in trips) {
      batch.set(_tripsRef.doc(trip.id), trip.toJson());
    }
    await batch.commit();
    return trips;
  }

  List<BusTrip> _generateTrips(
    List<BusCompany> companies,
    BusSearchRequest request,
    String dateKey,
  ) {
    final trips = <BusTrip>[];
    final targetCompanies = request.selectedCompanyId != null
        ? companies
            .where((c) => c.id == request.selectedCompanyId)
            .toList()
        : companies;

    for (int i = 0; i < targetCompanies.length; i++) {
      final company = targetCompanies[i];
      final basePrice = 300.0 + (i * 25);
      trips.addAll([
        BusTrip(
          id: '${company.id}-$dateKey-trip-1',
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
          busType: 'سياحي',
          amenities: const ['WiFi', 'مكيف', 'وسائد'],
        ),
        BusTrip(
          id: '${company.id}-$dateKey-trip-2',
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
          busType: 'سياحي',
          amenities: const ['WiFi', 'مكيف', 'وسائد', 'شاي وقهوة'],
        ),
        BusTrip(
          id: '${company.id}-$dateKey-trip-3',
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
          busType: 'سياحي',
          amenities: const ['WiFi', 'مكيف'],
        ),
      ]);
    }

    return trips;
  }

  @override
  Future<BusBooking> bookTrip(BusTrip trip, PassengerInfo passenger) async {
    final now = DateTime.now();
    final bookingId = 'BK-${now.microsecondsSinceEpoch}';
    final booking = {
      'id': bookingId,
      'status': 'confirmed',
      'booking_date': now.toIso8601String(),
      'confirmation_number':
          'BUS-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${(now.microsecondsSinceEpoch % 10000).toString().padLeft(4, '0')}',
      'trip': trip.toJson(),
      'passenger': passenger.toJson(),
    };

    await _bookingsRef.doc(bookingId).set(booking);
    return BusBooking.fromJson(booking);
  }

  @override
  Future<BusBooking?> getBooking(String bookingId) async {
    final snapshot = await _bookingsRef.doc(bookingId).get();
    final data = snapshot.data();
    if (data == null) return null;
    return BusBooking.fromJson(data);
  }
}

// For demo purposes
class Math {
  static double random() => 0.5;
}
