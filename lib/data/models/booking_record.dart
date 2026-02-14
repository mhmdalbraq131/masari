class BookingRecord {
  final String ticketId;
  final String company;
  final DateTime date;
  final String status;

  const BookingRecord({
    required this.ticketId,
    required this.company,
    required this.date,
    required this.status,
  });

  BookingRecord copyWith({String? status}) {
    return BookingRecord(
      ticketId: ticketId,
      company: company,
      date: date,
      status: status ?? this.status,
    );
  }
}
