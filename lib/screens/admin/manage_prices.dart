import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/admin_price.dart';
import '../../logic/admin_data_state.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/responsive_container.dart';

class ManagePricesScreen extends StatefulWidget {
  const ManagePricesScreen({super.key});

  @override
  State<ManagePricesScreen> createState() => _ManagePricesScreenState();
}

class _ManagePricesScreenState extends State<ManagePricesScreen> {
  void _addPrice() => _openDialog();

  void _editPrice(AdminPrice price) => _openDialog(existing: price);

  void _toggle(AdminPrice price, bool value) {
    context.read<AdminDataState>().updatePrice(price.id, price.copyWith(enabled: value));
  }

  Future<void> _openDialog({AdminPrice? existing}) async {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final valueController = TextEditingController(text: existing?.valueSar.toString() ?? '');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing == null ? 'إضافة سعر' : 'تعديل سعر'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'العنوان'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: valueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'السعر (ر.س)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final value = double.tryParse(valueController.text.trim()) ?? 0;
              if (title.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('يرجى إدخال العنوان')),
                );
                return;
              }
              if (existing == null) {
                context.read<AdminDataState>().addPrice(
                      AdminPrice(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: title,
                        valueSar: value,
                        enabled: true,
                      ),
                    );
              } else {
                context.read<AdminDataState>().updatePrice(
                      existing.id,
                      existing.copyWith(title: title, valueSar: value),
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
    final prices = context.watch<AdminDataState>().prices;
    return Scaffold(
      appBar: const BrandedAppBar(title: 'إدارة الأسعار'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPrice,
        icon: const Icon(Icons.add),
        label: const Text('إضافة سعر'),
      ),
      body: ResponsiveContainer(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: prices.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final price = prices[index];
            return Card(
              child: ListTile(
                title: Text(price.title),
                subtitle: Text('${price.valueSar.toStringAsFixed(0)} ر.س'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(value: price.enabled, onChanged: (v) => _toggle(price, v)),
                    IconButton(
                      onPressed: () => _editPrice(price),
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
