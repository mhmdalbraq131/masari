import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../logic/favorites_service.dart';
import '../auth/auth_service.dart';
import '../models/trip_details.dart';
import '../widgets/branded_app_bar.dart';
import '../widgets/responsive_container.dart';

class DetailsScreen extends StatefulWidget {
  final TripDetails trip;
  const DetailsScreen({super.key, required this.trip});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  List<String> get _gallery => [
        widget.trip.imageUrl,
        'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=1400&q=80',
        'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=1400&q=80',
      ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    final favorites = context.watch<FavoritesService>();
    final auth = context.watch<AuthService>();
    final isFavorite = favorites.isFavorite(trip.id);
    return Scaffold(
      appBar: BrandedAppBar(
        title: 'تفاصيل الرحلة',
        actions: [
          IconButton(
            onPressed: () {
              if (!auth.isLoggedIn) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('يرجى تسجيل الدخول لإضافة المفضلة')),
                );
                context.go('/login');
                return;
              }
              if (isFavorite) {
                favorites.remove(trip.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تمت إزالة الرحلة من المفضلة')),
                );
              } else {
                favorites.addFromTripDetails(trip);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حفظ الرحلة في المفضلة')),
                );
              }
            },
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم نسخ الرابط للمشاركة')),
              );
            },
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (!auth.isLoggedIn) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('يرجى تسجيل الدخول لإتمام الحجز')),
            );
            context.go('/login');
            return;
          }
          context.push('/booking');
        },
        icon: const Icon(Icons.calendar_month_outlined),
        label: Text('احجز الآن • ${trip.priceLabel}'),
      ),
      body: ResponsiveContainer(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
          children: [
            _GallerySlider(
              controller: _pageController,
              images: _gallery,
              currentIndex: _currentIndex,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              heroTag: 'trip-${trip.id}',
            ),
            const SizedBox(height: 12),
            Text(trip.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(trip.location, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            Text(trip.description),
            const SizedBox(height: 20),
            _PriceBreakdown(priceLabel: trip.priceLabel),
            const SizedBox(height: 20),
            const _SectionHeader(title: 'التقييمات'),
            const SizedBox(height: 10),
            const _ReviewCard(
              name: 'سارة',
              comment: 'تنظيم ممتاز وتجربة مريحة للغاية.',
              rating: 5,
            ),
            const SizedBox(height: 10),
            const _ReviewCard(
              name: 'خالد',
              comment: 'خدمة سريعة والدعم متعاون.',
              rating: 4,
            ),
          ],
        ),
      ),
    );
  }
}

class _GallerySlider extends StatelessWidget {
  final PageController controller;
  final List<String> images;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final String heroTag;

  const _GallerySlider({
    required this.controller,
    required this.images,
    required this.currentIndex,
    required this.onPageChanged,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 230,
          child: PageView.builder(
            controller: controller,
            onPageChanged: onPageChanged,
            itemCount: images.length,
            itemBuilder: (context, index) {
              final image = images[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Hero(
                  tag: index == 0 ? heroTag : '$heroTag-$index',
                  child: CachedNetworkImage(
                    imageUrl: image,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.white10),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.broken_image_outlined),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            images.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: currentIndex == index ? 18 : 6,
              decoration: BoxDecoration(
                color: currentIndex == index
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _PriceBreakdown extends StatelessWidget {
  final String priceLabel;
  const _PriceBreakdown({required this.priceLabel});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('تفاصيل السعر', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _PriceRow(label: 'سعر الرحلة', value: priceLabel),
            const _PriceRow(label: 'رسوم الخدمة', value: '40 ر.س'),
            const _PriceRow(label: 'الضرائب', value: '20 ر.س'),
            const Divider(height: 20),
            _PriceRow(
              label: 'الإجمالي',
              value: _totalPrice(priceLabel),
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  String _totalPrice(String label) {
    final numeric = RegExp(r'\d+').firstMatch(label)?.group(0) ?? '0';
    final base = int.tryParse(numeric) ?? 0;
    final total = base + 60;
    return '$total ر.س';
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _PriceRow({required this.label, required this.value, this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    final style = isTotal
        ? Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String name;
  final String comment;
  final int rating;

  const _ReviewCard({
    required this.name,
    required this.comment,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(name, style: Theme.of(context).textTheme.titleSmall)),
                _RatingStars(rating: rating),
              ],
            ),
            const SizedBox(height: 8),
            Text(comment),
          ],
        ),
      ),
    );
  }
}

class _RatingStars extends StatelessWidget {
  final int rating;
  const _RatingStars({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        final filled = index < rating;
        return Icon(
          filled ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }
}
