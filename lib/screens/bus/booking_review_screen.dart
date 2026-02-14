import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../logic/bus_booking_controller.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/responsive_container.dart';

class BookingReviewScreen extends StatelessWidget {
  final String? passengerName;
  final String? passengerPhone;
  final String? travelReason;

  const BookingReviewScreen({
    super.key,
    this.passengerName,
    this.passengerPhone,
    this.travelReason,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BusBookingController>();
    final trip = controller.selectedTrip;

    return Scaffold(
      appBar: const BrandedAppBar(title: 'مراجعة الحجز'),
      body: ResponsiveContainer(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('تفاصيل الرحلة', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    _ReviewRow(label: 'الشركة', value: trip?.company ?? 'غير محدد'),
                    _ReviewRow(
                      label: 'المسار',
                      value: trip == null ? 'غير محدد' : '${trip.fromCity} → ${trip.toCity}',
                    ),
                    _ReviewRow(
                      label: 'التاريخ',
                      value: trip == null
                          ? 'غير محدد'
                          : '${trip.date.year}/${trip.date.month.toString().padLeft(2, '0')}/${trip.date.day.toString().padLeft(2, '0')}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('بيانات الراكب', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    _ReviewRow(label: 'الاسم', value: passengerName ?? 'غير محدد'),
                    _ReviewRow(label: 'الهاتف', value: passengerPhone ?? 'غير محدد'),
                    _ReviewRow(label: 'سبب السفر', value: travelReason ?? 'غير محدد'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الأسعار', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    _ReviewRow(
                      label: 'السعر (YER)',
                      value: trip == null ? 'غير محدد' : trip.priceYER.toStringAsFixed(0),
                    ),
                    _ReviewRow(
                      label: 'السعر (SAR)',
                      value: trip == null ? 'غير محدد' : trip.priceSAR.toStringAsFixed(0),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('تعديل'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final bookingId = DateTime.now().millisecondsSinceEpoch.toString();
                      context.push('/bus-confirmation', extra: bookingId);
                    },
                    child: const Text('تأكيد الحجز'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}
