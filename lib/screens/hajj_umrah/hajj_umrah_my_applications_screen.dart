import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_service.dart';
import '../../data/models/hajj_umrah_models.dart';
import '../../logic/hajj_umrah_service.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/responsive_container.dart';

class HajjUmrahMyApplicationsScreen extends StatelessWidget {
  const HajjUmrahMyApplicationsScreen({super.key});

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

  Color _statusColor(HajjUmrahApplicationStatus status) {
    switch (status) {
      case HajjUmrahApplicationStatus.approved:
        return Colors.green;
      case HajjUmrahApplicationStatus.rejected:
        return Colors.redAccent;
      case HajjUmrahApplicationStatus.completed:
        return Colors.blueAccent;
      case HajjUmrahApplicationStatus.pending:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final service = context.watch<HajjUmrahService>();
    final userName = auth.username;

    final applications = userName == null
        ? <HajjUmrahApplication>[]
        : service.applications
            .where((app) => app.userName == userName)
            .toList();

    return Scaffold(
      appBar: const BrandedAppBar(title: 'طلباتي للحج والعمرة'),
      body: SafeArea(
        child: ResponsiveContainer(
          child: applications.isEmpty
              ? const _EmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: applications.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final app = applications[index];
                    final pkg = service.packages
                        .where((p) => p.id == app.packageId)
                        .cast<HajjUmrahPackage?>()
                        .firstWhere((p) => p != null, orElse: () => null);
                    return Card(
                      child: ListTile(
                        title: Text(pkg?.name ?? 'باقة غير معروفة'),
                        subtitle: Text(
                            'تاريخ الطلب: ${app.createdAt.toString().split(' ').first}'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor(app.status)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _statusLabel(app.status),
                            style: TextStyle(
                              color: _statusColor(app.status),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        onTap: () => showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('تفاصيل الطلب'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('رقم التأكيد: ${app.id}'),
                                const SizedBox(height: 6),
                                Text('الاسم: ${app.userName}'),
                                const SizedBox(height: 6),
                                Text('الهاتف: ${app.phone}'),
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
                                const SizedBox(height: 10),
                                if (app.passportImagePath.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(app.passportImagePath),
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('إغلاق'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
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
            Icon(Icons.mosque_outlined,
                size: 72, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text('لا توجد طلبات حالياً',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text('سجل طلبات الحج والعمرة سيظهر هنا.',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
