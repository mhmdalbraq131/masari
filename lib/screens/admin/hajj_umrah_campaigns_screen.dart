import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_service.dart';
import '../../data/models/hajj_umrah_models.dart';
import '../../logic/hajj_umrah_service.dart';
import '../../services/audit_log_service.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/responsive_container.dart';

class HajjUmrahCampaignsScreen extends StatelessWidget {
  const HajjUmrahCampaignsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<HajjUmrahService>();
    final items = service.campaigns;

    return Scaffold(
      appBar: const BrandedAppBar(title: 'إدارة الحملات'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('إضافة حملة'),
      ),
      body: ResponsiveContainer(
        child: items.isEmpty
            ? const _EmptyState()
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final campaign = items[index];
                  return Card(
                    child: ListTile(
                      title: Text(campaign.name),
                      subtitle: Text(
                        '${_typeLabel(campaign.type)} • السعة: ${campaign.capacity}',
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _openDialog(context, existing: campaign);
                          } else if (value == 'delete') {
                            _confirmDelete(context, campaign);
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

  void _confirmDelete(BuildContext context, HajjUmrahCampaign campaign) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف الحملة'),
        content: const Text('هل أنت متأكد من حذف الحملة؟'),
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
              await service.deleteCampaign(campaign.id);
              await audit.log(
                    actor: actor,
                    action: 'حذف حملة',
                    targetType: 'hajj_umrah_campaign',
                    targetId: campaign.id,
                    details: campaign.name,
                  );
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _openDialog(
    BuildContext context, {
    HajjUmrahCampaign? existing,
  }) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final capacityController = TextEditingController(
      text: existing?.capacity.toString() ?? '',
    );
    final notesController = TextEditingController(text: existing?.notes ?? '');
    HajjUmrahType type = existing?.type ?? HajjUmrahType.hajj;
    DateTime start = existing?.seasonStart ?? DateTime.now();
    DateTime end = existing?.seasonEnd ?? DateTime.now().add(const Duration(days: 120));
    bool active = existing?.active ?? true;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing == null ? 'إضافة حملة' : 'تعديل حملة'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'اسم الحملة'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<HajjUmrahType>(
                  initialValue: type,
                items: const [
                  DropdownMenuItem(value: HajjUmrahType.hajj, child: Text('الحج')),
                  DropdownMenuItem(value: HajjUmrahType.umrah, child: Text('العمرة')),
                ],
                onChanged: (value) => type = value ?? type,
                decoration: const InputDecoration(labelText: 'النوع'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'السعة'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: notesController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'ملاحظات'),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('نشطة'),
                value: active,
                onChanged: (value) => active = value,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: start,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null) start = picked;
                      },
                      child: Text('بداية الموسم: ${start.toString().split(' ').first}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: end,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );
                        if (picked != null) end = picked;
                      },
                      child: Text('نهاية الموسم: ${end.toString().split(' ').first}'),
                    ),
                  ),
                ],
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
              final capacity = int.tryParse(capacityController.text.trim()) ?? 0;
              if (name.isEmpty || capacity <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('يرجى إدخال البيانات المطلوبة')),
                );
                return;
              }
              final now = DateTime.now();
              final campaign = HajjUmrahCampaign(
                id: existing?.id ?? now.microsecondsSinceEpoch.toString(),
                name: name,
                type: type,
                seasonStart: start,
                seasonEnd: end,
                capacity: capacity,
                active: active,
                notes: notesController.text.trim(),
                createdAt: existing?.createdAt ?? now,
                updatedAt: now,
              );
              await service.upsertCampaign(campaign);
              if (!context.mounted) return;
              await audit.log(
                    actor: actor,
                    action: existing == null ? 'إضافة حملة' : 'تعديل حملة',
                    targetType: 'hajj_umrah_campaign',
                    targetId: campaign.id,
                    details: campaign.name,
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
            Icon(Icons.flag_outlined,
                size: 72, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text('لا توجد حملات بعد',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text('قم بإضافة حملة لتنظيم الموسم.',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
