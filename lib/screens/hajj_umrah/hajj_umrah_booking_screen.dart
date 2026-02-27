import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_service.dart';
import '../../data/models/booking_record.dart';
import '../../data/models/hajj_umrah_models.dart';
import '../../logic/app_state.dart';
import '../../logic/hajj_umrah_service.dart';
import '../../logic/mytrips_service.dart';
import '../../data/models/booked_trip_model.dart';
import '../../services/security_service.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/responsive_container.dart';

class HajjUmrahBookingScreen extends StatefulWidget {
  final String packageId;

  const HajjUmrahBookingScreen({super.key, required this.packageId});

  @override
  State<HajjUmrahBookingScreen> createState() => _HajjUmrahBookingScreenState();
}

class _HajjUmrahBookingScreenState extends State<HajjUmrahBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _companionsController = TextEditingController(text: '0');
  final _visaController = TextEditingController();
  File? _passportImage;
  bool _submitting = false;
  bool _prefilled = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _companionsController.dispose();
    _visaController.dispose();
    super.dispose();
  }

  Future<void> _prefill() async {
    if (_prefilled) return;
    _prefilled = true;
    final auth = context.read<AuthService>();
    _nameController.text = auth.username ?? '';

    if (auth.username == null) return;
    final latest = await context
        .read<HajjUmrahService>()
        .latestApplicationForUser(auth.username!);
    if (!mounted || latest == null) return;
    _visaController.text = latest.visaType;
    if (latest.passportImagePath.isNotEmpty) {
      final file = File(latest.passportImagePath);
      if (file.existsSync()) {
        setState(() => _passportImage = file);
      }
    }
  }

  Future<void> _pickPassportImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;
    setState(() => _passportImage = File(picked.path));
  }

  Future<bool> _verifySecurityBeforeConfirm() async {
    final security = context.read<SecurityService>();
    final hasPin = await security.isPinSet();
    if (!hasPin) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إعداد رمز PIN أولاً')),
      );
      context.go('/settings');
      return false;
    }
    if (security.biometricsEnabled) {
      final biometricOk = await security.authenticateBiometric();
      if (biometricOk) return true;
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر التحقق بالبصمة، الرجاء إدخال PIN')),
      );
    }
    if (!mounted) return false;
    final verified = await context.push<bool>('/pin-verify');
    return verified == true;
  }

  String _generateApplicationId() {
    final now = DateTime.now();
    final code = Random.secure().nextInt(9000) + 1000;
    return 'HU-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-$code';
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_passportImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى رفع صورة الجواز')),
      );
      return;
    }

    final auth = context.read<AuthService>();
    if (!auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تسجيل الدخول لإتمام الحجز')),
      );
      context.go('/login');
      return;
    }

    final service = context.read<HajjUmrahService>();
    final appState = context.read<AppState>();
    final tripsService = context.read<MyTripsService>();
    final router = GoRouter.of(context);
    final pkg = service.packages
        .where((item) => item.id == widget.packageId)
        .cast<HajjUmrahPackage?>()
        .firstWhere((item) => item != null, orElse: () => null);
    if (pkg == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر العثور على الباقة')),
      );
      return;
    }

    final companions = int.tryParse(_companionsController.text.trim()) ?? 0;
    final totalSeats = 1 + companions;
    final remaining = service.remainingSeats(pkg.id);
    if (totalSeats > remaining) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('سيتم إدراج طلبك في قائمة الانتظار')),
      );
    }

    setState(() => _submitting = true);
    final verified = await _verifySecurityBeforeConfirm();
    if (!verified) {
      if (mounted) setState(() => _submitting = false);
      return;
    }

    final now = DateTime.now();
    final appId = _generateApplicationId();
    final application = HajjUmrahApplication(
      id: appId,
      packageId: pkg.id,
      userName: auth.username ?? 'غير معروف',
      age: int.tryParse(_ageController.text.trim()) ?? 0,
      phone: _phoneController.text.trim(),
      companions: companions,
      passportImagePath: _passportImage!.path,
      visaType: _visaController.text.trim(),
      status: HajjUmrahApplicationStatus.pending,
      createdAt: now,
      updatedAt: now,
    );

    await service.addApplication(application);

    final enriched = service.applications.firstWhere(
      (item) => item.id == application.id,
      orElse: () => application,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    final totalPrice = pkg.priceSar * totalSeats;
    appState.addBusBooking(
          BookingRecord(
            ticketId: appId,
            company: pkg.name,
            date: now,
            status: 'قيد المراجعة',
            amountSar: totalPrice,
            userName: auth.username ?? 'غير معروف',
          ),
        );
    tripsService.add(
          BookedTrip(
            id: appId,
            title: pkg.name,
            location: pkg.hotelName,
            imageUrl:
                'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80',
            priceLabel: '${totalPrice.toStringAsFixed(0)} ر.س',
            status: BookedTripStatus.upcoming,
            bookedAt: now,
          ),
        );

    router.go('/hajj-umrah/confirmation', extra: {
      'package': pkg,
      'application': enriched,
      'totalPrice': totalPrice,
    });
  }

  @override
  Widget build(BuildContext context) {
    _prefill();
    final service = context.watch<HajjUmrahService>();
    final pkg = service.packages
        .where((item) => item.id == widget.packageId)
        .cast<HajjUmrahPackage?>()
        .firstWhere((item) => item != null, orElse: () => null);

    if (pkg == null) {
      return Scaffold(
        appBar: const BrandedAppBar(title: 'حجز الباقة'),
        body: const Center(child: Text('تعذر العثور على الباقة')),
      );
    }

    return Scaffold(
      appBar: const BrandedAppBar(title: 'تسجيل الحجز'),
      body: SafeArea(
        child: ResponsiveContainer(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pkg.name,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Text('السعر: ${pkg.priceSar.toStringAsFixed(0)} ر.س'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'الاسم الكامل'),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'العمر'),
                        validator: (v) {
                          final value = int.tryParse(v ?? '');
                          if (value == null || value < 1) return 'مطلوب';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _companionsController,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'المرافقون (اختياري)'),
                        validator: (v) {
                          final value = int.tryParse(v ?? '0');
                          if (value == null || value < 0) return 'غير صالح';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _visaController,
                        decoration: const InputDecoration(labelText: 'نوع التأشيرة'),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 16),
                      Text('صورة الجواز',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 8),
                      if (_passportImage != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _passportImage!,
                            height: 160,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Container(
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: const Center(child: Text('لم يتم رفع صورة')),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickPassportImage(ImageSource.camera),
                              icon: const Icon(Icons.photo_camera_outlined),
                              label: const Text('التقاط'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _pickPassportImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library_outlined),
                              label: const Text('المعرض'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _submitting ? null : _submit,
                        child:
                            Text(_submitting ? 'جارٍ الإرسال...' : 'تأكيد الحجز'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
