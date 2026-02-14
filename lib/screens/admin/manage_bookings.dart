import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/app_state.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/responsive_container.dart';

class ManageBookingsScreen extends StatefulWidget {
  const ManageBookingsScreen({super.key});

  @override
  State<ManageBookingsScreen> createState() => _ManageBookingsScreenState();
}

class _ManageBookingsScreenState extends State<ManageBookingsScreen> {
  void _changeStatus(int index, String status) {
    final record = context.read<AppState>().busBookings[index];
    context.read<AppState>().updateBusBookingStatus(record.ticketId, status);
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تصدير البيانات')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BrandedAppBar(
        title: 'إدارة الحجوزات',
        actions: [
          IconButton(
            onPressed: _exportData,
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'تصدير',
          ),
        ],
      ),
      body: ResponsiveContainer(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: context.watch<AppState>().busBookings.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final booking = context.watch<AppState>().busBookings[index];
            return Card(
              child: ListTile(
                title: Text('رقم الحجز: ${booking.ticketId}'),
                subtitle: Text('الشركة: ${booking.company}'),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) => _changeStatus(index, value),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'مؤكدة', child: Text('اعتماد')),
                    PopupMenuItem(value: 'مرفوضة', child: Text('رفض')),
                    PopupMenuItem(value: 'قيد المراجعة', child: Text('قيد المراجعة')),
                  ],
                  child: _StatusChip(status: booking.status),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  Color _color() {
    switch (status) {
      case 'مؤكدة':
        return Colors.green;
      case 'مرفوضة':
        return Colors.redAccent;
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
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

