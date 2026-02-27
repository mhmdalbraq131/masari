import 'package:flutter/material.dart';
import '../../data/models/hajj_umrah_models.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/responsive_container.dart';

class HajjUmrahConfirmationScreen extends StatelessWidget {
  final HajjUmrahPackage package;
  final HajjUmrahApplication application;
  final double totalPrice;

  const HajjUmrahConfirmationScreen({
    super.key,
    required this.package,
    required this.application,
    required this.totalPrice,
  });

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandedAppBar(title: 'تأكيد الطلب'),
      body: SafeArea(
        child: ResponsiveContainer(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle,
                            size: 64, color: Colors.green),
                        const SizedBox(height: 12),
                        Text('تم إرسال الطلب بنجاح',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text('رقم التأكيد: ${application.id}'),
                        const SizedBox(height: 6),
                        Text('الحالة: ${_statusLabel(application.status)}'),
                        if (application.waitingList) ...[
                          const SizedBox(height: 6),
                          Text(
                            'قائمة الانتظار: ${application.waitlistPosition ?? '-'}',
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('تفاصيل الباقة',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        _row('الباقة', package.name),
                        const SizedBox(height: 8),
                        _row('المدة', '${package.durationDays} أيام'),
                        const SizedBox(height: 8),
                        _row('الفندق', package.hotelName),
                        const SizedBox(height: 8),
                        _row('المبلغ', '${totalPrice.toStringAsFixed(0)} ر.س'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('بيانات المتقدم',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        _row('الاسم', application.userName),
                        const SizedBox(height: 8),
                        _row('العمر', application.age.toString()),
                        const SizedBox(height: 8),
                        _row('الهاتف', application.phone),
                        const SizedBox(height: 8),
                        _row('المرافقون', application.companions.toString()),
                        const SizedBox(height: 8),
                        _row('نوع التأشيرة', application.visaType),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
