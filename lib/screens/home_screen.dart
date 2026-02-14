import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../models/trip_details.dart';
import '../widgets/branded_app_bar.dart';
import '../widgets/responsive_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _loading = true;

  final List<String> _sliderImages = const [
    'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1400&q=80',
    'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=1400&q=80',
    'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=1400&q=80',
  ];

  final List<_QuickAction> _quickActions = const [
    _QuickAction(label: 'رحلاتي', icon: Icons.confirmation_number_outlined, route: '/mytrips'),
    _QuickAction(label: 'احجز الآن', icon: Icons.calendar_month_outlined, route: '/booking'),
    _QuickAction(label: 'المفضلة', icon: Icons.favorite_border, route: '/favorites'),
    _QuickAction(label: 'الملف الشخصي', icon: Icons.person_outline, route: '/profile'),
  ];

  final List<_DestinationItem> _destinations = const [
    _DestinationItem(
      title: 'الرياض',
      location: 'السعودية',
      imageUrl: 'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?auto=format&fit=crop&w=1200&q=80',
      priceLabel: 'من 220 ر.س',
    ),
    _DestinationItem(
      title: 'دبي',
      location: 'الإمارات',
      imageUrl: 'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?auto=format&fit=crop&w=1200&q=80',
      priceLabel: 'من 340 ر.س',
    ),
    _DestinationItem(
      title: 'القاهرة',
      location: 'مصر',
      imageUrl: 'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?auto=format&fit=crop&w=1200&q=80',
      priceLabel: 'من 260 ر.س',
    ),
    _DestinationItem(
      title: 'الدوحة',
      location: 'قطر',
      imageUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80',
      priceLabel: 'من 310 ر.س',
    ),
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _loading = false);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _loading = false);
    Fluttertoast.showToast(msg: 'تم تحديث الصفحة');
  }

  @override
  Widget build(BuildContext context) {
    const cards = [
      _ServiceCardData(title: 'الرحلات', icon: Icons.airplane_ticket, route: '/mytrips'),
      _ServiceCardData(title: 'الطيران', icon: Icons.flight, route: '/flights'),
      _ServiceCardData(title: 'الفنادق', icon: Icons.hotel, route: '/hotels'),
      _ServiceCardData(title: 'الباصات', icon: Icons.directions_bus, route: '/bus-companies'),
    ];

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: const BrandedAppBar(title: 'الرئيسية'),
        body: SafeArea(
          child: ResponsiveContainer(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: _loading
                  ? const _HomeSkeleton()
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                      _PersonalGreeting(
                        title: 'مرحبًا أحمد 👋',
                        subtitle: 'ابدأ التخطيط لرحلتك القادمة بسهولة.',
                      ),
                      const SizedBox(height: 16),

                      _SectionHeader(title: 'استكشف الوجهات', actionLabel: 'الكل'),
                      const SizedBox(height: 10),
                      _ImageSlider(
                        controller: _pageController,
                        images: _sliderImages,
                        currentIndex: _currentPage,
                        onPageChanged: (index) => setState(() => _currentPage = index),
                      ),
                      const SizedBox(height: 16),

                      _OffersBanner(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          context.go('/booking');
                        },
                      ),
                      const SizedBox(height: 16),

                      _SectionHeader(title: 'إجراءات سريعة'),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 84,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _quickActions.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final item = _quickActions[index];
                            return _QuickActionButton(
                              item: item,
                              onTap: () => context.go(item.route),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      _SectionHeader(title: 'الوجهات الشعبية', actionLabel: 'عرض المزيد'),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 210,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _destinations.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final item = _destinations[index];
                            return _DestinationCard(
                              item: item,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                context.push(
                                  '/details',
                                  extra: TripDetails(
                                    id: item.title,
                                    title: 'رحلة إلى ${item.title}',
                                    location: item.location,
                                    imageUrl: item.imageUrl,
                                    description: 'أفضل العروض لزيارة ${item.title} مع خيارات مرنة للحجز.',
                                    priceLabel: item.priceLabel,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // بطاقات الخدمات
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.1,
                        ),
                        itemCount: cards.length,
                        itemBuilder: (context, index) {
                          final item = cards[index];
                          return TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 350),
                            tween: Tween(begin: 0.96, end: 1),
                            builder: (context, value, child) => Transform.scale(scale: value, child: child),
                            child: _ServiceCard(item: item),
                          );
                        },
                      ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PersonalGreeting extends StatelessWidget {
  final String title;
  final String subtitle;

  const _PersonalGreeting({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(subtitle),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;

  const _SectionHeader({required this.title, this.actionLabel});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        if (actionLabel != null)
          TextButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              Fluttertoast.showToast(msg: 'قريبًا');
            },
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class _ImageSlider extends StatelessWidget {
  final PageController controller;
  final List<String> images;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  const _ImageSlider({
    required this.controller,
    required this.images,
    required this.currentIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: controller,
            itemCount: images.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: images[index],
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: Colors.white10),
                      errorWidget: (_, __, ___) => const Icon(Icons.broken_image_outlined),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black.withOpacity(0.55), Colors.transparent],
                        ),
                      ),
                    ),
                    const Positioned(
                      left: 16,
                      bottom: 16,
                      child: Text('خصومات تصل 25%', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
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
                    : Theme.of(context).colorScheme.primary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OffersBanner extends StatelessWidget {
  final VoidCallback onPressed;

  const _OffersBanner({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('عرض اليوم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                SizedBox(height: 6),
                Text('احصل على خصم 15% على حجوزات الطيران القادمة.'),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: Text(
              'احجز الآن',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final String route;

  const _QuickAction({required this.label, required this.icon, required this.route});
}

class _QuickActionButton extends StatelessWidget {
  final _QuickAction item;
  final VoidCallback onTap;

  const _QuickActionButton({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(item.icon, color: Theme.of(context).colorScheme.primary),
            const Spacer(),
            Text(item.label, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
      ),
    );
  }
}

class _DestinationItem {
  final String title;
  final String location;
  final String imageUrl;
  final String priceLabel;

  const _DestinationItem({
    required this.title,
    required this.location,
    required this.imageUrl,
    required this.priceLabel,
  });
}

class _DestinationCard extends StatelessWidget {
  final _DestinationItem item;
  final VoidCallback onTap;

  const _DestinationCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: Colors.white10),
                  errorWidget: (_, __, ___) => const Icon(Icons.broken_image_outlined),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(item.location, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 6),
                    Text(item.priceLabel, style: Theme.of(context).textTheme.labelLarge),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceCardData {
  final String title;
  final IconData icon;
  final String route;

  const _ServiceCardData({required this.title, required this.icon, required this.route});
}

class _ServiceCard extends StatelessWidget {
  final _ServiceCardData item;

  const _ServiceCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          HapticFeedback.selectionClick();
          if (item.route == '/details') {
            context.push(
              '/details',
              extra: const TripDetails(
                id: 'hotel',
                title: 'حجز الفنادق',
                location: 'وجهات متعددة',
                imageUrl: 'https://images.unsplash.com/photo-1501117716987-c8e1ecb210d0?auto=format&fit=crop&w=1200&q=80',
                description: 'اختيارات واسعة من الفنادق بأسعار مناسبة.',
                priceLabel: '320 ر.س',
              ),
            );
          } else {
            context.go(item.route);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Icon(item.icon, size: 32, color: Theme.of(context).colorScheme.primary),
              ),
              const Spacer(),
              Text(item.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  if (item.route == '/details') {
                    context.push(
                      '/details',
                      extra: const TripDetails(
                        id: 'hotel',
                        title: 'حجز الفنادق',
                        location: 'وجهات متعددة',
                        imageUrl: 'https://images.unsplash.com/photo-1501117716987-c8e1ecb210d0?auto=format&fit=crop&w=1200&q=80',
                        description: 'اختيارات واسعة من الفنادق بأسعار مناسبة.',
                        priceLabel: '320 ر.س',
                      ),
                    );
                  } else {
                    context.go(item.route);
                  }
                },
                child: const Text('الدخول'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _shimmerBox(height: 90),
        const SizedBox(height: 16),
        _shimmerBox(height: 180),
        const SizedBox(height: 16),
        _shimmerBox(height: 90),
        const SizedBox(height: 16),
        SizedBox(
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, __) => _shimmerBox(width: 120, height: 84),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, __) => _shimmerBox(width: 170, height: 210),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: 4,
          itemBuilder: (_, __) => _shimmerBox(height: 140),
        ),
      ],
    );
  }
}

Widget _shimmerBox({double? width, required double height}) {
  return Shimmer.fromColors(
    baseColor: Colors.white10,
    highlightColor: Colors.white24,
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}
