import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/admin_data_state.dart';
import '../../data/models/user_role.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/responsive_container.dart';

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final users = context.watch<AdminDataState>().users;
    return Scaffold(
      appBar: const BrandedAppBar(title: 'إدارة المستخدمين'),
      body: ResponsiveContainer(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
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
                      },
                      items: const [
                        DropdownMenuItem(value: UserRole.user, child: Text('مستخدم')),
                        DropdownMenuItem(value: UserRole.admin, child: Text('مدير')),
                      ],
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
