import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_service.dart';
import '../../data/models/hajj_umrah_models.dart';
import '../../logic/hajj_umrah_service.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/responsive_container.dart';

class HajjUmrahPackageDetailsScreen extends StatelessWidget {
  final String packageId;

  const HajjUmrahPackageDetailsScreen({super.key, required this.packageId});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<HajjUmrahService>();
    final pkg = service.packages
        .where((item) => item.id == packageId)
        .cast<HajjUmrahPackage?>()
        .firstWhere((item) => item != null, orElse: () => null);
    if (pkg == null) {
      return Scaffold(
        appBar: const BrandedAppBar(title: 'تفاصيل الباقة'),
        body: const Center(child: Text('تعذر العثور على الباقة')),
      );
    }

    final remaining = service.remainingSeats(pkg.id);
    final canBook = remaining > 0;

    return Scaffold(
      appBar: const BrandedAppBar(title: 'تفاصيل الباقة'),
      body: SafeArea(
        child: ResponsiveContainer(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _HeaderCard(package: pkg, remaining: remaining),
              const SizedBox(height: 16),
              _SectionTitle(title: 'الوصف'),
              const SizedBox(height: 8),
              Text(pkg.description),
              const SizedBox(height: 16),
              _SectionTitle(title: 'موقع الفندق'),
              const SizedBox(height: 8),
              SizedBox(
                height: 220,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(pkg.hotelLat, pkg.hotelLng),
                      zoom: 14,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId(pkg.id),
                        position: LatLng(pkg.hotelLat, pkg.hotelLng),
                        infoWindow: InfoWindow(title: pkg.hotelName),
                      ),
                    },
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    myLocationEnabled: false,
                    rotateGesturesEnabled: false,
                    scrollGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                    zoomGesturesEnabled: false,
                    liteModeEnabled: true,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: canBook
                    ? () {
                        final auth = context.read<AuthService>();
                        if (!auth.isLoggedIn) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('يرجى تسجيل الدخول لإتمام الحجز')),
                          );
                          context.go('/login');
                          return;
                        }
                        context.go('/hajj-umrah/book/${pkg.id}');
                      }
                    : null,
                child: Text(
                  canBook ? 'احجز الآن' : 'لا توجد مقاعد متاحة',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final HajjUmrahPackage package;
  final int remaining;

  const _HeaderCard({required this.package, required this.remaining});

  String _typeLabel(HajjUmrahType type) {
    return type == HajjUmrahType.hajj ? 'الحج' : 'العمرة';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(package.name,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('${_typeLabel(package.type)} • ${package.durationDays} أيام'),
            const SizedBox(height: 6),
            Text('الفندق: ${package.hotelName}'),
            const SizedBox(height: 6),
            Text('النقل: ${package.transportType}'),
            const SizedBox(height: 6),
            Text('المقاعد المتبقية: $remaining'),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${package.priceSar.toStringAsFixed(0)} ر.س',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}
