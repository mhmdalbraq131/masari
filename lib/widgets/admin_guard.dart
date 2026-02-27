import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../auth/auth_service.dart';
import 'branded_app_bar.dart';
import '../data/models/user_role.dart';

class AdminGuard extends StatelessWidget {
  final Widget child;
  final Set<UserRole> allowedRoles;

  const AdminGuard({
    super.key,
    required this.child,
    this.allowedRoles = const {UserRole.admin},
  });

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthService>().role;
    if (allowedRoles.contains(role)) {
      return child;
    }
    return Scaffold(
      appBar: const BrandedAppBar(title: 'صلاحيات المدير'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 48),
              const SizedBox(height: 12),
              const Text('لا تملك صلاحية الوصول لهذه الصفحة'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.go('/admin-login'),
                child: const Text('تسجيل دخول المدير'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
