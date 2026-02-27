import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/flight_model.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/responsive_container.dart';

class FlightResultsScreen extends StatefulWidget {
  final FlightSearchCriteria criteria;
  final List<FlightOption> results;

  const FlightResultsScreen({super.key, required this.criteria, required this.results});

  @override
  State<FlightResultsScreen> createState() => _FlightResultsScreenState();
}

class _FlightResultsScreenState extends State<FlightResultsScreen> {
  FlightSort _sort = FlightSort.price;
  late List<FlightOption> _sortedResults;

  @override
  void initState() {
    super.initState();
    _computeSorted();
  }

  @override
  void didUpdateWidget(covariant FlightResultsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.results != widget.results) {
      _computeSorted();
    }
  }

  void _computeSorted() {
    final items = [...widget.results];
    if (_sort == FlightSort.price) {
      items.sort((a, b) => a.priceSAR.compareTo(b.priceSAR));
    } else {
      items.sort((a, b) => a.departTime.compareTo(b.departTime));
    }
    _sortedResults = items;
  }

  String _durationLabel(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '$hس $mد';
  }

  String _stopLabel(int stops) {
    return stops == 0 ? 'مباشر' : 'توقف $stops';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandedAppBar(title: 'الرحلات المتاحة'),
      body: SafeArea(
        child: ResponsiveContainer(
          child: widget.results.isEmpty
              ? _EmptyState(from: widget.criteria.fromCity, to: widget.criteria.toCity)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: 4 + _sortedResults.length,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _Header(
                        from: widget.criteria.fromCity,
                        to: widget.criteria.toCity,
                        passengers: widget.criteria.passengers,
                        travelClass: widget.criteria.travelClass,
                      );
                    }
                    if (index == 1) return const SizedBox(height: 12);
                    if (index == 2) {
                      return _SortBar(
                        value: _sort,
                        onChanged: (value) => setState(() {
                          _sort = value;
                          _computeSorted();
                        }),
                      );
                    }
                    if (index == 3) return const SizedBox(height: 12);

                    final flight = _sortedResults[index - 4];
                    return _FlightCard(
                      flight: flight,
                      durationLabel: _durationLabel(flight.durationMinutes),
                      stopLabel: _stopLabel(flight.stops),
                      canBook: flight.seatsAvailable >= widget.criteria.passengers,
                      onSelect: () => context.push(
                        '/flight-passengers',
                        extra: FlightSelection(
                          criteria: widget.criteria,
                          flight: flight,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String from;
  final String to;
  final int passengers;
  final TravelClass travelClass;

  const _Header({
    required this.from,
    required this.to,
    required this.passengers,
    required this.travelClass,
  });

  String _classLabel() {
    return travelClass == TravelClass.business ? 'رجال أعمال' : 'اقتصادي';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(Icons.flight_takeoff, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$from → $to', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('عدد المسافرين: $passengers • ${_classLabel()}',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SortBar extends StatelessWidget {
  final FlightSort value;
  final ValueChanged<FlightSort> onChanged;

  const _SortBar({required this.value, required this.onChanged});

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
          const Text('الترتيب'),
          const Spacer(),
          ChoiceChip(
            label: const Text('السعر'),
            selected: value == FlightSort.price,
            onSelected: (_) => onChanged(FlightSort.price),
            selectedColor: AppColors.primary.withValues(alpha: 0.2),
            labelStyle: TextStyle(
              color: value == FlightSort.price ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('الوقت'),
            selected: value == FlightSort.time,
            onSelected: (_) => onChanged(FlightSort.time),
            selectedColor: AppColors.primary.withValues(alpha: 0.2),
            labelStyle: TextStyle(
              color: value == FlightSort.time ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlightCard extends StatelessWidget {
  final FlightOption flight;
  final String durationLabel;
  final String stopLabel;
  final VoidCallback onSelect;
  final bool canBook;

  const _FlightCard({
    required this.flight,
    required this.durationLabel,
    required this.stopLabel,
    required this.onSelect,
    required this.canBook,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(flight.airline, style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                _Tag(label: stopLabel),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _TimeBlock(label: 'الإقلاع', value: flight.departTime),
                const SizedBox(width: 16),
                _TimeBlock(label: 'الوصول', value: flight.arriveTime),
                const Spacer(),
                _Tag(label: durationLabel),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text('المقاعد المتاحة: ${flight.seatsAvailable}',
                      style: Theme.of(context).textTheme.bodySmall),
                ),
                if (!canBook)
                  Text(
                    'غير متاح',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.redAccent),
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${flight.priceYER.toStringAsFixed(0)} ر.ي',
                        style: Theme.of(context).textTheme.titleMedium),
                    Text('${flight.priceSAR.toStringAsFixed(0)} ر.س',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: canBook ? onSelect : null,
                child: const Text('اختيار الرحلة'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeBlock extends StatelessWidget {
  final String label;
  final String value;

  const _TimeBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;

  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String from;
  final String to;

  const _EmptyState({required this.from, required this.to});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.airplanemode_inactive, size: 72, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text('لا توجد رحلات متاحة', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text('لا توجد رحلات من $from إلى $to حالياً.',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
