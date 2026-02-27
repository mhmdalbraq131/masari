import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'auth/auth_service.dart';
import 'logic/admin_data_state.dart';
import 'logic/app_state.dart';
import 'logic/bus_booking_controller.dart';
import 'logic/favorites_service.dart';
import 'logic/hajj_umrah_service.dart';
import 'logic/location_service.dart';
import 'logic/mytrips_service.dart';
import 'l10n/app_localizations.dart';
import 'routes/app_router.dart';
import 'services/bus_service.dart';
import 'services/app_settings_service.dart';
import 'services/security_service.dart';
import 'services/audit_log_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => AdminDataState()),
        ChangeNotifierProvider(create: (_) => FavoritesService()),
        ChangeNotifierProvider(create: (_) => HajjUmrahService()..load()),
        ChangeNotifierProvider(create: (_) => LocationService()..load()),
        ChangeNotifierProvider(create: (_) => MyTripsService()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => AppSettingsService()..load()),
        ChangeNotifierProvider(create: (_) => SecurityService()),
        ChangeNotifierProvider(create: (_) => AuditLogService()..load()),
        ChangeNotifierProvider(
          create: (_) => BusBookingController(FirestoreBusService()),
        ),
      ],
      child: const MasariApp(),
    ),
  );
}

class MasariApp extends StatelessWidget {
  const MasariApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'مساري',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: context.watch<AppSettingsService>().themeMode,
      locale: context.watch<AppSettingsService>().locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: AppRouter.router,
      builder: (context, child) {
        final locale = context.watch<AppSettingsService>().locale;
        return Directionality(
          textDirection: locale.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
