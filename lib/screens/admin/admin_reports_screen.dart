import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../../data/models/booking_record.dart';
import '../../logic/app_state.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/responsive_container.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;

  Future<void> _pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _fromDate = picked);
    }
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _toDate = picked);
    }
  }

  List<BookingRecord> _filter(List<BookingRecord> items) {
    return items.where((b) {
      final date = DateTime(b.date.year, b.date.month, b.date.day);
      if (_fromDate != null) {
        final from = DateTime(
          _fromDate!.year,
          _fromDate!.month,
          _fromDate!.day,
        );
        if (date.isBefore(from)) return false;
      }
      if (_toDate != null) {
        final to = DateTime(_toDate!.year, _toDate!.month, _toDate!.day);
        if (date.isAfter(to)) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allBookings = context.watch<AppState>().busBookings;
    final bookings = _filter(allBookings);
    final totalRevenue = bookings.fold<double>(
      0,
      (sum, b) => sum + b.amountSar,
    );
    final totalBookings = bookings.length;
    final avgRevenue = totalBookings == 0 ? 0.0 : totalRevenue / totalBookings;

    final perUser = _groupBy(bookings, (b) => b.userName);
    final perCompany = _groupBy(bookings, (b) => b.company);

    return Scaffold(
      appBar: BrandedAppBar(
        title: 'تقارير الإدارة',
        actions: [
          IconButton(
            onPressed: () =>
                _exportPdf(context, bookings, totalRevenue, totalBookings),
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
              _FiltersRow(
                fromDate: _fromDate,
                toDate: _toDate,
                onPickFrom: _pickFromDate,
                onPickTo: _pickToDate,
                onClear: () => setState(() {
                  _fromDate = null;
                  _toDate = null;
                }),
              ),
              const SizedBox(height: 16),
              _AdminSummaryRow(
                totalBookings: totalBookings,
                totalRevenue: totalRevenue,
                avgRevenue: avgRevenue,
              ),
              const SizedBox(height: 16),
              Text(
                'تقرير حسب المستخدم',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              _GroupList(groups: perUser),
              const SizedBox(height: 16),
              Text(
                'تقرير حسب الشركة',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              _GroupList(groups: perCompany),
              const SizedBox(height: 16),
              Text(
                'سجل الحجوزات',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              if (bookings.isEmpty)
                const _EmptyState()
              else
                ...bookings.map((b) => _BookingRow(record: b)),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, _GroupSummary> _groupBy(
    List<BookingRecord> items,
    String Function(BookingRecord) key,
  ) {
    final map = <String, _GroupSummary>{};
    for (final item in items) {
      final k = key(item);
      final existing = map[k];
      if (existing == null) {
        map[k] = _GroupSummary(count: 1, amountSar: item.amountSar);
      } else {
        map[k] = _GroupSummary(
          count: existing.count + 1,
          amountSar: existing.amountSar + item.amountSar,
        );
      }
    }
    return map;
  }

  Future<void> _exportPdf(
    BuildContext context,
    List<BookingRecord> bookings,
    double totalRevenue,
    int totalBookings,
  ) async {
    final doc = pw.Document();
    final formatter = DateFormat('yyyy/MM/dd');

    doc.addPage(
      pw.MultiPage(
        build: (_) => [
          pw.Text('تقرير الإدارة', style: pw.TextStyle(fontSize: 20)),
          pw.SizedBox(height: 12),
          pw.Text('إجمالي الحجوزات: $totalBookings'),
          pw.Text('إجمالي الإيرادات: ${totalRevenue.toStringAsFixed(0)} ر.س'),
          pw.SizedBox(height: 16),
          pw.Text('سجل الحجوزات', style: pw.TextStyle(fontSize: 16)),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: ['المستخدم', 'الشركة', 'التاريخ', 'الحالة', 'المبلغ'],
            data: bookings
                .map(
                  (b) => [
                    b.userName,
                    b.company,
                    formatter.format(b.date),
                    b.status,
                    '${b.amountSar.toStringAsFixed(0)} ر.س',
                  ],
                )
                .toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (_) => doc.save());
  }
}

class _FiltersRow extends StatelessWidget {
  final DateTime? fromDate;
  final DateTime? toDate;
  final VoidCallback onPickFrom;
  final VoidCallback onPickTo;
  final VoidCallback onClear;

  const _FiltersRow({
    required this.fromDate,
    required this.toDate,
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
            Text(
              'تصفية بالتاريخ',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onPickFrom,
                    child: Text(
                      fromDate == null ? 'من' : formatter.format(fromDate!),
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
                TextButton(onPressed: onClear, child: const Text('مسح')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminSummaryRow extends StatelessWidget {
  final int totalBookings;
  final double totalRevenue;
  final double avgRevenue;

  const _AdminSummaryRow({
    required this.totalBookings,
    required this.totalRevenue,
    required this.avgRevenue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'إجمالي الحجوزات',
            value: totalBookings.toString(),
            icon: Icons.confirmation_number_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'الإيرادات',
            value: '${totalRevenue.toStringAsFixed(0)} ر.س',
            icon: Icons.payments_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'متوسط الحجز',
            value: '${avgRevenue.toStringAsFixed(0)} ر.س',
            icon: Icons.bar_chart_outlined,
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

class _GroupList extends StatelessWidget {
  final Map<String, _GroupSummary> groups;

  const _GroupList({required this.groups});

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) return const _EmptyState();

    return Column(
      children: groups.entries.map((entry) {
        final summary = entry.value;
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            title: Text(entry.key),
            subtitle: Text('عدد الحجوزات: ${summary.count}'),
            trailing: Text('${summary.amountSar.toStringAsFixed(0)} ر.س'),
          ),
        );
      }).toList(),
    );
  }
}

class _BookingRow extends StatelessWidget {
  final BookingRecord record;

  const _BookingRow({required this.record});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.event_available_outlined),
        title: Text('${record.userName} • ${record.company}'),
        subtitle: Text(DateFormat('yyyy/MM/dd').format(record.date)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${record.amountSar.toStringAsFixed(0)} ر.س'),
            const SizedBox(height: 4),
            Text(record.status, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _GroupSummary {
  final int count;
  final double amountSar;

  const _GroupSummary({required this.count, required this.amountSar});
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.insert_chart_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'لا توجد بيانات بعد',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'ستظهر التقارير بعد تسجيل حجوزات.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
