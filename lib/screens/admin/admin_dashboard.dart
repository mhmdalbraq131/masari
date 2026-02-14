import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/responsive_container.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BrandedAppBar(
        title: 'لوحة التحكم',
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
            _StatsRow(
              totalBookings: 284,
              activeTrips: 37,
              revenue: '92,450 ر.س',
            ),
            const SizedBox(height: 16),
            _AdminCard(
              title: 'إدارة شركات الباصات',
              subtitle: 'إضافة وتحديث الشركات المتاحة',
              icon: Icons.directions_bus_outlined,
              onTap: () => context.push('/admin/companies'),
            ),
            const SizedBox(height: 12),
            _AdminCard(
              title: 'إدارة الرحلات',
              subtitle: 'تنظيم جداول الرحلات والوجهات',
              icon: Icons.route_outlined,
              onTap: () => context.push('/admin/trips'),
            ),
            const SizedBox(height: 12),
            _AdminCard(
              title: 'إدارة الأسعار',
              subtitle: 'تحديث الأسعار والعروض',
              icon: Icons.price_change_outlined,
              onTap: () => context.push('/admin/prices'),
            ),
            const SizedBox(height: 12),
            _AdminCard(
              title: 'إدارة الحجوزات',
              subtitle: 'متابعة الطلبات وتأكيدها',
              icon: Icons.event_available_outlined,
              onTap: () => context.push('/admin/bookings'),
            ),
            const SizedBox(height: 12),
            _AdminCard(
              title: 'إدارة المستخدمين',
              subtitle: 'صلاحيات وإدارة الحسابات',
              icon: Icons.people_outline,
              onTap: () => context.push('/admin/users'),
            ),
            const SizedBox(height: 12),
            const _AdminCard(
              title: 'التقارير',
              subtitle: 'تحليلات الأداء والمبيعات',
              icon: Icons.bar_chart_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int totalBookings;
  final int activeTrips;
  final String revenue;

  const _StatsRow({
    required this.totalBookings,
    required this.activeTrips,
    required this.revenue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'إجمالي الحجوزات',
            value: totalBookings.toString(),
            icon: Icons.confirmation_number_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'الرحلات النشطة',
            value: activeTrips.toString(),
            icon: Icons.airplane_ticket_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'الإيرادات',
            value: revenue,
            icon: Icons.payments_outlined,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const _AdminCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_left),
        onTap: onTap,
      ),
    );
  }
}
