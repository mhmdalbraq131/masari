import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/admin_login_screen.dart';
import '../screens/admin/manage_bookings.dart';
import '../screens/admin/manage_companies.dart';
import '../screens/admin/manage_prices.dart';
import '../screens/admin/manage_trips.dart';
import '../screens/admin/manage_users.dart';
import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';
import '../screens/my_trips_screen.dart';
import '../screens/details_screen.dart';
import '../models/trip_details.dart';
import '../screens/booking_screen.dart';
import '../screens/bus/bus_companies_screen.dart';
import '../screens/bus/bus_search_screen.dart';
import '../screens/bus/bus_results_screen.dart';
import '../screens/bus/bus_passenger_screen.dart';
import '../screens/bus/booking_confirmation_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/flights/flight_search_screen.dart';
import '../screens/flights/flight_results_screen.dart';
import '../screens/flights/flight_passenger_screen.dart';
import '../screens/hotels_screen.dart';
import '../screens/settings_screen.dart';
import '../data/models/flight_model.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/admin_guard.dart';
import '../widgets/auth_required.dart';
import '../widgets/branded_app_bar.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        pageBuilder: (context, state) => _transitionPage(state.pageKey, const SplashScreen()),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => _transitionPage(state.pageKey, const LoginScreen()),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder: (context, state) => _transitionPage(state.pageKey, const RegisterScreen()),
      ),
      GoRoute(
        path: '/forgot',
        name: 'forgot',
        pageBuilder: (context, state) => _transitionPage(state.pageKey, const ForgotPasswordScreen()),
      ),
      GoRoute(
        path: '/otp',
        name: 'otp',
        pageBuilder: (context, state) => _transitionPage(state.pageKey, const OtpScreen()),
      ),
      ShellRoute(
        builder: (context, state, child) => BottomNavScaffold(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) => _transitionPage(state.pageKey, const HomeScreen()),
          ),
          GoRoute(
            path: '/flights',
            name: 'flights',
            pageBuilder: (context, state) => _transitionPage(state.pageKey, const FlightSearchScreen()),
          ),
          GoRoute(
            path: '/hotels',
            name: 'hotels',
            pageBuilder: (context, state) => _transitionPage(state.pageKey, const HotelsScreen()),
          ),
          GoRoute(
            path: '/bus-companies',
            name: 'bus-companies',
            pageBuilder: (context, state) => _transitionPage(state.pageKey, const BusCompaniesScreen()),
          ),
          GoRoute(
            path: '/favorites',
            name: 'favorites',
            pageBuilder: (context, state) => _transitionPage(
              state.pageKey,
              const AuthRequired(
                reason: 'يرجى تسجيل الدخول لعرض المفضلة',
                child: FavoritesScreen(),
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        pageBuilder: (context, state) => _transitionPage(
          state.pageKey,
          const AdminGuard(child: AdminDashboard()),
        ),
      ),
      GoRoute(
        path: '/admin-login',
        name: 'admin-login',
        pageBuilder: (context, state) => _transitionPage(state.pageKey, const AdminLoginScreen()),
      ),
      GoRoute(
        path: '/admin/companies',
        name: 'admin-companies',
        pageBuilder: (context, state) => _transitionPage(
          state.pageKey,
          const AdminGuard(child: ManageCompaniesScreen()),
        ),
      ),
      GoRoute(
        path: '/admin/trips',
        name: 'admin-trips',
        pageBuilder: (context, state) => _transitionPage(
          state.pageKey,
          const AdminGuard(child: ManageTripsScreen()),
        ),
      ),
      GoRoute(
        path: '/admin/bookings',
        name: 'admin-bookings',
        pageBuilder: (context, state) => _transitionPage(
          state.pageKey,
          const AdminGuard(child: ManageBookingsScreen()),
        ),
      ),
      GoRoute(
        path: '/admin/prices',
        name: 'admin-prices',
        pageBuilder: (context, state) => _transitionPage(
          state.pageKey,
          const AdminGuard(child: ManagePricesScreen()),
        ),
      ),
      GoRoute(
        path: '/admin/users',
        name: 'admin-users',
        pageBuilder: (context, state) => _transitionPage(
          state.pageKey,
          const AdminGuard(child: ManageUsersScreen()),
        ),
      ),
      GoRoute(
        path: '/mytrips',
        name: 'mytrips',
        pageBuilder: (context, state) => _transitionPage(
          state.pageKey,
          const AuthRequired(
            reason: 'يرجى تسجيل الدخول لعرض حجوزاتك',
            child: MyTripsScreen(),
          ),
        ),
      ),
      GoRoute(
        path: '/my-trips',
        redirect: (_, __) => '/mytrips',
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (context, state) => _transitionPage(state.pageKey, const SettingsScreen()),
      ),
      GoRoute(
        path: '/flight-results',
        name: 'flight-results',
        pageBuilder: (context, state) {
          final payload = state.extra as Map<String, dynamic>?;
          if (payload == null) {
            return _transitionPage(state.pageKey, const _RouteErrorScreen());
          }
          final criteria = payload['criteria'] as FlightSearchCriteria?;
          final results = payload['results'] as List<FlightOption>?;
          if (criteria == null || results == null) {
            return _transitionPage(state.pageKey, const _RouteErrorScreen());
          }
          return _transitionPage(
            state.pageKey,
            FlightResultsScreen(criteria: criteria, results: results),
          );
        },
      ),
      GoRoute(
        path: '/flight-passengers',
        name: 'flight-passengers',
        pageBuilder: (context, state) {
          final flight = state.extra as FlightOption?;
          if (flight == null) {
            return _transitionPage(state.pageKey, const _RouteErrorScreen());
          }
          return _transitionPage(state.pageKey, FlightPassengerScreen(flight: flight));
        },
      ),
      GoRoute(
        path: '/booking',
        name: 'booking',
        pageBuilder: (context, state) => _transitionPage(
          state.pageKey,
          const AuthRequired(
            reason: 'يرجى تسجيل الدخول لإتمام الحجز',
            child: BookingScreen(),
          ),
        ),
      ),
      GoRoute(
        path: '/bus-search',
        name: 'bus-search',
        pageBuilder: (context, state) => _transitionPage(
          state.pageKey,
          const BusSearchScreen(),
        ),
      ),
      GoRoute(
        path: '/bus-results',
        name: 'bus-results',
        pageBuilder: (context, state) => _transitionPage(
          state.pageKey,
          const BusResultsScreen(),
        ),
      ),
      GoRoute(
        path: '/bus-passenger',
        name: 'bus-passenger',
        pageBuilder: (context, state) => _transitionPage(
          state.pageKey,
          const BusPassengerScreen(),
        ),
      ),
      GoRoute(
        path: '/bus-confirmation',
        name: 'bus-confirmation',
        pageBuilder: (context, state) => _transitionPage(
          state.pageKey,
          const BookingConfirmationScreen(),
        ),
      ),
      GoRoute(
        path: '/details',
        name: 'details',
        pageBuilder: (context, state) {
          final trip = state.extra as TripDetails?;
          if (trip == null) {
            return _transitionPage(state.pageKey, const _RouteErrorScreen());
          }
          return _transitionPage(state.pageKey, DetailsScreen(trip: trip));
        },
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        pageBuilder: (context, state) => _transitionPage(state.pageKey, const NotificationsScreen()),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        pageBuilder: (context, state) => _transitionPage(state.pageKey, const ProfileScreen()),
      ),
    ],
  );
}

class _RouteErrorScreen extends StatelessWidget {
  const _RouteErrorScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandedAppBar(title: 'خطأ في البيانات'),
      body: Center(
        child: TextButton(
          onPressed: () => context.go('/home'),
          child: const Text('العودة للرئيسية'),
        ),
      ),
    );
  }
}

CustomTransitionPage _transitionPage(LocalKey key, Widget child) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // انتقالات سلسة: انزلاق + تلاشي + تكبير خفيف
      final slide = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
          .chain(CurveTween(curve: Curves.easeOutCubic));
      final fade = Tween<double>(begin: 0, end: 1).chain(CurveTween(curve: Curves.easeOut));
      final scale = Tween<double>(begin: 0.98, end: 1).chain(CurveTween(curve: Curves.easeOut));

      return SlideTransition(
        position: animation.drive(slide),
        child: FadeTransition(
          opacity: animation.drive(fade),
          child: ScaleTransition(
            scale: animation.drive(scale),
            child: child,
          ),
        ),
      );
    },
  );
}
