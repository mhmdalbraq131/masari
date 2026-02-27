import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../logic/bus_booking_controller.dart';
import '../../logic/location_service.dart';
import '../../models/bus_model.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/responsive_container.dart';

class BusSearchScreen extends StatefulWidget {
  const BusSearchScreen({super.key});

  @override
  State<BusSearchScreen> createState() => _BusSearchScreenState();
}

class _BusSearchScreenState extends State<BusSearchScreen> {
  late GlobalKey<FormState> _formKey;
  late TextEditingController _passengersController;
  late TextEditingController _dateController;
  String? _fromCity;
  String? _toCity;
  DateTime? _travelDate;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _passengersController = TextEditingController(text: '1');
    _dateController = TextEditingController();
  }

  @override
  void dispose() {
    _passengersController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      locale: const Locale('ar'),
    );
    if (picked != null && mounted) {
      setState(() {
        _travelDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _search() async {
    if (!(_formKey.currentState?.validate() ?? false) || _travelDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى ملء جميع الحقول المطلوبة'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final controller = context.read<BusBookingController>();
    final selectedCompany = controller.selectedCompany;

    if (selectedCompany == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار شركة باصات'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final fromCity = _fromCity?.trim().isEmpty ?? true
        ? BusConstants.saudiCities.first
        : _fromCity!.trim();
    final toCity = _toCity?.trim().isEmpty ?? true
        ? BusConstants.saudiCities[1]
        : _toCity!.trim();

    final request = BusSearchRequest(
      fromCity: fromCity,
      toCity: toCity,
      date: _travelDate!,
      passengerCount: int.tryParse(_passengersController.text) ?? 1,
      selectedCompanyId: selectedCompany.id,
    );

    await controller.searchTrips(request);

    if (!mounted) return;

    if (controller.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? 'حدث خطأ'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      context.push('/bus-results');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BusBookingController>();
    final selectedCompany = controller.selectedCompany;

    return Scaffold(
      appBar: const BrandedAppBar(title: 'البحث عن رحلات'),
      body: SafeArea(
        child: ResponsiveContainer(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Selected Company Card
                  if (selectedCompany != null)
                    Card(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  selectedCompany.arabicName.isNotEmpty
                                      ? selectedCompany.arabicName[0]
                                      : '؟',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'الشركة المختارة',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    selectedCompany.arabicName,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // From City
                  _buildLocationAutocomplete(
                    label: 'من المدينة (اختياري)',
                    value: _fromCity,
                    onChanged: (value) => setState(() => _fromCity = value),
                  ),
                  const SizedBox(height: 16),

                  // To City
                  _buildLocationAutocomplete(
                    label: 'إلى المدينة (اختياري)',
                    value: _toCity,
                    onChanged: (value) => setState(() => _toCity = value),
                  ),
                  const SizedBox(height: 16),

                  // Travel Date
                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'تاريخ السفر',
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                    onTap: _pickDate,
                    validator: (value) {
                      if (_travelDate == null) {
                        return 'اختر التاريخ';
                      }
                      return null;
                    },
                    controller: _dateController,
                  ),
                  const SizedBox(height: 16),

                  // Passengers Count
                  TextFormField(
                    controller: _passengersController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'عدد الركاب',
                      prefixIcon: const Icon(Icons.person),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'أدخل عدد الركاب';
                      }
                      final count = int.tryParse(value);
                      if (count == null || count < 1) {
                        return 'أدخل عدداً صحيحاً';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Search Button
                  ElevatedButton.icon(
                    onPressed: controller.isLoading ? null : _search,
                    icon: controller.isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : const Icon(Icons.search),
                    label: Text(controller.isLoading ? 'جاري البحث...' : 'بحث عن رحلات'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationAutocomplete({
    required String label,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    final locations = context.watch<LocationService>().locations;
    final options = locations.map((e) => e.name).toList();

    return Autocomplete<String>(
      initialValue: TextEditingValue(text: value ?? ''),
      optionsBuilder: (text) {
        final query = text.text.trim();
        if (query.isEmpty) return options;
        return options.where((item) => item.contains(query));
      },
      onSelected: (selection) => onChanged(selection),
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.location_on),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
          onChanged: (value) => onChanged(value.trim().isEmpty ? null : value),
        );
      },
    );
  }
}
