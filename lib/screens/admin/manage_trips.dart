import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/admin_trip.dart';
import '../../logic/admin_data_state.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/responsive_container.dart';

class ManageTripsScreen extends StatefulWidget {
  const ManageTripsScreen({super.key});

  @override
  State<ManageTripsScreen> createState() => _ManageTripsScreenState();
}

class _ManageTripsScreenState extends State<ManageTripsScreen> {
  final List<String> _regions = const [
    'الرياض',
    'جدة',
    'الدمام',
    'المدينة',
    'مكة',
    'أبها',
  ];

  void _addTrip() {
    _openTripDialog();
  }

  void _editTrip(int index) {
    _openTripDialog(existing: context.read<AdminDataState>().trips[index], index: index);
  }

  void _toggleTrip(int index, bool value) {
    final trip = context.read<AdminDataState>().trips[index];
    context.read<AdminDataState>().toggleTrip(trip.id, value);
  }

  Future<void> _openTripDialog({AdminTrip? existing, int? index}) async {
    String? fromRegion = existing?.fromRegion;
    String? toRegion = existing?.toRegion;
    final timeController = TextEditingController(text: existing?.time ?? '');
    final priceController = TextEditingController(text: existing?.priceSar.toString() ?? '');
    final seatsController = TextEditingController(text: existing?.seats.toString() ?? '');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing == null ? 'إضافة رحلة' : 'تعديل رحلة'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: fromRegion,
                decoration: const InputDecoration(labelText: 'من'),
                items: _regions.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (value) => fromRegion = value,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: toRegion,
                decoration: const InputDecoration(labelText: 'إلى'),
                items: _regions.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (value) => toRegion = value,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: 'الوقت'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'السعر (ر.س)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: seatsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'المقاعد المتاحة'),
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
            onPressed: () {
              final from = fromRegion ?? '';
              final to = toRegion ?? '';
              final time = timeController.text.trim();
              final price = double.tryParse(priceController.text.trim()) ?? 0;
              final seats = int.tryParse(seatsController.text.trim()) ?? 0;
              if (from.isEmpty || to.isEmpty || time.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('يرجى تعبئة البيانات المطلوبة')),
                );
                return;
              }
              if (index == null) {
                context.read<AdminDataState>().addTrip(
                      AdminTrip(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        fromRegion: from,
                        toRegion: to,
                        time: time,
                        priceSar: price,
                        seats: seats,
                        enabled: true,
                      ),
                    );
              } else {
                context.read<AdminDataState>().updateTrip(
                      existing!.id,
                      existing.copyWith(
                        fromRegion: from,
                        toRegion: to,
                        time: time,
                        priceSar: price,
                        seats: seats,
                      ),
                    );
              }
              Navigator.of(context).pop();
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandedAppBar(title: 'إدارة الرحلات'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTrip,
        icon: const Icon(Icons.add),
        label: const Text('إضافة رحلة'),
      ),
      body: ResponsiveContainer(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: context.watch<AdminDataState>().trips.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final trip = context.watch<AdminDataState>().trips[index];
            return Card(
              child: ListTile(
                leading: Icon(
                  trip.enabled ? Icons.check_circle_outline : Icons.pause_circle_outline,
                  color: trip.enabled ? Colors.green : Colors.orange,
                ),
                title: Text(trip.route),
                subtitle: Text('الوقت: ${trip.time} • السعر: ${trip.priceSar.toStringAsFixed(0)} ر.س • المقاعد: ${trip.seats}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: trip.enabled,
                      onChanged: (value) => _toggleTrip(index, value),
                    ),
                    IconButton(
                      onPressed: () => _editTrip(index),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
