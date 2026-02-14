import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/responsive_container.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم المدير'),
        actions: [
          IconButton(
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.home_outlined),
          ),
        ],
      ),
      body: ResponsiveContainer(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.dashboard_outlined),
                title: const Text('إحصائيات عامة'),
                subtitle: const Text('متابعة الحجوزات والمستخدمين اليوم'),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.manage_accounts_outlined),
                title: const Text('إدارة المستخدمين'),
                subtitle: const Text('عرض صلاحيات المستخدمين وتعديلها'),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.report_outlined),
                title: const Text('التقارير'),
                subtitle: const Text('تقارير المبيعات والأداء الشهري'),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
