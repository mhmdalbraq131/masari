import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_service.dart';
import '../../data/models/location_model.dart';
import '../../logic/location_service.dart';
import '../../services/audit_log_service.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/responsive_container.dart';

class AdminLocationsScreen extends StatelessWidget {
  const AdminLocationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<LocationService>();
    final items = service.locations;

    return Scaffold(
      appBar: const BrandedAppBar(title: 'إدارة المواقع'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openDialog(context),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('إضافة موقع'),
      ),
      body: ResponsiveContainer(
        child: items.isEmpty
            ? const _EmptyState()
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.location_on_outlined),
                      title: Text(item.name),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _openDialog(context, existing: item);
                          } else if (value == 'delete') {
                            _confirmDelete(context, item);
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

  void _confirmDelete(BuildContext context, LocationEntry entry) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف الموقع'),
        content: const Text('هل أنت متأكد من حذف الموقع؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final locationService = context.read<LocationService>();
              final auth = context.read<AuthService>();
              final audit = context.read<AuditLogService>();
              final actor = auth.username ?? 'غير معروف';
              await locationService.delete(entry.id);
              await audit.log(
                    actor: actor,
                    action: 'حذف موقع',
                    targetType: 'location',
                    targetId: entry.id,
                    details: entry.name,
                  );
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _openDialog(BuildContext context, {LocationEntry? existing}) {
    final controller = TextEditingController(text: existing?.name ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing == null ? 'إضافة موقع' : 'تعديل موقع'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'اسم الموقع'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final locationService = context.read<LocationService>();
              final auth = context.read<AuthService>();
              final audit = context.read<AuditLogService>();
              final actor = auth.username ?? 'غير معروف';
              final name = controller.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('يرجى إدخال اسم الموقع')),
                );
                return;
              }
              final entry = LocationEntry(
                id: existing?.id ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                name: name,
              );
              await locationService.upsert(entry);
              await audit.log(
                    actor: actor,
                    action: existing == null ? 'إضافة موقع' : 'تعديل موقع',
                    targetType: 'location',
                    targetId: entry.id,
                    details: entry.name,
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
            Icon(Icons.location_on_outlined,
                size: 72, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text('لا توجد مواقع بعد',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text('أضف مواقع جديدة لتظهر في البحث.',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
