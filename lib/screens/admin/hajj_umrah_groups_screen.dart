import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_service.dart';
import '../../data/models/hajj_umrah_models.dart';
import '../../logic/hajj_umrah_service.dart';
import '../../services/audit_log_service.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/responsive_container.dart';

class HajjUmrahGroupsScreen extends StatelessWidget {
  const HajjUmrahGroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<HajjUmrahService>();
    final items = service.groups;

    return Scaffold(
      appBar: const BrandedAppBar(title: 'إدارة المجموعات'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openDialog(context),
        icon: const Icon(Icons.group_add_outlined),
        label: const Text('إضافة مجموعة'),
      ),
      body: ResponsiveContainer(
        child: items.isEmpty
            ? const _EmptyState()
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final group = items[index];
                  final campaign = service.campaigns.firstWhere(
                    (c) => c.id == group.campaignId,
                    orElse: () => HajjUmrahCampaign(
                      id: '_missing',
                      name: 'غير معروف',
                      type: HajjUmrahType.hajj,
                      seasonStart: DateTime.fromMillisecondsSinceEpoch(0),
                      seasonEnd: DateTime.fromMillisecondsSinceEpoch(0),
                      capacity: 0,
                      active: false,
                      notes: '',
                      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
                      updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
                    ),
                  );
                  return Card(
                    child: ListTile(
                      title: Text(group.name),
                      subtitle: Text(
                        '${campaign.name} • المشرف: ${group.supervisorName}',
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _openDialog(context, existing: group);
                          } else if (value == 'delete') {
                            _confirmDelete(context, group);
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

  void _confirmDelete(BuildContext context, HajjUmrahGroup group) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف المجموعة'),
        content: const Text('هل أنت متأكد من حذف المجموعة؟'),
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
              await service.deleteGroup(group.id);
              await audit.log(
                    actor: actor,
                    action: 'حذف مجموعة',
                    targetType: 'hajj_umrah_group',
                    targetId: group.id,
                    details: group.name,
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
    HajjUmrahGroup? existing,
  }) {
    final service = context.read<HajjUmrahService>();
    final campaigns = service.campaigns;
    final nameController = TextEditingController(text: existing?.name ?? '');
    final supervisorController =
        TextEditingController(text: existing?.supervisorName ?? '');
    final transportController =
        TextEditingController(text: existing?.transportPlan ?? '');
    final capacityController = TextEditingController(
      text: existing?.capacity.toString() ?? '',
    );
    String? campaignId = existing?.campaignId ?? (campaigns.isNotEmpty ? campaigns.first.id : null);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing == null ? 'إضافة مجموعة' : 'تعديل مجموعة'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                  initialValue: campaignId,
                items: campaigns
                    .map(
                      (c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => campaignId = value,
                decoration: const InputDecoration(labelText: 'الحملة'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'اسم المجموعة'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: supervisorController,
                decoration: const InputDecoration(labelText: 'المشرف'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: transportController,
                decoration: const InputDecoration(labelText: 'خطة النقل'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'السعة'),
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
              final auth = context.read<AuthService>();
              final audit = context.read<AuditLogService>();
              final actor = auth.username ?? 'غير معروف';
              final name = nameController.text.trim();
              final supervisor = supervisorController.text.trim();
              final transport = transportController.text.trim();
              final capacity = int.tryParse(capacityController.text.trim()) ?? 0;
              if (campaignId == null || name.isEmpty || supervisor.isEmpty || capacity <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('يرجى إدخال البيانات المطلوبة')),
                );
                return;
              }
              final now = DateTime.now();
              final group = HajjUmrahGroup(
                id: existing?.id ?? now.microsecondsSinceEpoch.toString(),
                campaignId: campaignId!,
                name: name,
                supervisorName: supervisor,
                transportPlan: transport,
                capacity: capacity,
                createdAt: existing?.createdAt ?? now,
                updatedAt: now,
              );
              await service.upsertGroup(group);
              if (!context.mounted) return;
              await audit.log(
                    actor: actor,
                    action: existing == null ? 'إضافة مجموعة' : 'تعديل مجموعة',
                    targetType: 'hajj_umrah_group',
                    targetId: group.id,
                    details: group.name,
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
            Icon(Icons.group_outlined,
                size: 72, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text('لا توجد مجموعات بعد',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text('أضف مجموعات لتوزيع الحجاج.',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
