import 'package:flutter/material.dart';
import '../data/local_db.dart';
import '../data/models/hajj_umrah_models.dart';

class HajjUmrahService extends ChangeNotifier {
  final LocalDb _db = LocalDb.instance;
  final List<HajjUmrahPackage> _packages = [];
  final List<HajjUmrahApplication> _applications = [];
  final List<HajjUmrahCampaign> _campaigns = [];
  final List<HajjUmrahGroup> _groups = [];
  bool _loaded = false;

  List<HajjUmrahPackage> get packages => List.unmodifiable(_packages);
  List<HajjUmrahApplication> get applications =>
      List.unmodifiable(_applications);
  List<HajjUmrahCampaign> get campaigns => List.unmodifiable(_campaigns);
  List<HajjUmrahGroup> get groups => List.unmodifiable(_groups);

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    await refresh();
  }

  Future<void> refresh() async {
    final pkgs = await _db.fetchHajjUmrahPackages();
    final apps = await _db.fetchHajjUmrahApplications();
    final campaigns = await _db.fetchHajjUmrahCampaigns();
    final groups = await _db.fetchHajjUmrahGroups();
    _packages
      ..clear()
      ..addAll(pkgs);
    _applications
      ..clear()
      ..addAll(apps);
    _campaigns
      ..clear()
      ..addAll(campaigns);
    _groups
      ..clear()
      ..addAll(groups);
    notifyListeners();
  }

  Future<void> upsertPackage(HajjUmrahPackage pkg) async {
    await _db.upsertHajjUmrahPackage(pkg);
    await refresh();
  }

  Future<void> deletePackage(String id) async {
    await _db.deleteHajjUmrahPackage(id);
    await refresh();
  }

  Future<void> addApplication(HajjUmrahApplication app) async {
    final enriched = _assignCampaignAndGroup(app);
    await _db.insertHajjUmrahApplication(enriched);
    await refresh();
  }

  Future<void> updateApplicationStatus(
    String id,
    HajjUmrahApplicationStatus status,
  ) async {
    await _db.updateHajjUmrahApplicationStatus(id, status);
    await refresh();
  }

  Future<void> updateApplicationDetails(HajjUmrahApplication updated) async {
    await _db.updateHajjUmrahApplicationDetails(
      id: updated.id,
      status: updated.status,
      visaStatus: updated.visaStatus,
      documentStatus: updated.documentStatus,
      visaReference: updated.visaReference,
      documentNotes: updated.documentNotes,
      groupId: updated.groupId,
      supervisorName: updated.supervisorName,
      transportPlan: updated.transportPlan,
      hotelRoomType: updated.hotelRoomType,
      hotelRoomNumber: updated.hotelRoomNumber,
      waitingList: updated.waitingList,
      waitlistPosition: updated.waitlistPosition,
    );
    await refresh();
  }

  Future<HajjUmrahApplication?> latestApplicationForUser(
    String userName,
  ) {
    return _db.fetchLatestApplicationForUser(userName);
  }

  Future<void> upsertCampaign(HajjUmrahCampaign campaign) async {
    await _db.upsertHajjUmrahCampaign(campaign);
    await refresh();
  }

  Future<void> deleteCampaign(String id) async {
    await _db.deleteHajjUmrahCampaign(id);
    await refresh();
  }

  Future<void> upsertGroup(HajjUmrahGroup group) async {
    await _db.upsertHajjUmrahGroup(group);
    await refresh();
  }

  Future<void> deleteGroup(String id) async {
    await _db.deleteHajjUmrahGroup(id);
    await refresh();
  }

  HajjUmrahCampaign? activeCampaignForType(HajjUmrahType type) {
    final now = DateTime.now();
    for (final campaign in _campaigns) {
      if (campaign.type != type || !campaign.active) continue;
      if (now.isBefore(campaign.seasonStart)) continue;
      if (now.isAfter(campaign.seasonEnd)) continue;
      return campaign;
    }
    for (final campaign in _campaigns) {
      if (campaign.type == type && campaign.active) return campaign;
    }
    return null;
  }

  HajjUmrahGroup? _firstAvailableGroup(String? campaignId, int seats) {
    if (campaignId == null) return null;
    final candidates = _groups.where((g) => g.campaignId == campaignId).toList();
    for (final group in candidates) {
      final used = _applications
          .where((a) => a.groupId == group.id)
          .fold<int>(0, (sum, a) => sum + 1 + a.companions);
      if (used + seats <= group.capacity) return group;
    }
    return null;
  }

  int campaignUsedSeats(String campaignId) {
    return _applications
        .where((app) => app.campaignId == campaignId)
        .where((app) => app.status != HajjUmrahApplicationStatus.rejected)
        .fold<int>(0, (sum, app) => sum + 1 + app.companions);
  }

  int campaignRemainingSeats(String campaignId) {
    final campaign = _campaigns.firstWhere(
      (c) => c.id == campaignId,
      orElse: () => HajjUmrahCampaign(
        id: '_missing',
        name: '',
        type: HajjUmrahType.hajj,
        seasonStart: DateTime.fromMillisecondsSinceEpoch(0),
        seasonEnd: DateTime.fromMillisecondsSinceEpoch(0),
        capacity: 0,
        active: false,
        notes: '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
      ),
    );
    if (campaign.id == '_missing') return 0;
    final used = campaignUsedSeats(campaignId);
    final remaining = campaign.capacity - used;
    return remaining < 0 ? 0 : remaining;
  }

  int waitingListCount(String campaignId) {
    return _applications
        .where((app) => app.campaignId == campaignId)
        .where((app) => app.waitingList)
        .length;
  }

  HajjUmrahApplication _assignCampaignAndGroup(HajjUmrahApplication app) {
    final package = _packages.firstWhere(
      (p) => p.id == app.packageId,
      orElse: () => HajjUmrahPackage(
        id: '_missing',
        name: '',
        type: HajjUmrahType.hajj,
        priceSar: 0,
        durationDays: 0,
        hotelName: '',
        hotelLat: 0,
        hotelLng: 0,
        transportType: '',
        maxSeats: 0,
        description: '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
      ),
    );
    final campaignId = package.campaignId ??
        activeCampaignForType(package.type)?.id ??
        app.campaignId;

    final seats = 1 + app.companions;
    final remaining = campaignId == null ? 0 : campaignRemainingSeats(campaignId);
    final waiting = campaignId == null ? true : remaining < seats;
    final waitPosition = waiting && campaignId != null
        ? waitingListCount(campaignId) + 1
        : null;

    final group = _firstAvailableGroup(campaignId, seats);

    return app.copyWith(
      groupId: group?.id,
      supervisorName: group?.supervisorName,
      transportPlan: group?.transportPlan,
      waitingList: waiting,
      waitlistPosition: waitPosition,
      updatedAt: DateTime.now(),
    ).copyWith(
      campaignId: campaignId,
    );
  }

  int remainingSeats(String packageId) {
    final pkg = _packages.firstWhere(
      (item) => item.id == packageId,
      orElse: () => HajjUmrahPackage(
        id: '_missing',
        name: '',
        type: HajjUmrahType.hajj,
        priceSar: 0,
        durationDays: 0,
        hotelName: '',
        hotelLat: 0,
        hotelLng: 0,
        transportType: '',
        maxSeats: 0,
        description: '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
      ),
    );
    if (pkg.id == '_missing') return 0;
    final used = _applications
        .where((app) => app.packageId == packageId)
        .fold<int>(0, (sum, app) => sum + 1 + app.companions);
    final remaining = pkg.maxSeats - used;
    return remaining < 0 ? 0 : remaining;
  }

  int totalApplicationsForPackage(String packageId) {
    return _applications.where((app) => app.packageId == packageId).length;
  }
}
