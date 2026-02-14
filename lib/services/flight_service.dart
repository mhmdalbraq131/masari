import '../data/models/flight_model.dart';

class FlightService {
  Future<List<FlightOption>> searchFlights(FlightSearchCriteria criteria) async {
    await Future.delayed(const Duration(milliseconds: 900));

    if (criteria.fromCity == criteria.toCity) {
      return [];
    }

    final baseSar = criteria.travelClass == TravelClass.business ? 950.0 : 520.0;
    final baseYer = baseSar * 150.0;

    return [
      FlightOption(
        id: 'f1',
        airline: 'السعودية',
        fromCity: criteria.fromCity,
        toCity: criteria.toCity,
        departTime: '06:20',
        arriveTime: '08:40',
        durationMinutes: 140,
        stops: 0,
        priceYER: baseYer,
        priceSAR: baseSar,
        seatsAvailable: 6,
        travelClass: criteria.travelClass,
      ),
      FlightOption(
        id: 'f2',
        airline: 'طيران ناس',
        fromCity: criteria.fromCity,
        toCity: criteria.toCity,
        departTime: '10:15',
        arriveTime: '13:05',
        durationMinutes: 170,
        stops: 1,
        priceYER: baseYer * 0.9,
        priceSAR: baseSar * 0.9,
        seatsAvailable: 3,
        travelClass: criteria.travelClass,
      ),
      FlightOption(
        id: 'f3',
        airline: 'طيران الخليج',
        fromCity: criteria.fromCity,
        toCity: criteria.toCity,
        departTime: '17:10',
        arriveTime: '19:45',
        durationMinutes: 155,
        stops: 0,
        priceYER: baseYer * 1.15,
        priceSAR: baseSar * 1.15,
        seatsAvailable: 8,
        travelClass: criteria.travelClass,
      ),
    ];
  }
}
