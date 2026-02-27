import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/utils/input_sanitizer.dart';
import '../data/models/booked_trip_model.dart';
import '../logic/mytrips_service.dart';
import '../services/security_service.dart';
import '../widgets/branded_app_bar.dart';
import '../widgets/responsive_container.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _travelersController = TextEditingController(text: '1');
  bool _loading = false;
  int _currentStep = 0;
  DateTime? _date;
  String _seatClass = 'اقتصادية';
  String _roomType = 'قياسية';

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _travelersController.dispose();
    super.dispose();
  }

  bool _validateCurrentStep() {
    if (_currentStep == 0) {
      return _formKey.currentState?.validate() ?? false;
    }
    if (_currentStep == 2 && _date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار تاريخ السفر')),
      );
      return false;
    }
    return true;
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

  Future<void> _confirmBooking() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    context.read<MyTripsService>().add(
          BookedTrip(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'حجز جديد',
            location: _date == null ? 'غير محدد' : 'تاريخ ${_formatDate(_date!)}',
            imageUrl: 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=1200&q=80',
            priceLabel: 'يتم التأكيد',
            status: BookedTripStatus.upcoming,
            bookedAt: DateTime.now(),
          ),
        );
    setState(() => _loading = false);
    setState(() => _currentStep = 4);
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: const BrandedAppBar(title: 'الحجز'),
          bottomNavigationBar: null,
          body: ResponsiveContainer(
            child: Stepper(
              type: StepperType.vertical,
              currentStep: _currentStep,
              onStepContinue: _loading
                  ? null
                  : () async {
                      if (!_validateCurrentStep()) return;
                      if (_currentStep == 3) {
                        final verified = await _verifySecurityBeforeConfirm();
                        if (!verified) return;
                        await _confirmBooking();
                        return;
                      }
                      if (_currentStep < 4) {
                        setState(() => _currentStep += 1);
                      }
                    },
              onStepCancel: _loading
                  ? null
                  : () {
                      if (_currentStep > 0) {
                        setState(() => _currentStep -= 1);
                      }
                    },
              controlsBuilder: (context, details) {
                if (_currentStep == 4) return const SizedBox.shrink();
                final isLast = _currentStep == 3;
                return Row(
                  children: [
                    ElevatedButton(
                      onPressed: details.onStepContinue,
                      child: Text(isLast ? 'تأكيد الحجز' : 'التالي'),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('السابق'),
                    ),
                  ],
                );
              },
              steps: [
                Step(
                  title: const Text('بيانات المسافر'),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                  content: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('الاسم الكامل'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(hintText: 'اكتب الاسم هنا'),
                          validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                        ),
                        const SizedBox(height: 12),
                        const Text('رقم الهاتف'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(hintText: '05xxxxxxxx'),
                          validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                        ),
                        const SizedBox(height: 12),
                        const Text('عدد المسافرين'),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _travelersController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: 'مثال: 2'),
                          validator: (v) => (v == null || v.isEmpty) ? 'مطلوب' : null,
                        ),
                      ],
                    ),
                  ),
                ),
                Step(
                  title: const Text('اختيار المقعد/الغرفة'),
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('درجة المقعد'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ['اقتصادية', 'أعمال', 'أولى']
                            .map(
                              (seat) => ChoiceChip(
                                label: Text(seat),
                                selected: _seatClass == seat,
                                onSelected: (_) => setState(() => _seatClass = seat),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      const Text('نوع الغرفة'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ['قياسية', 'ديلوكس', 'جناح']
                            .map(
                              (room) => ChoiceChip(
                                label: Text(room),
                                selected: _roomType == room,
                                onSelected: (_) => setState(() => _roomType = room),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
                Step(
                  title: const Text('تحديد التاريخ'),
                  isActive: _currentStep >= 2,
                  state: _currentStep > 2 ? StepState.complete : StepState.indexed,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('تاريخ السفر'),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _date == null ? 'اختر التاريخ' : _formatDate(_date!),
                              ),
                              const Icon(Icons.calendar_month),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Step(
                  title: const Text('ملخص الحجز'),
                  isActive: _currentStep >= 3,
                  state: _currentStep > 3 ? StepState.complete : StepState.indexed,
                  content: _SummaryCard(
                    name: InputSanitizer.cleanText(_nameController.text),
                    phone: InputSanitizer.cleanPhone(_phoneController.text),
                    travelers: InputSanitizer.cleanNumber(_travelersController.text),
                    date: _date,
                    seatClass: _seatClass,
                    roomType: _roomType,
                  ),
                ),
                Step(
                  title: const Text('تم التأكيد'),
                  isActive: _currentStep >= 4,
                  state: _currentStep >= 4 ? StepState.complete : StepState.indexed,
                  content: _ConfirmationCard(
                    onViewTrips: () => context.go('/mytrips'),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_loading)
          Container(
            color: Colors.black45,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String name;
  final String phone;
  final String travelers;
  final DateTime? date;
  final String seatClass;
  final String roomType;

  const _SummaryCard({
    required this.name,
    required this.phone,
    required this.travelers,
    required this.date,
    required this.seatClass,
    required this.roomType,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('تفاصيل الحجز', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _SummaryRow(label: 'الاسم', value: name.isEmpty ? '-' : name),
            _SummaryRow(label: 'الهاتف', value: phone.isEmpty ? '-' : phone),
            _SummaryRow(label: 'المسافرون', value: travelers.isEmpty ? '-' : travelers),
            _SummaryRow(label: 'التاريخ', value: date == null ? '-' : _formatDate(date!)),
            _SummaryRow(label: 'درجة المقعد', value: seatClass),
            _SummaryRow(label: 'نوع الغرفة', value: roomType),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _ConfirmationCard extends StatelessWidget {
  final VoidCallback onViewTrips;

  const _ConfirmationCard({required this.onViewTrips});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 12),
            Text(
              'تم تأكيد الحجز بنجاح',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'ستصلك رسالة بالتفاصيل خلال دقائق.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onViewTrips,
              child: const Text('عرض رحلاتي'),
            ),
          ],
        ),
      ),
    );
  }
}
