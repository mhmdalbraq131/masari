import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const supportedLocales = [Locale('ar'), Locale('en')];

  bool get isArabic => locale.languageCode == 'ar';

  String get settingsTitle => isArabic ? 'الإعدادات' : 'Settings';
  String get securityTitle => isArabic ? 'الأمان' : 'Security';
  String get preferencesTitle => isArabic ? 'التفضيلات' : 'Preferences';
  String get languageLabel => isArabic ? 'اللغة' : 'Language';
  String get themeLabel => isArabic ? 'المظهر' : 'Theme';
  String get themeDark => isArabic ? 'داكن' : 'Dark';
  String get themeLight => isArabic ? 'فاتح' : 'Light';
  String get themeSystem => isArabic ? 'النظام' : 'System';
  String get biometricsLabel =>
      isArabic ? 'تفعيل البصمة/الوجه' : 'Enable biometrics';
  String get biometricsSubtitle => isArabic
      ? 'استخدم المصادقة الحيوية قبل تأكيد الحجز'
      : 'Use biometrics before confirming booking';
  String get pinStatusSet => isArabic ? 'تم إعداد رمز PIN' : 'PIN is set';
  String get pinStatusNotSet =>
      isArabic ? 'لم يتم إعداد رمز PIN' : 'PIN not set';
  String get pinNew => isArabic ? 'رمز PIN الجديد' : 'New PIN';
  String get pinConfirm => isArabic ? 'تأكيد رمز PIN' : 'Confirm PIN';
  String get pinSave => isArabic ? 'حفظ رمز PIN' : 'Save PIN';
  String get pinSaving => isArabic ? 'جارٍ الحفظ...' : 'Saving...';
  String get pinSaved =>
      isArabic ? 'تم حفظ رمز PIN بنجاح' : 'PIN saved successfully';
  String get pinMismatch =>
      isArabic ? 'رمز PIN غير متطابق' : 'PIN does not match';
  String get pinInvalid =>
      isArabic ? 'يرجى إدخال رمز PIN من 4 أرقام' : 'Enter a 4-digit PIN';
  String get deviceNoBiometrics => isArabic
      ? 'الجهاز لا يدعم المصادقة الحيوية'
      : 'Biometrics not available on this device';

  String get profileTitle => isArabic ? 'الملف الشخصي' : 'Profile';
  String get editProfile => isArabic ? 'تعديل الملف' : 'Edit profile';
  String get reportsLabel => isArabic ? 'التقارير' : 'Reports';
  String get settingsLabel => isArabic ? 'الإعدادات' : 'Settings';
  String get myTripsLabel => isArabic ? 'رحلاتي' : 'My trips';
  String get logoutLabel => isArabic ? 'تسجيل الخروج' : 'Logout';
  String get contactTitle => isArabic ? 'بيانات التواصل' : 'Contact';
  String get phoneLabel => isArabic ? 'الهاتف' : 'Phone';
  String get emailLabel => isArabic ? 'البريد الإلكتروني' : 'Email';
  String get myTripsSubtitle => isArabic
      ? 'عرض الحجوزات الحالية والسابقة'
      : 'View current and past bookings';
  String get reportsSubtitle => isArabic
      ? 'إحصائيات الحجوزات والمدفوعات'
      : 'Booking and payment insights';
  String get settingsSubtitle =>
      isArabic ? 'إعدادات التطبيق والتفضيلات' : 'App settings and preferences';

  String get navHome => isArabic ? 'الرئيسية' : 'Home';
  String get navFlights => isArabic ? 'الطيران' : 'Flights';
  String get navHotels => isArabic ? 'الفنادق' : 'Hotels';
  String get navBuses => isArabic ? 'الباصات' : 'Buses';
  String get navFavorites => isArabic ? 'المفضلة' : 'Favorites';
    String get navProfile => isArabic ? 'الملف' : 'Profile';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
