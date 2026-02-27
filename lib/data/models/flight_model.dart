enum TravelClass { economy, business }

enum FlightSort { price, time }

class FlightSearchCriteria {
  final String fromCity;
  final String toCity;
  final DateTime departureDate;
  final DateTime? returnDate;
  final int passengers;
  final TravelClass travelClass;

  const FlightSearchCriteria({
    required this.fromCity,
    required this.toCity,
    required this.departureDate,
    this.returnDate,
    required this.passengers,
    required this.travelClass,
  });
}

class FlightOption {
  final String id;
  final String airline;
  final String fromCity;
  final String toCity;
  final String departTime;
  final String arriveTime;
  final int durationMinutes;
  final int stops;
  final double priceYER;
  final double priceSAR;
  final int seatsAvailable;
  final TravelClass travelClass;

  const FlightOption({
    required this.id,
    required this.airline,
    required this.fromCity,
    required this.toCity,
    required this.departTime,
    required this.arriveTime,
    required this.durationMinutes,
    required this.stops,
    required this.priceYER,
    required this.priceSAR,
    required this.seatsAvailable,
    required this.travelClass,
  });
}

class FlightSelection {
  final FlightSearchCriteria criteria;
  final FlightOption flight;

  const FlightSelection({
    required this.criteria,
    required this.flight,
  });
}

class FlightBookingData {
  final FlightSelection selection;
  final String passengerName;
  final String passengerPhone;
  final String passengerEmail;
  final String confirmationNumber;
  final DateTime bookedAt;
  final double totalPriceSar;

  const FlightBookingData({
    required this.selection,
    required this.passengerName,
    required this.passengerPhone,
    required this.passengerEmail,
    required this.confirmationNumber,
    required this.bookedAt,
    required this.totalPriceSar,
  });
}
