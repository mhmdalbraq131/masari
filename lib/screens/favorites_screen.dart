import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/models/favorite_trip_model.dart';
import '../logic/favorites_service.dart';
import '../models/trip_details.dart';
import '../widgets/branded_app_bar.dart';
import '../widgets/responsive_container.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  void _remove(BuildContext context, FavoriteTrip trip) {
    HapticFeedback.selectionClick();
    context.read<FavoritesService>().remove(trip.id);
    Fluttertoast.showToast(msg: 'تمت إزالة ${trip.title} من المفضلة');
  }

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesService>().items;

    return Scaffold(
      appBar: BrandedAppBar(
        title: 'المفضلة',
        actions: [
          IconButton(
            onPressed: () => context.push('/notifications'),
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: ResponsiveContainer(
        child: favorites.isEmpty
            ? const _EmptyState()
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: favorites.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = favorites[index];
                  return Dismissible(
                    key: ValueKey(item.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => _remove(context, item),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    ),
                    child: Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => context.push(
                          '/details',
                          extra: TripDetails(
                            id: item.id,
                            title: item.title,
                            location: item.location,
                            imageUrl: item.imageUrl,
                            description: item.description,
                            priceLabel: item.priceLabel,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: item.imageUrl,
                                  width: 90,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(color: Colors.white10),
                                  errorWidget: (_, __, ___) => const Icon(Icons.broken_image_outlined),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.title, style: Theme.of(context).textTheme.titleSmall),
                                    const SizedBox(height: 6),
                                    Text(item.location, style: Theme.of(context).textTheme.bodySmall),
                                    const SizedBox(height: 6),
                                    Text(item.priceLabel, style: Theme.of(context).textTheme.labelLarge),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => _remove(context, item),
                                icon: const Icon(Icons.bookmark_remove_outlined),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
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
            Icon(Icons.bookmark_border, size: 72, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text('لا توجد عناصر مفضلة', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text('أضف رحلاتك المفضلة لتظهر هنا.', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
