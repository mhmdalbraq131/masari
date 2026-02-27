import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_service.dart';
import '../../logic/admin_data_state.dart';
import '../../data/models/user_role.dart';
import '../../services/audit_log_service.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/responsive_container.dart';

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'مدير';
      case UserRole.subAdmin:
        return 'مساعد مدير';
      case UserRole.bookingAgent:
        return 'موظف حجوزات';
      case UserRole.visaOfficer:
        return 'موظف تأشيرات';
      case UserRole.supervisor:
        return 'مشرف';
      case UserRole.user:
        return 'مستخدم';
      case UserRole.guest:
        return 'ضيف';
    }
  }

  @override
  Widget build(BuildContext context) {
    final users = context.watch<AdminDataState>().users;
    return Scaffold(
      appBar: const BrandedAppBar(title: 'إدارة المستخدمين'),
      body: ResponsiveContainer(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final user = users[index];
            return Card(
              child: ListTile(
                title: Text(user.name),
                subtitle: Text(user.email),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: user.active,
                      onChanged: (value) {
                        context.read<AdminDataState>().updateUser(
                              user.id,
                              user.copyWith(active: value),
                            );
                        final actor = context.read<AuthService>().username ?? 'غير معروف';
                        context.read<AuditLogService>().log(
                              actor: actor,
                              action: 'تحديث حالة مستخدم',
                              targetType: 'user',
                              targetId: user.id,
                              details: value ? 'تفعيل' : 'إيقاف',
                            );
                      },
                    ),
                    DropdownButton<UserRole>(
                      value: user.role,
                      onChanged: (role) {
                        if (role == null) return;
                        context.read<AdminDataState>().updateUser(
                              user.id,
                              user.copyWith(role: role),
                            );
                        final actor = context.read<AuthService>().username ?? 'غير معروف';
                        context.read<AuditLogService>().log(
                              actor: actor,
                              action: 'تغيير دور مستخدم',
                              targetType: 'user',
                              targetId: user.id,
                              details: _roleLabel(role),
                            );
                      },
                      items: [
                        UserRole.admin,
                        UserRole.supervisor,
                        UserRole.subAdmin,
                        UserRole.bookingAgent,
                        UserRole.visaOfficer,
                        UserRole.user,
                      ]
                          .map(
                            (role) => DropdownMenuItem(
                              value: role,
                              child: Text(_roleLabel(role)),
                            ),
                          )
                          .toList(),
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
