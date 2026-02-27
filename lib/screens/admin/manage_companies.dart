import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_service.dart';
import '../../data/models/admin_company.dart';
import '../../logic/admin_data_state.dart';
import '../../services/audit_log_service.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/responsive_container.dart';

class ManageCompaniesScreen extends StatefulWidget {
  const ManageCompaniesScreen({super.key});

  @override
  State<ManageCompaniesScreen> createState() => _ManageCompaniesScreenState();
}

class _ManageCompaniesScreenState extends State<ManageCompaniesScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  Future<File?> _pickLogo() async {
    final file = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return null;
    return File(file.path);
  }

  void _addCompany() {
    _openCompanyDialog();
  }

  void _editCompany(int index) {
    _openCompanyDialog(
      existing: context.read<AdminDataState>().companies[index],
      index: index,
    );
  }

  void _deleteCompany(int index) {
    final id = context.read<AdminDataState>().companies[index].id;
    context.read<AdminDataState>().deleteCompany(id);
    final actor = context.read<AuthService>().username ?? 'غير معروف';
    context.read<AuditLogService>().log(
          actor: actor,
          action: 'حذف شركة',
          targetType: 'company',
          targetId: id,
          details: 'تم حذف الشركة',
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حذف الشركة')),
    );
  }

  Future<void> _openCompanyDialog({AdminCompany? existing, int? index}) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final descController = TextEditingController(text: existing?.description ?? '');
    File? logo = existing?.logoPath == null ? null : File(existing!.logoPath!);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing == null ? 'إضافة شركة' : 'تعديل شركة'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'اسم الشركة'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'وصف مختصر'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await _pickLogo();
                        if (picked == null) return;
                        setState(() => logo = picked);
                      },
                      icon: const Icon(Icons.upload_file_outlined),
                      label: const Text('رفع شعار'),
                    ),
                  ),
                ],
              ),
              if (logo != null) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(logo!, height: 60, width: 60, fit: BoxFit.cover),
                ),
              ],
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
              final name = nameController.text.trim();
              final desc = descController.text.trim();
              if (name.isEmpty || desc.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('يرجى تعبئة الحقول')),
                );
                return;
              }
              setState(() {
                if (index == null) {
                  context.read<AdminDataState>().addCompany(
                        AdminCompany(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: name,
                          description: desc,
                          logoPath: logo?.path,
                        ),
                      );
                  final actor = context.read<AuthService>().username ?? 'غير معروف';
                  context.read<AuditLogService>().log(
                        actor: actor,
                        action: 'إضافة شركة',
                        targetType: 'company',
                        targetId: name,
                        details: 'شركة جديدة',
                      );
                } else {
                  context.read<AdminDataState>().updateCompany(
                        existing!.id,
                        existing.copyWith(
                          name: name,
                          description: desc,
                          logoPath: logo?.path,
                        ),
                      );
                  final actor = context.read<AuthService>().username ?? 'غير معروف';
                  context.read<AuditLogService>().log(
                        actor: actor,
                        action: 'تعديل شركة',
                        targetType: 'company',
                        targetId: existing.id,
                        details: 'تعديل بيانات الشركة',
                      );
                }
              });
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
      appBar: const BrandedAppBar(title: 'إدارة شركات الباصات'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCompany,
        icon: const Icon(Icons.add),
        label: const Text('إضافة شركة'),
      ),
      body: ResponsiveContainer(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: context.watch<AdminDataState>().companies.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final company = context.watch<AdminDataState>().companies[index];
            return Card(
              child: ListTile(
                leading: company.logoPath == null
                    ? CircleAvatar(
                        child: Text(company.name.characters.first),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(File(company.logoPath!), width: 40, height: 40, fit: BoxFit.cover),
                      ),
                title: Text(company.name),
                subtitle: Text(company.description),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editCompany(index);
                    } else if (value == 'delete') {
                      _deleteCompany(index);
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
}

