import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../../data/models/booked_trip_model.dart';
import '../../logic/mytrips_service.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/responsive_container.dart';

class UserReportsScreen extends StatelessWidget {
  const UserReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trips = context.watch<MyTripsService>().items;
    final totalTrips = trips.length;
    final totalPaid = trips.fold<double>(
      0,
      (sum, trip) => sum + _parsePrice(trip.priceLabel),
    );

    return Scaffold(
      appBar: BrandedAppBar(
        title: 'تقارير المستخدم',
        actions: [
          IconButton(
            onPressed: () => _exportPdf(context, trips, totalTrips, totalPaid),
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'تصدير PDF',
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveContainer(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SummaryRow(totalTrips: totalTrips, totalPaid: totalPaid),
              const SizedBox(height: 16),
              Text(
                'قائمة الحجوزات',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              if (trips.isEmpty)
                const _EmptyState()
              else
                ...trips.map((trip) => _BookingCard(trip: trip)),
            ],
          ),
        ),
      ),
    );
  }

  static double _parsePrice(String label) {
    final match = RegExp(r'\d+(\.\d+)?').firstMatch(label);
    if (match == null) return 0;
    return double.tryParse(match.group(0) ?? '') ?? 0;
  }

  Future<void> _exportPdf(
    BuildContext context,
    List<BookedTrip> trips,
    int totalTrips,
    double totalPaid,
  ) async {
    final doc = pw.Document();
    final formatter = DateFormat('yyyy/MM/dd');

    doc.addPage(
      pw.MultiPage(
        build: (_) => [
          pw.Text('تقرير المستخدم', style: pw.TextStyle(fontSize: 20)),
          pw.SizedBox(height: 12),
          pw.Text('إجمالي الرحلات: $totalTrips'),
          pw.Text('إجمالي المدفوعات: ${totalPaid.toStringAsFixed(0)} ر.س'),
          pw.SizedBox(height: 16),
          pw.Text('قائمة الحجوزات', style: pw.TextStyle(fontSize: 16)),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: ['الرحلة', 'التاريخ', 'الحالة', 'السعر'],
            data: trips
                .map(
                  (trip) => [
                    trip.title,
                    formatter.format(trip.bookedAt),
                    _statusLabel(trip.status),
                    trip.priceLabel,
                  ],
                )
                .toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (_) => doc.save());
  }

  static String _statusLabel(dynamic status) {
    switch (status.toString()) {
      case 'BookedTripStatus.completed':
        return 'مكتملة';
      case 'BookedTripStatus.cancelled':
        return 'ملغاة';
      default:
        return 'قادمة';
    }
  }
}

class _SummaryRow extends StatelessWidget {
  final int totalTrips;
  final double totalPaid;

  const _SummaryRow({required this.totalTrips, required this.totalPaid});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'إجمالي الرحلات',
            value: totalTrips.toString(),
            icon: Icons.confirmation_number_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'إجمالي المدفوعات',
            value: '${totalPaid.toStringAsFixed(0)} ر.س',
            icon: Icons.payments_outlined,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookedTrip trip;

  const _BookingCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.flight_takeoff),
        title: Text(trip.title),
        subtitle: Text(DateFormat('yyyy/MM/dd').format(trip.bookedAt)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(trip.priceLabel),
            const SizedBox(height: 4),
            Text(
              UserReportsScreen._statusLabel(trip.status),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
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
            Icon(
              Icons.assignment_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'لا توجد حجوزات بعد',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'ستظهر تقاريرك هنا بعد إجراء الحجوزات.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
