enum HajjUmrahType { hajj, umrah }

enum HajjUmrahApplicationStatus { pending, approved, rejected, completed }

enum VisaStatus { requested, submitted, approved, rejected, issued }

enum DocumentStatus { pending, verified, rejected }

class HajjUmrahCampaign {
  final String id;
  final String name;
  final HajjUmrahType type;
  final DateTime seasonStart;
  final DateTime seasonEnd;
  final int capacity;
  final bool active;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HajjUmrahCampaign({
    required this.id,
    required this.name,
    required this.type,
    required this.seasonStart,
    required this.seasonEnd,
    required this.capacity,
    required this.active,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  HajjUmrahCampaign copyWith({
    String? name,
    HajjUmrahType? type,
    DateTime? seasonStart,
    DateTime? seasonEnd,
    int? capacity,
    bool? active,
    String? notes,
    DateTime? updatedAt,
  }) {
    return HajjUmrahCampaign(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      seasonStart: seasonStart ?? this.seasonStart,
      seasonEnd: seasonEnd ?? this.seasonEnd,
      capacity: capacity ?? this.capacity,
      active: active ?? this.active,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class HajjUmrahGroup {
  final String id;
  final String campaignId;
  final String name;
  final String supervisorName;
  final String transportPlan;
  final int capacity;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HajjUmrahGroup({
    required this.id,
    required this.campaignId,
    required this.name,
    required this.supervisorName,
    required this.transportPlan,
    required this.capacity,
    required this.createdAt,
    required this.updatedAt,
  });

  HajjUmrahGroup copyWith({
    String? name,
    String? supervisorName,
    String? transportPlan,
    int? capacity,
    DateTime? updatedAt,
  }) {
    return HajjUmrahGroup(
      id: id,
      campaignId: campaignId,
      name: name ?? this.name,
      supervisorName: supervisorName ?? this.supervisorName,
      transportPlan: transportPlan ?? this.transportPlan,
      capacity: capacity ?? this.capacity,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class HajjUmrahPackage {
  final String id;
  final String name;
  final HajjUmrahType type;
  final double priceSar;
  final int durationDays;
  final String hotelName;
  final double hotelLat;
  final double hotelLng;
  final String transportType;
  final int maxSeats;
  final String? campaignId;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HajjUmrahPackage({
    required this.id,
    required this.name,
    required this.type,
    required this.priceSar,
    required this.durationDays,
    required this.hotelName,
    required this.hotelLat,
    required this.hotelLng,
    required this.transportType,
    required this.maxSeats,
    this.campaignId,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  HajjUmrahPackage copyWith({
    String? name,
    HajjUmrahType? type,
    double? priceSar,
    int? durationDays,
    String? hotelName,
    double? hotelLat,
    double? hotelLng,
    String? transportType,
    int? maxSeats,
    String? campaignId,
    String? description,
    DateTime? updatedAt,
  }) {
    return HajjUmrahPackage(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      priceSar: priceSar ?? this.priceSar,
      durationDays: durationDays ?? this.durationDays,
      hotelName: hotelName ?? this.hotelName,
      hotelLat: hotelLat ?? this.hotelLat,
      hotelLng: hotelLng ?? this.hotelLng,
      transportType: transportType ?? this.transportType,
      maxSeats: maxSeats ?? this.maxSeats,
      campaignId: campaignId ?? this.campaignId,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class HajjUmrahApplication {
  final String id;
  final String packageId;
  final String? campaignId;
  final String? groupId;
  final String userName;
  final int age;
  final String phone;
  final int companions;
  final String passportImagePath;
  final String visaType;
  final HajjUmrahApplicationStatus status;
  final VisaStatus visaStatus;
  final String? visaReference;
  final DocumentStatus documentStatus;
  final String? documentNotes;
  final String? hotelRoomType;
  final String? hotelRoomNumber;
  final String? transportPlan;
  final String? supervisorName;
  final bool waitingList;
  final int? waitlistPosition;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HajjUmrahApplication({
    required this.id,
    required this.packageId,
    this.campaignId,
    this.groupId,
    required this.userName,
    required this.age,
    required this.phone,
    required this.companions,
    required this.passportImagePath,
    required this.visaType,
    required this.status,
    this.visaStatus = VisaStatus.requested,
    this.visaReference,
    this.documentStatus = DocumentStatus.pending,
    this.documentNotes,
    this.hotelRoomType,
    this.hotelRoomNumber,
    this.transportPlan,
    this.supervisorName,
    this.waitingList = false,
    this.waitlistPosition,
    required this.createdAt,
    required this.updatedAt,
  });

  HajjUmrahApplication copyWith({
    String? campaignId,
    String? groupId,
    int? age,
    String? phone,
    int? companions,
    String? passportImagePath,
    String? visaType,
    HajjUmrahApplicationStatus? status,
    VisaStatus? visaStatus,
    String? visaReference,
    DocumentStatus? documentStatus,
    String? documentNotes,
    String? hotelRoomType,
    String? hotelRoomNumber,
    String? transportPlan,
    String? supervisorName,
    bool? waitingList,
    int? waitlistPosition,
    DateTime? updatedAt,
  }) {
    return HajjUmrahApplication(
      id: id,
      packageId: packageId,
      campaignId: campaignId ?? this.campaignId,
      groupId: groupId ?? this.groupId,
      userName: userName,
      age: age ?? this.age,
      phone: phone ?? this.phone,
      companions: companions ?? this.companions,
      passportImagePath: passportImagePath ?? this.passportImagePath,
      visaType: visaType ?? this.visaType,
      status: status ?? this.status,
      visaStatus: visaStatus ?? this.visaStatus,
      visaReference: visaReference ?? this.visaReference,
      documentStatus: documentStatus ?? this.documentStatus,
      documentNotes: documentNotes ?? this.documentNotes,
      hotelRoomType: hotelRoomType ?? this.hotelRoomType,
      hotelRoomNumber: hotelRoomNumber ?? this.hotelRoomNumber,
      transportPlan: transportPlan ?? this.transportPlan,
      supervisorName: supervisorName ?? this.supervisorName,
      waitingList: waitingList ?? this.waitingList,
      waitlistPosition: waitlistPosition ?? this.waitlistPosition,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
