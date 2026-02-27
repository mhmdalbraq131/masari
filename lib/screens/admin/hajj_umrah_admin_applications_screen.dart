import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_service.dart';
import '../../data/models/hajj_umrah_models.dart';
import '../../logic/app_state.dart';
import '../../logic/hajj_umrah_service.dart';
import '../../services/audit_log_service.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/responsive_container.dart';

class HajjUmrahAdminApplicationsScreen extends StatefulWidget {
  const HajjUmrahAdminApplicationsScreen({super.key});

  @override
  State<HajjUmrahAdminApplicationsScreen> createState() =>
      _HajjUmrahAdminApplicationsScreenState();
}

class _HajjUmrahAdminApplicationsScreenState
    extends State<HajjUmrahAdminApplicationsScreen> {
  String? _packageFilter;
  HajjUmrahApplicationStatus? _statusFilter;
  DateTime? _fromDate;
  DateTime? _toDate;

  List<HajjUmrahApplication> _filter(
    List<HajjUmrahApplication> items,
    HajjUmrahService service,
  ) {
    return items.where((app) {
      if (_packageFilter != null && app.packageId != _packageFilter) {
        return false;
      }
      if (_statusFilter != null && app.status != _statusFilter) return false;
      if (_fromDate != null) {
        final from = DateTime(_fromDate!.year, _fromDate!.month, _fromDate!.day);
        if (app.createdAt.isBefore(from)) return false;
      }
      if (_toDate != null) {
        final to = DateTime(_toDate!.year, _toDate!.month, _toDate!.day);
        if (app.createdAt.isAfter(to)) return false;
      }
      return true;
    }).toList();
  }

  String _statusLabel(HajjUmrahApplicationStatus status) {
    switch (status) {
      case HajjUmrahApplicationStatus.approved:
        return 'مقبولة';
      case HajjUmrahApplicationStatus.rejected:
        return 'مرفوضة';
      case HajjUmrahApplicationStatus.completed:
        return 'مكتملة';
      case HajjUmrahApplicationStatus.pending:
        return 'قيد المراجعة';
    }
  }

  String _visaLabel(VisaStatus status) {
    switch (status) {
      case VisaStatus.requested:
        return 'طلب جديد';
      case VisaStatus.submitted:
        return 'تم الإرسال';
      case VisaStatus.approved:
        return 'تمت الموافقة';
      case VisaStatus.rejected:
        return 'مرفوضة';
      case VisaStatus.issued:
        return 'تم الإصدار';
    }
  }

  String _docLabel(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.pending:
        return 'قيد المراجعة';
      case DocumentStatus.verified:
        return 'موثقة';
      case DocumentStatus.rejected:
        return 'مرفوضة';
    }
  }

  Future<void> _exportPdf(
    List<HajjUmrahApplication> items,
    HajjUmrahService service,
  ) async {
    final doc = pw.Document();
    final formatter = DateFormat('yyyy/MM/dd');
    doc.addPage(
      pw.MultiPage(
        build: (_) => [
          pw.Text('طلبات الحج والعمرة', style: pw.TextStyle(fontSize: 20)),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(
            headers: ['الاسم', 'الباقة', 'الحالة', 'التاريخ'],
            data: items
                .map(
                  (app) => [
                    app.userName,
                    service.packages
                            .firstWhere(
                              (p) => p.id == app.packageId,
                              orElse: () => HajjUmrahPackage(
                                id: '_missing',
                                name: 'غير معروف',
                                type: HajjUmrahType.hajj,
                                priceSar: 0,
                                durationDays: 0,
                                hotelName: '',
                                hotelLat: 0,
                                hotelLng: 0,
                                transportType: '',
                                maxSeats: 0,
                                description: '',
                                createdAt:
                                    DateTime.fromMillisecondsSinceEpoch(0),
                                updatedAt:
                                    DateTime.fromMillisecondsSinceEpoch(0),
                              ),
                            )
                            .name,
                    _statusLabel(app.status),
                    formatter.format(app.createdAt),
                  ],
                )
                .toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (_) => doc.save());
  }

  Future<void> _exportPilgrimList(
    List<HajjUmrahApplication> items,
    HajjUmrahService service,
  ) async {
    final doc = pw.Document();
    final formatter = DateFormat('yyyy/MM/dd');

    doc.addPage(
      pw.MultiPage(
        build: (_) => [
          pw.Text('قائمة الحجاج والمعتمرين',
              style: pw.TextStyle(fontSize: 20)),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(
            headers: [
              'الاسم',
              'الباقة',
              'الحملة',
              'المجموعة',
              'التأشيرة',
              'التوثيق',
              'المشرف',
              'الغرفة',
              'التاريخ',
            ],
            data: items
                .map(
                  (app) {
                    final pkg = service.packages
                        .firstWhere(
                          (p) => p.id == app.packageId,
                          orElse: () => HajjUmrahPackage(
                            id: '_missing',
                            name: 'غير معروف',
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
                        )
                        .name;
                    final campaign = service.campaigns
                        .firstWhere(
                          (c) => c.id == app.campaignId,
                          orElse: () => HajjUmrahCampaign(
                            id: '_missing',
                            name: 'غير معروف',
                            type: HajjUmrahType.hajj,
                            seasonStart: DateTime.fromMillisecondsSinceEpoch(0),
                            seasonEnd: DateTime.fromMillisecondsSinceEpoch(0),
                            capacity: 0,
                            active: false,
                            notes: '',
                            createdAt: DateTime.fromMillisecondsSinceEpoch(0),
                            updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
                          ),
                        )
                        .name;
                    final group = service.groups
                        .firstWhere(
                          (g) => g.id == app.groupId,
                          orElse: () => HajjUmrahGroup(
                            id: '_missing',
                            campaignId: '',
                            name: 'غير معروف',
                            supervisorName: '',
                            transportPlan: '',
                            capacity: 0,
                            createdAt: DateTime.fromMillisecondsSinceEpoch(0),
                            updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
                          ),
                        )
                        .name;
                    final room = app.hotelRoomNumber == null
                        ? ''
                        : '${app.hotelRoomType ?? ''} ${app.hotelRoomNumber ?? ''}'.trim();
                    return [
                      app.userName,
                      pkg,
                      campaign,
                      group,
                      _visaLabel(app.visaStatus),
                      _docLabel(app.documentStatus),
                      app.supervisorName ?? '',
                      room,
                      formatter.format(app.createdAt),
                    ];
                  },
                )
                .toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (_) => doc.save());
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<HajjUmrahService>();
    final filtered = _filter(service.applications, service);

    return Scaffold(
      appBar: BrandedAppBar(
        title: 'طلبات الحج والعمرة',
        actions: [
          IconButton(
            onPressed: () => _exportPdf(filtered, service),
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'تصدير/طباعة',
          ),
          IconButton(
            onPressed: () => _exportPilgrimList(filtered, service),
            icon: const Icon(Icons.assignment_ind_outlined),
            tooltip: 'تصدير قائمة الحجاج',
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _FiltersCard(
                packages: service.packages,
                packageFilter: _packageFilter,
                statusFilter: _statusFilter,
                fromDate: _fromDate,
                toDate: _toDate,
                onPackageChanged: (value) =>
                    setState(() => _packageFilter = value),
                onStatusChanged: (value) =>
                    setState(() => _statusFilter = value),
                onPickFrom: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _fromDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _fromDate = picked);
                },
                onPickTo: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _toDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _toDate = picked);
                },
                onClear: () => setState(() {
                  _packageFilter = null;
                  _statusFilter = null;
                  _fromDate = null;
                  _toDate = null;
                }),
              ),
              const SizedBox(height: 16),
              if (filtered.isEmpty)
                const _EmptyState()
              else
                ...filtered.map(
                  (app) => _ApplicationCard(
                    application: app,
                    packageName: service.packages
                        .firstWhere(
                          (p) => p.id == app.packageId,
                          orElse: () => HajjUmrahPackage(
                            id: '_missing',
                            name: 'غير معروف',
                            type: HajjUmrahType.hajj,
                            priceSar: 0,
                            durationDays: 0,
                            hotelName: '',
                            hotelLat: 0,
                            hotelLng: 0,
                            transportType: '',
                            maxSeats: 0,
                            description: '',
                            createdAt:
                                DateTime.fromMillisecondsSinceEpoch(0),
                            updatedAt:
                                DateTime.fromMillisecondsSinceEpoch(0),
                          ),
                        )
                        .name,
                    statusLabel: _statusLabel(app.status),
                    onStatusChange: (status) async {
                      await context
                          .read<HajjUmrahService>()
                          .updateApplicationStatus(app.id, status);
                      if (!context.mounted) return;
                      context
                          .read<AppState>()
                          .updateBusBookingStatus(app.id, _statusLabel(status));
                      final actor = context.read<AuthService>().username ?? 'غير معروف';
                      await context.read<AuditLogService>().log(
                            actor: actor,
                            action: 'تحديث حالة طلب',
                            targetType: 'hajj_umrah_application',
                            targetId: app.id,
                            details: _statusLabel(status),
                          );
                    },
                    onView: () => _openDetailsDialog(context, app),
                    onManage: () => _openManageDialog(context, app, service),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetailsDialog(BuildContext context, HajjUmrahApplication app) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تفاصيل الطلب'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('رقم التأكيد: ${app.id}'),
              const SizedBox(height: 6),
              Text('الاسم: ${app.userName}'),
              const SizedBox(height: 6),
              Text('العمر: ${app.age}'),
              const SizedBox(height: 6),
              Text('الهاتف: ${app.phone}'),
              const SizedBox(height: 6),
              Text('المرافقون: ${app.companions}'),
              const SizedBox(height: 6),
              Text('نوع التأشيرة: ${app.visaType}'),
              const SizedBox(height: 6),
              Text('حالة التأشيرة: ${_visaLabel(app.visaStatus)}'),
              const SizedBox(height: 6),
              Text('حالة التوثيق: ${_docLabel(app.documentStatus)}'),
              if (app.waitingList) ...[
                const SizedBox(height: 6),
                Text('قائمة الانتظار: ${app.waitlistPosition ?? '-'}'),
              ],
              if (app.supervisorName != null && app.supervisorName!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text('المشرف: ${app.supervisorName}'),
              ],
              if (app.transportPlan != null && app.transportPlan!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text('خطة النقل: ${app.transportPlan}'),
              ],
              if (app.hotelRoomNumber != null && app.hotelRoomNumber!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text('الغرفة: ${app.hotelRoomType ?? ''} ${app.hotelRoomNumber ?? ''}'.trim()),
              ],
              const SizedBox(height: 10),
              if (app.passportImagePath.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(app.passportImagePath),
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _openManageDialog(
    BuildContext context,
    HajjUmrahApplication app,
    HajjUmrahService service,
  ) {
    final visaRefController = TextEditingController(text: app.visaReference ?? '');
    final docNotesController = TextEditingController(text: app.documentNotes ?? '');
    final roomTypeController = TextEditingController(text: app.hotelRoomType ?? '');
    final roomNumberController = TextEditingController(text: app.hotelRoomNumber ?? '');
    final transportController = TextEditingController(text: app.transportPlan ?? '');
    final supervisorController = TextEditingController(text: app.supervisorName ?? '');
    VisaStatus visaStatus = app.visaStatus;
    DocumentStatus docStatus = app.documentStatus;
    HajjUmrahApplicationStatus appStatus = app.status;
    String? groupId = app.groupId;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إدارة الطلب'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<HajjUmrahApplicationStatus>(
                initialValue: appStatus,
                decoration: const InputDecoration(labelText: 'حالة الطلب'),
                items: const [
                  DropdownMenuItem(
                    value: HajjUmrahApplicationStatus.pending,
                    child: Text('قيد المراجعة'),
                  ),
                  DropdownMenuItem(
                    value: HajjUmrahApplicationStatus.approved,
                    child: Text('مقبولة'),
                  ),
                  DropdownMenuItem(
                    value: HajjUmrahApplicationStatus.rejected,
                    child: Text('مرفوضة'),
                  ),
                  DropdownMenuItem(
                    value: HajjUmrahApplicationStatus.completed,
                    child: Text('مكتملة'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) appStatus = value;
                },
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<VisaStatus>(
                initialValue: visaStatus,
                decoration: const InputDecoration(labelText: 'حالة التأشيرة'),
                items: const [
                  DropdownMenuItem(value: VisaStatus.requested, child: Text('طلب جديد')),
                  DropdownMenuItem(value: VisaStatus.submitted, child: Text('تم الإرسال')),
                  DropdownMenuItem(value: VisaStatus.approved, child: Text('تمت الموافقة')),
                  DropdownMenuItem(value: VisaStatus.rejected, child: Text('مرفوضة')),
                  DropdownMenuItem(value: VisaStatus.issued, child: Text('تم الإصدار')),
                ],
                onChanged: (value) {
                  if (value != null) visaStatus = value;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: visaRefController,
                decoration: const InputDecoration(labelText: 'مرجع التأشيرة'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<DocumentStatus>(
                initialValue: docStatus,
                decoration: const InputDecoration(labelText: 'حالة التوثيق'),
                items: const [
                  DropdownMenuItem(value: DocumentStatus.pending, child: Text('قيد المراجعة')),
                  DropdownMenuItem(value: DocumentStatus.verified, child: Text('موثقة')),
                  DropdownMenuItem(value: DocumentStatus.rejected, child: Text('مرفوضة')),
                ],
                onChanged: (value) {
                  if (value != null) docStatus = value;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: docNotesController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'ملاحظات التوثيق'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: groupId,
                decoration: const InputDecoration(labelText: 'المجموعة'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('بدون مجموعة')),
                  ...service.groups
                      .where((g) => g.campaignId == app.campaignId)
                      .map(
                        (g) => DropdownMenuItem(
                          value: g.id,
                          child: Text(g.name),
                        ),
                      ),
                ],
                onChanged: (value) => groupId = value,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: supervisorController,
                decoration: const InputDecoration(labelText: 'المشرف'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: transportController,
                decoration: const InputDecoration(labelText: 'خطة النقل'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: roomTypeController,
                      decoration: const InputDecoration(labelText: 'نوع الغرفة'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: roomNumberController,
                      decoration: const InputDecoration(labelText: 'رقم الغرفة'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final service = context.read<HajjUmrahService>();
              final actor = context.read<AuthService>().username ?? 'غير معروف';
              final audit = context.read<AuditLogService>();
              final updated = app.copyWith(
                status: appStatus,
                visaStatus: visaStatus,
                visaReference: visaRefController.text.trim(),
                documentStatus: docStatus,
                documentNotes: docNotesController.text.trim(),
                groupId: groupId,
                supervisorName: supervisorController.text.trim().isEmpty
                    ? app.supervisorName
                    : supervisorController.text.trim(),
                transportPlan: transportController.text.trim().isEmpty
                    ? app.transportPlan
                    : transportController.text.trim(),
                hotelRoomType: roomTypeController.text.trim().isEmpty
                    ? app.hotelRoomType
                    : roomTypeController.text.trim(),
                hotelRoomNumber: roomNumberController.text.trim().isEmpty
                    ? app.hotelRoomNumber
                    : roomNumberController.text.trim(),
                updatedAt: DateTime.now(),
              );
              await service.updateApplicationDetails(updated);
              if (!context.mounted) return;
              await audit.log(
                    actor: actor,
                    action: 'إدارة طلب',
                    targetType: 'hajj_umrah_application',
                    targetId: app.id,
                    details: 'تحديث التأشيرة والتوثيق والتخصيصات',
                  );
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}

class _FiltersCard extends StatelessWidget {
  final List<HajjUmrahPackage> packages;
  final String? packageFilter;
  final HajjUmrahApplicationStatus? statusFilter;
  final DateTime? fromDate;
  final DateTime? toDate;
  final ValueChanged<String?> onPackageChanged;
  final ValueChanged<HajjUmrahApplicationStatus?> onStatusChanged;
  final VoidCallback onPickFrom;
  final VoidCallback onPickTo;
  final VoidCallback onClear;

  const _FiltersCard({
    required this.packages,
    required this.packageFilter,
    required this.statusFilter,
    required this.fromDate,
    required this.toDate,
    required this.onPackageChanged,
    required this.onStatusChanged,
    required this.onPickFrom,
    required this.onPickTo,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('yyyy/MM/dd');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('الفلاتر',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: packageFilter,
              decoration: const InputDecoration(labelText: 'الباقة'),
              items: [
                const DropdownMenuItem(value: null, child: Text('الكل')),
                ...packages.map(
                  (pkg) => DropdownMenuItem(
                    value: pkg.id,
                    child: Text(pkg.name),
                  ),
                ),
              ],
              onChanged: onPackageChanged,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<HajjUmrahApplicationStatus>(
              initialValue: statusFilter,
              decoration: const InputDecoration(labelText: 'الحالة'),
              items: const [
                DropdownMenuItem(value: null, child: Text('الكل')),
                DropdownMenuItem(
                  value: HajjUmrahApplicationStatus.pending,
                  child: Text('قيد المراجعة'),
                ),
                DropdownMenuItem(
                  value: HajjUmrahApplicationStatus.approved,
                  child: Text('مقبولة'),
                ),
                DropdownMenuItem(
                  value: HajjUmrahApplicationStatus.rejected,
                  child: Text('مرفوضة'),
                ),
                DropdownMenuItem(
                  value: HajjUmrahApplicationStatus.completed,
                  child: Text('مكتملة'),
                ),
              ],
              onChanged: onStatusChanged,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onPickFrom,
                    child: Text(
                      fromDate == null
                          ? 'من'
                          : formatter.format(fromDate!),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onPickTo,
                    child: Text(
                      toDate == null ? 'إلى' : formatter.format(toDate!),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onClear,
                  child: const Text('مسح'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final HajjUmrahApplication application;
  final String packageName;
  final String statusLabel;
  final ValueChanged<HajjUmrahApplicationStatus> onStatusChange;
  final VoidCallback onView;
  final VoidCallback onManage;

  const _ApplicationCard({
    required this.application,
    required this.packageName,
    required this.statusLabel,
    required this.onStatusChange,
    required this.onView,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(packageName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المتقدم: ${application.userName}'),
            if (application.waitingList)
              Text('قائمة الانتظار: ${application.waitlistPosition ?? '-'}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onManage,
              icon: const Icon(Icons.manage_accounts_outlined),
              tooltip: 'إدارة الطلب',
            ),
            PopupMenuButton<HajjUmrahApplicationStatus>(
              onSelected: onStatusChange,
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: HajjUmrahApplicationStatus.pending,
                  child: Text('قيد المراجعة'),
                ),
                PopupMenuItem(
                  value: HajjUmrahApplicationStatus.approved,
                  child: Text('مقبولة'),
                ),
                PopupMenuItem(
                  value: HajjUmrahApplicationStatus.rejected,
                  child: Text('مرفوضة'),
                ),
                PopupMenuItem(
                  value: HajjUmrahApplicationStatus.completed,
                  child: Text('مكتملة'),
                ),
              ],
              child: _StatusChip(label: statusLabel),
            ),
          ],
        ),
        onTap: onView,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;

  const _StatusChip({required this.label});

  Color _color() {
    switch (label) {
      case 'مقبولة':
        return Colors.green;
      case 'مرفوضة':
        return Colors.redAccent;
      case 'مكتملة':
        return Colors.blueAccent;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.assignment_outlined,
                size: 72, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text('لا توجد طلبات حالياً',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text('ستظهر الطلبات هنا بعد التقديم.',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
