import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../data/models/hajj_umrah_models.dart';
import '../../logic/hajj_umrah_service.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/responsive_container.dart';

class HajjUmrahPackagesScreen extends StatefulWidget {
  const HajjUmrahPackagesScreen({super.key});

  @override
  State<HajjUmrahPackagesScreen> createState() => _HajjUmrahPackagesScreenState();
}

class _HajjUmrahPackagesScreenState extends State<HajjUmrahPackagesScreen> {
  HajjUmrahType? _typeFilter;
  RangeValues _priceRange = const RangeValues(0, 20000);

  @override
  Widget build(BuildContext context) {
    final service = context.watch<HajjUmrahService>();
    final packages = service.packages;

    final maxPrice = packages.isEmpty
        ? 20000.0
        : packages
            .map((pkg) => pkg.priceSar)
            .reduce((a, b) => a > b ? a : b)
            .clamp(2000.0, 200000.0)
            .toDouble();

    final clampedRange = RangeValues(
      _priceRange.start.clamp(0, maxPrice).toDouble(),
      _priceRange.end.clamp(0, maxPrice).toDouble(),
    );

    final items = packages.where((pkg) {
      if (_typeFilter != null && pkg.type != _typeFilter) return false;
      if (pkg.priceSar < clampedRange.start ||
          pkg.priceSar > clampedRange.end) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: const BrandedAppBar(title: 'باقات الحج والعمرة'),
      body: SafeArea(
        child: ResponsiveContainer(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'التصفية',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('الكل'),
                            selected: _typeFilter == null,
                            onSelected: (_) => setState(() => _typeFilter = null),
                          ),
                          ChoiceChip(
                            label: const Text('الحج'),
                            selected: _typeFilter == HajjUmrahType.hajj,
                            onSelected: (_) =>
                                setState(() => _typeFilter = HajjUmrahType.hajj),
                          ),
                          ChoiceChip(
                            label: const Text('العمرة'),
                            selected: _typeFilter == HajjUmrahType.umrah,
                            onSelected: (_) => setState(
                                () => _typeFilter = HajjUmrahType.umrah),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'السعر حتى ${clampedRange.end.toStringAsFixed(0)} ر.س',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      RangeSlider(
                        values: clampedRange,
                        min: 0,
                        max: maxPrice,
                        divisions: 10,
                        labels: RangeLabels(
                          clampedRange.start.toStringAsFixed(0),
                          clampedRange.end.toStringAsFixed(0),
                        ),
                        onChanged: (value) => setState(() => _priceRange = value),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (items.isEmpty)
                const _EmptyState()
              else
                ...items.map(
                  (pkg) => _PackageCard(
                    package: pkg,
                    remaining: service.remainingSeats(pkg.id),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final HajjUmrahPackage package;
  final int remaining;

  const _PackageCard({required this.package, required this.remaining});

  String _typeLabel(HajjUmrahType type) {
    return type == HajjUmrahType.hajj ? 'الحج' : 'العمرة';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(package.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${_typeLabel(package.type)} • ${package.durationDays} أيام'),
            const SizedBox(height: 4),
            Text('المقاعد المتبقية: $remaining'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${package.priceSar.toStringAsFixed(0)} ر.س',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            const Text('عرض التفاصيل'),
          ],
        ),
        onTap: () => context.go('/hajj-umrah/package/${package.id}'),
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
            Text('لا توجد باقات حالياً',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text('سيتم عرض الباقات عند إضافتها من الإدارة.',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
