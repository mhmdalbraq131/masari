import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_service.dart';
import '../../data/models/hajj_umrah_models.dart';
import '../../logic/hajj_umrah_service.dart';
import '../../services/audit_log_service.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/responsive_container.dart';

class HajjUmrahAdminPackagesScreen extends StatelessWidget {
  const HajjUmrahAdminPackagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<HajjUmrahService>();
    final packages = service.packages;

    return Scaffold(
      appBar: const BrandedAppBar(title: 'إدارة باقات الحج والعمرة'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openPackageDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('إضافة باقة'),
      ),
      body: ResponsiveContainer(
        child: packages.isEmpty
            ? const _EmptyState()
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: packages.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final pkg = packages[index];
                  return Card(
                    child: ListTile(
                      title: Text(pkg.name),
                      subtitle: Text(
                        '${_typeLabel(pkg.type)} • ${pkg.durationDays} أيام • ${pkg.priceSar.toStringAsFixed(0)} ر.س',
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _openPackageDialog(context, existing: pkg);
                          } else if (value == 'delete') {
                            _confirmDelete(context, pkg);
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('تعديل')),
                          PopupMenuItem(value: 'delete', child: Text('حذف')),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  static String _typeLabel(HajjUmrahType type) {
    return type == HajjUmrahType.hajj ? 'الحج' : 'العمرة';
  }

  void _confirmDelete(BuildContext context, HajjUmrahPackage pkg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف الباقة'),
        content: const Text('هل أنت متأكد من حذف الباقة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final service = context.read<HajjUmrahService>();
              final auth = context.read<AuthService>();
              final audit = context.read<AuditLogService>();
              final actor = auth.username ?? 'غير معروف';
              await service.deletePackage(pkg.id);
              await audit.log(
                    actor: actor,
                    action: 'حذف باقة',
                    targetType: 'hajj_umrah_package',
                    targetId: pkg.id,
                    details: pkg.name,
                  );
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _openPackageDialog(
    BuildContext context, {
    HajjUmrahPackage? existing,
  }) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final priceController = TextEditingController(
        text: existing?.priceSar.toStringAsFixed(0) ?? '');
    final durationController = TextEditingController(
        text: existing?.durationDays.toString() ?? '');
    final hotelController = TextEditingController(text: existing?.hotelName ?? '');
    final latController = TextEditingController(
        text: existing?.hotelLat.toString() ?? '');
    final lngController = TextEditingController(
        text: existing?.hotelLng.toString() ?? '');
    final transportController =
        TextEditingController(text: existing?.transportType ?? '');
    final seatsController = TextEditingController(
        text: existing?.maxSeats.toString() ?? '');
    final descController =
        TextEditingController(text: existing?.description ?? '');
    HajjUmrahType type = existing?.type ?? HajjUmrahType.hajj;
    String? campaignId = existing?.campaignId;
    final campaigns = context.read<HajjUmrahService>().campaigns;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing == null ? 'إضافة باقة' : 'تعديل باقة'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'اسم الباقة'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<HajjUmrahType>(
                initialValue: type,
                items: const [
                  DropdownMenuItem(
                    value: HajjUmrahType.hajj,
                    child: Text('الحج'),
                  ),
                  DropdownMenuItem(
                    value: HajjUmrahType.umrah,
                    child: Text('العمرة'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) type = value;
                },
                decoration: const InputDecoration(labelText: 'النوع'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: campaignId,
                items: [
                  const DropdownMenuItem(value: null, child: Text('بدون حملة')),
                  ...campaigns
                      .map(
                        (c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name),
                        ),
                      ),
                ],
                onChanged: (value) => campaignId = value,
                decoration: const InputDecoration(labelText: 'الحملة'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'السعر (ر.س)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'المدة (أيام)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: hotelController,
                decoration: const InputDecoration(labelText: 'اسم الفندق'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: latController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'خط العرض'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: lngController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'خط الطول'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: transportController,
                decoration: const InputDecoration(labelText: 'نوع النقل'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: seatsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'عدد المقاعد'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'الوصف (يجب ذكر الفيزا ضمن الباقة)',
                ),
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
              final auth = context.read<AuthService>();
              final audit = context.read<AuditLogService>();
              final actor = auth.username ?? 'غير معروف';
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text.trim()) ?? 0;
              final duration = int.tryParse(durationController.text.trim()) ?? 0;
              final hotel = hotelController.text.trim();
              final lat = double.tryParse(latController.text.trim()) ?? 0;
              final lng = double.tryParse(lngController.text.trim()) ?? 0;
              final transport = transportController.text.trim();
              final seats = int.tryParse(seatsController.text.trim()) ?? 0;
              final desc = descController.text.trim();
              final descOk =
                  desc.contains('الفيزا') || desc.toLowerCase().contains('visa');

              if (name.isEmpty ||
                  hotel.isEmpty ||
                  transport.isEmpty ||
                  desc.isEmpty ||
                  price <= 0 ||
                  duration <= 0 ||
                  seats <= 0 ||
                  lat == 0 ||
                  lng == 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('يرجى تعبئة جميع الحقول')),
                );
                return;
              }
              if (!descOk) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('يجب ذكر أن الفيزا ضمن الباقة'),
                  ),
                );
                return;
              }

              final now = DateTime.now();
              final pkg = HajjUmrahPackage(
                id: existing?.id ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                name: name,
                type: type,
                priceSar: price,
                durationDays: duration,
                hotelName: hotel,
                hotelLat: lat,
                hotelLng: lng,
                transportType: transport,
                maxSeats: seats,
                campaignId: campaignId,
                description: desc,
                createdAt: existing?.createdAt ?? now,
                updatedAt: now,
              );

              await service.upsertPackage(pkg);
              if (!context.mounted) return;
              await audit.log(
                    actor: actor,
                    action: existing == null ? 'إضافة باقة' : 'تعديل باقة',
                    targetType: 'hajj_umrah_package',
                    targetId: pkg.id,
                    details: pkg.name,
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
            Text('لا توجد باقات بعد',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text('أضف أول باقة من زر الإضافة.',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
