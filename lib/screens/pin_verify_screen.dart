import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/security_service.dart';
import '../widgets/branded_app_bar.dart';
import '../widgets/responsive_container.dart';

class PinVerifyScreen extends StatefulWidget {
  const PinVerifyScreen({super.key});

  @override
  State<PinVerifyScreen> createState() => _PinVerifyScreenState();
}

class _PinVerifyScreenState extends State<PinVerifyScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _submitting = false;
  bool? _hasPin;

  @override
  void initState() {
    super.initState();
    final security = context.read<SecurityService>();
    Future.microtask(() async {
      final hasPin = await security.isPinSet();
      if (!mounted) return;
      setState(() => _hasPin = hasPin);
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final pin = _pinController.text.trim();
    if (pin.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال رقم PIN من 4 أرقام')),
      );
      return;
    }
    setState(() => _submitting = true);
    final security = context.read<SecurityService>();
    final ok = await security.verifyPin(pin);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رمز PIN غير صحيح')),
      );
      return;
    }
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final hasPin = _hasPin;

    return Scaffold(
      appBar: const BrandedAppBar(title: 'التحقق من PIN'),
      body: SafeArea(
        child: ResponsiveContainer(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: hasPin == null
                  ? const CircularProgressIndicator()
                  : hasPin
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'أدخل رمز PIN لتأكيد الحجز',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _pinController,
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              maxLength: 4,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: const InputDecoration(
                                counterText: '',
                                hintText: '••••',
                              ),
                              onSubmitted: (_) => _submitting ? null : _verify(),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _submitting ? null : _verify,
                              child: Text(_submitting ? 'جارٍ التحقق...' : 'تأكيد'),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.lock_outline, size: 48),
                            const SizedBox(height: 12),
                            const Text('لم يتم إعداد رمز PIN بعد'),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {
                                context.go('/settings');
                              },
                              child: const Text('إعداد PIN الآن'),
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
