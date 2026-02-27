import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/models/booked_trip_model.dart';
import '../logic/mytrips_service.dart';
import '../models/trip_details.dart';
import '../widgets/branded_app_bar.dart';
import '../widgets/responsive_container.dart';

class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trips = context.watch<MyTripsService>().items;

    return Scaffold(
      appBar: const BrandedAppBar(title: 'رحلاتي'),
      body: SafeArea(
        child: ResponsiveContainer(
          child: trips.isEmpty
              ? const _EmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: trips.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final trip = trips[index];
                    return Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => context.push(
                          '/details',
                          extra: TripDetails(
                            id: trip.id,
                            title: trip.title,
                            location: trip.location,
                            imageUrl: trip.imageUrl,
                            description: 'تفاصيل الحجز متاحة داخل التطبيق.',
                            priceLabel: trip.priceLabel,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: trip.imageUrl,
                                  width: 90,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      Container(color: Colors.white10),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.broken_image_outlined),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(trip.title, style: Theme.of(context).textTheme.titleSmall),
                                    const SizedBox(height: 6),
                                    Text(trip.location, style: Theme.of(context).textTheme.bodySmall),
                                    const SizedBox(height: 6),
                                    Text(trip.priceLabel, style: Theme.of(context).textTheme.labelLarge),
                                  ],
                                ),
                              ),
                              _StatusChip(status: trip.status),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
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
            Icon(Icons.flight_takeoff, size: 72, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text('لا توجد حجوزات حالياً', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text('احجز رحلة جديدة لتظهر هنا.', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final BookedTripStatus status;

  const _StatusChip({required this.status});

  String _label() {
    switch (status) {
      case BookedTripStatus.completed:
        return 'مكتملة';
      case BookedTripStatus.cancelled:
        return 'ملغاة';
      case BookedTripStatus.upcoming:
        return 'قادمة';
    }
  }

  Color _color(BuildContext context) {
    switch (status) {
      case BookedTripStatus.completed:
        return Colors.green;
      case BookedTripStatus.cancelled:
        return Colors.redAccent;
      case BookedTripStatus.upcoming:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _label(),
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
