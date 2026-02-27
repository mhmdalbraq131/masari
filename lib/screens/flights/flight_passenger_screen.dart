import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_service.dart';
import '../../data/models/flight_model.dart';
import '../../services/security_service.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/responsive_container.dart';

class FlightPassengerScreen extends StatefulWidget {
  final FlightSelection selection;

  const FlightPassengerScreen({super.key, required this.selection});

  @override
  State<FlightPassengerScreen> createState() => _FlightPassengerScreenState();
}

class _FlightPassengerScreenState extends State<FlightPassengerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
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

  bool _hasSeats() {
    return widget.selection.flight.seatsAvailable >=
        widget.selection.criteria.passengers;
  }

  String _generateConfirmationNumber() {
    final now = DateTime.now();
    final code = Random.secure().nextInt(9000) + 1000;
    return 'FLT-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-$code';
  }

  Future<void> _confirmBooking() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_hasSeats()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد مقاعد كافية لهذه الرحلة')),
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

    setState(() => _submitting = true);
    final verified = await _verifySecurityBeforeConfirm();
    if (!verified) {
      if (mounted) setState(() => _submitting = false);
      return;
    }

    final selection = widget.selection;
    final totalPrice =
        selection.flight.priceSAR * selection.criteria.passengers;
    final booking = FlightBookingData(
      selection: selection,
      passengerName: _nameController.text.trim(),
      passengerPhone: _phoneController.text.trim(),
      passengerEmail: _emailController.text.trim(),
      confirmationNumber: _generateConfirmationNumber(),
      bookedAt: DateTime.now(),
      totalPriceSar: totalPrice,
    );

    if (!mounted) return;
    setState(() => _submitting = false);
    context.go('/flight-confirmation', extra: booking);
  }

  @override
  Widget build(BuildContext context) {
    final selection = widget.selection;
    final flight = selection.flight;
    final criteria = selection.criteria;
    final canBook = _hasSeats();

    return Scaffold(
      appBar: const BrandedAppBar(title: 'بيانات المسافر'),
      body: SafeArea(
        child: ResponsiveContainer(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ملخص الرحلة',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text('${flight.fromCity} → ${flight.toCity}'),
                        const SizedBox(height: 4),
                        Text('${flight.airline} • ${flight.departTime}'),
                        const SizedBox(height: 4),
                        Text('عدد الركاب: ${criteria.passengers}'),
                        const SizedBox(height: 4),
                        Text('المقاعد المتاحة: ${flight.seatsAvailable}'),
                        if (!canBook) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'لا توجد مقاعد كافية لهذه الرحلة',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ],
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
                        decoration: const InputDecoration(
                          labelText: 'الاسم الكامل',
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'رقم الهاتف',
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'البريد الإلكتروني',
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed:
                            _submitting || !canBook ? null : _confirmBooking,
                        child: Text(
                          _submitting ? 'جارٍ التأكيد...' : 'تأكيد الحجز',
                        ),
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
