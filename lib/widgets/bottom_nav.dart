import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final Map<int, int> badges;

  const BottomNav({
    super.key,
    required this.currentIndex,
    this.onTap,
    this.badges = const {},
  });

  List<_BottomNavItem> _items(BuildContext context) {
    final t = AppLocalizations.of(context);
    return [
      _BottomNavItem(label: t.navHome, icon: Icons.home, route: '/home'),
      _BottomNavItem(
        label: t.navFlights,
        icon: Icons.flight,
        route: '/flights',
      ),
      _BottomNavItem(label: t.navHotels, icon: Icons.hotel, route: '/hotels'),
      _BottomNavItem(
        label: t.navBuses,
        icon: Icons.directions_bus,
        route: '/bus-companies',
      ),
      _BottomNavItem(
        label: t.navFavorites,
        icon: Icons.favorite,
        route: '/favorites',
      ),
      _BottomNavItem(
        label: t.navProfile,
        icon: Icons.person_outline,
        route: '/profile',
      ),
    ];
  }

  void _handleTap(BuildContext context, int index) {
    if (index == currentIndex) return;
    if (onTap != null) {
      onTap!(index);
      return;
    }
    context.go(_items(context)[index].route);
  }

  @override
  Widget build(BuildContext context) {
    final items = _items(context);
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _handleTap(context, index),
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: items
          .map(
            (item) => BottomNavigationBarItem(
              icon: Icon(item.icon),
              label: item.label,
            ),
          )
          .toList(),
    );
  }
}

class BottomNavScaffold extends StatelessWidget {
  final Widget child;

  const BottomNavScaffold({super.key, required this.child});

  Future<bool> _confirmExit(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد الخروج'),
        content: const Text('هل تريد الخروج من التطبيق؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('خروج'),
          ),
        ],
      ),
    );
    return result == true;
  }

  int _indexForLocation(String location) {
    if (location == '/home' || location.startsWith('/home')) return 0;
    if (location.startsWith('/flights')) return 1;
    if (location.startsWith('/hotels')) return 2;
    if (location.startsWith('/bus')) return 3;
    if (location.startsWith('/favorites')) return 4;
    if (location.startsWith('/profile') || location.startsWith('/settings')) {
      return 5;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final router = GoRouter.of(context);
        if (router.canPop()) {
          context.pop();
          return;
        }
        final shouldExit = await _confirmExit(context);
        if (shouldExit) {
          await SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: child,
        bottomNavigationBar: BottomNav(currentIndex: _indexForLocation(location)),
      ),
    );
  }
}

class _BottomNavItem {
  final String label;
  final IconData icon;
  final String route;

  const _BottomNavItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}
