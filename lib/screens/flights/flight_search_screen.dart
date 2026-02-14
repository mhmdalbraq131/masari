import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/flight_model.dart';
import '../../services/flight_service.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/responsive_container.dart';

class FlightSearchScreen extends StatefulWidget {
  const FlightSearchScreen({super.key});

  @override
  State<FlightSearchScreen> createState() => _FlightSearchScreenState();
}

class _FlightSearchScreenState extends State<FlightSearchScreen> {
  final FlightService _service = FlightService();
  final List<String> _cities = const [
    'الرياض',
    'جدة',
    'الدمام',
    'المدينة',
    'أبها',
    'القاهرة',
    'دبي',
    'الدوحة',
  ];

  String? _fromCity;
  String? _toCity;
  DateTime? _departureDate;
  DateTime? _returnDate;
  int _passengers = 1;
  TravelClass _travelClass = TravelClass.economy;
  bool _loading = false;

  String _formatDate(DateTime? date) {
    if (date == null) return 'اختر التاريخ';
    return DateFormat('yyyy/MM/dd').format(date);
  }

  Future<void> _pickDate({required bool isReturn}) async {
    final initial = isReturn ? (_returnDate ?? _departureDate ?? DateTime.now()) : (_departureDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (isReturn) {
        _returnDate = picked;
      } else {
        _departureDate = picked;
        if (_returnDate != null && _returnDate!.isBefore(picked)) {
          _returnDate = null;
        }
      }
    });
  }

  Future<void> _search() async {
    if (_fromCity == null || _toCity == null || _departureDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تعبئة بيانات البحث')),
      );
      return;
    }
    setState(() => _loading = true);
    final criteria = FlightSearchCriteria(
      fromCity: _fromCity!,
      toCity: _toCity!,
      departureDate: _departureDate!,
      returnDate: _returnDate,
      passengers: _passengers,
      travelClass: _travelClass,
    );
    final results = await _service.searchFlights(criteria);
    if (!mounted) return;
    setState(() => _loading = false);
    context.go('/flight-results', extra: {
      'criteria': criteria,
      'results': results,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandedAppBar(title: 'البحث عن رحلة طيران'),
      body: SafeArea(
        child: ResponsiveContainer(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SectionTitle(title: 'بيانات الرحلة'),
              const SizedBox(height: 12),
              _DropdownField(
                label: 'من',
                value: _fromCity,
                items: _cities,
                onChanged: (value) => setState(() => _fromCity = value),
              ),
              const SizedBox(height: 12),
              _DropdownField(
                label: 'إلى',
                value: _toCity,
                items: _cities,
                onChanged: (value) => setState(() => _toCity = value),
              ),
              const SizedBox(height: 12),
              _DateField(
                label: 'تاريخ الذهاب',
                value: _formatDate(_departureDate),
                onTap: () => _pickDate(isReturn: false),
              ),
              const SizedBox(height: 12),
              _DateField(
                label: 'تاريخ العودة (اختياري)',
                value: _formatDate(_returnDate),
                onTap: () => _pickDate(isReturn: true),
              ),
              const SizedBox(height: 16),
              _SectionTitle(title: 'المسافرون'),
              const SizedBox(height: 12),
              _CounterField(
                label: 'عدد المسافرين',
                value: _passengers,
                onAdd: () => setState(() => _passengers += 1),
                onRemove: () => setState(() => _passengers = _passengers > 1 ? _passengers - 1 : 1),
              ),
              const SizedBox(height: 12),
              _ClassSelector(
                value: _travelClass,
                onChanged: (value) => setState(() => _travelClass = value),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loading ? null : _search,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : const Icon(Icons.search),
                label: Text(_loading ? 'جاري البحث...' : 'بحث'),
              ),
            ],
          ),
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
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.location_on_outlined),
      ),
      items: items.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
      onChanged: onChanged,
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.date_range_outlined),
        ),
        child: Text(value),
      ),
    );
  }
}

class _CounterField extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _CounterField({
    required this.label,
    required this.value,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          IconButton(onPressed: onRemove, icon: const Icon(Icons.remove_circle_outline)),
          Text('$value', style: Theme.of(context).textTheme.titleMedium),
          IconButton(onPressed: onAdd, icon: const Icon(Icons.add_circle_outline)),
        ],
      ),
    );
  }
}

class _ClassSelector extends StatelessWidget {
  final TravelClass value;
  final ValueChanged<TravelClass> onChanged;

  const _ClassSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          const Text('درجة السفر'),
          const Spacer(),
          ChoiceChip(
            label: const Text('اقتصادي'),
            selected: value == TravelClass.economy,
            onSelected: (_) => onChanged(TravelClass.economy),
            selectedColor: AppColors.primary.withOpacity(0.2),
            labelStyle: TextStyle(
              color: value == TravelClass.economy ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('رجال أعمال'),
            selected: value == TravelClass.business,
            onSelected: (_) => onChanged(TravelClass.business),
            selectedColor: AppColors.primary.withOpacity(0.2),
            labelStyle: TextStyle(
              color: value == TravelClass.business ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
