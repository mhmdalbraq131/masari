enum WorkflowStatus { received, verified, approved, paid, completed }

class BookingRecord {
  final String ticketId;
  final String company;
  final DateTime date;
  final String status;
  final double amountSar;
  final String userName;
  final WorkflowStatus workflowStatus;
  final String? assignedTo;
  final List<String> internalNotes;

  const BookingRecord({
    required this.ticketId,
    required this.company,
    required this.date,
    required this.status,
    required this.amountSar,
    required this.userName,
    this.workflowStatus = WorkflowStatus.received,
    this.assignedTo,
    this.internalNotes = const [],
  });

  BookingRecord copyWith({
    String? status,
    double? amountSar,
    String? userName,
    WorkflowStatus? workflowStatus,
    String? assignedTo,
    List<String>? internalNotes,
  }) {
    return BookingRecord(
      ticketId: ticketId,
      company: company,
      date: date,
      status: status ?? this.status,
      amountSar: amountSar ?? this.amountSar,
      userName: userName ?? this.userName,
      workflowStatus: workflowStatus ?? this.workflowStatus,
      assignedTo: assignedTo ?? this.assignedTo,
      internalNotes: internalNotes ?? this.internalNotes,
    );
  }
}
