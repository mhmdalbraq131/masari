import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../logic/bus_booking_controller.dart';
import '../../models/bus_model.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/responsive_container.dart';

class BusResultsScreen extends StatefulWidget {
  const BusResultsScreen({super.key});

  @override
  State<BusResultsScreen> createState() => _BusResultsScreenState();
}

class _BusResultsScreenState extends State<BusResultsScreen> {
  late RangeValues _priceRange;
  bool _sortAscending = true;
  String _selectedSort = 'price'; // 'price', 'time'

  @override
  void initState() {
    super.initState();
    final controller = context.read<BusBookingController>();
    final prices = controller.searchResults.map((e) => e.priceSAR).toList();
    final bounds = _priceBounds(prices);
    final min = bounds.start;
    final max = bounds.end;
    _priceRange = RangeValues(min, max);
  }

  RangeValues _priceBounds(List<double> prices) {
    if (prices.isEmpty) return const RangeValues(0, 1);
    final min = prices.reduce((a, b) => a < b ? a : b);
    var max = prices.reduce((a, b) => a > b ? a : b);
    if (min == max) max = min + 1;
    return RangeValues(min, max);
  }

  RangeValues _effectiveRange(List<double> prices) {
    final bounds = _priceBounds(prices);
    final min = bounds.start;
    final max = bounds.end;
    final start = _priceRange.start.clamp(min, max).toDouble();
    final end = _priceRange.end.clamp(min, max).toDouble();
    if (start == end) return RangeValues(start, max);
    return RangeValues(start, end);
  }

  List<BusTrip> _filteredAndSortedResults(RangeValues range) {
    final controller = context.read<BusBookingController>();
    final filtered = controller.searchResults.where((trip) {
      return trip.priceSAR >= range.start && trip.priceSAR <= range.end;
    }).toList();

    filtered.sort((a, b) {
      if (_selectedSort == 'price') {
        return _sortAscending
            ? a.priceSAR.compareTo(b.priceSAR)
            : b.priceSAR.compareTo(a.priceSAR);
      } else if (_selectedSort == 'time') {
        final timeA = _parseTime(a.departureTime);
        final timeB = _parseTime(b.departureTime);
        return _sortAscending ? timeA.compareTo(timeB) : timeB.compareTo(timeA);
      }
      return 0;
    });

    return filtered;
  }

  int _parseTime(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return 0;
    return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandedAppBar(title: 'الرحلات المتاحة'),
      body: Consumer<BusBookingController>(
        builder: (context, controller, _) {
          final prices = controller.searchResults.map((e) => e.priceSAR).toList();
          final bounds = _priceBounds(prices);
          final range = _effectiveRange(prices);
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.hasError && controller.searchResults.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_bus_filled_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage ?? 'لا توجد رحلات متاحة',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('العودة'),
                  ),
                ],
              ),
            );
          }

          final results = _filteredAndSortedResults(range);

          return ResponsiveContainer(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Filters Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Price Filter
                        Text(
                          'التصفية حسب السعر (ر.س)',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        RangeSlider(
                          values: range,
                          min: bounds.start,
                          max: bounds.end,
                          divisions: 10,
                          labels: RangeLabels(
                            range.start.toStringAsFixed(0),
                            range.end.toStringAsFixed(0),
                          ),
                          onChanged: (values) {
                            setState(() => _priceRange = values);
                          },
                        ),
                        const SizedBox(height: 12),

                        // Sort Options
                        Text(
                          'الترتيب',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: SegmentedButton<String>(
                                segments: const <ButtonSegment<String>>[
                                  ButtonSegment<String>(
                                    value: 'price',
                                    label: Text('السعر'),
                                  ),
                                  ButtonSegment<String>(
                                    value: 'time',
                                    label: Text('الوقت'),
                                  ),
                                ],
                                selected: <String>{_selectedSort},
                                onSelectionChanged: (Set<String> newSelection) {
                                  setState(() => _selectedSort = newSelection.first);
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(
                                _sortAscending
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                              ),
                              onPressed: () {
                                setState(() => _sortAscending = !_sortAscending);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Results Count
                if (results.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      'تم العثور على ${results.length} رحلة',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ),
                const SizedBox(height: 12),

                // Results List
                if (results.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        'لا توجد رحلات ضمن هذا النطاق',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  )
                else
                  ...results.map((trip) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _BusTripCard(
                        trip: trip,
                        onSelect: () {
                          controller.selectTrip(trip);
                          context.push('/bus-passenger');
                        },
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BusTripCard extends StatelessWidget {
  final BusTrip trip;
  final VoidCallback onSelect;

  const _BusTripCard({
    required this.trip,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onSelect,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Company and Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    trip.company,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Chip(
                    label: Text(trip.busType),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Route
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'من',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        Text(
                          trip.fromCity,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward,
                    color: Colors.grey[400],
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'إلى',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        Text(
                          trip.toCity,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Times and Details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        trip.departureTime,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        'الانطلاق',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        trip.arrivalTime,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        'الوصول',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Seats and Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'المقاعد المتاحة',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              '${trip.availableSeats}',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: trip.isLowSeats
                                        ? Colors.orange
                                        : Colors.green,
                                  ),
                            ),
                            const SizedBox(width: 4),
                            if (trip.isLowSeats)
                              const Tooltip(
                                message: 'مقاعد قليلة',
                                child: Icon(
                                  Icons.warning_amber_rounded,
                                  size: 16,
                                  color: Colors.orange,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'السعر',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        const SizedBox(height: 2),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${trip.priceSAR.toStringAsFixed(0)} ر.س',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                            Text(
                              '${trip.priceYER.toStringAsFixed(0)} ر.ي',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Amenities
              if (trip.amenities.isNotEmpty)
                Wrap(
                  spacing: 6,
                  children: trip.amenities
                      .map((amenity) => Chip(
                            label: Text(amenity),
                            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                            backgroundColor:
                              Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          ))
                      .toList(),
                ),
              const SizedBox(height: 12),

              // Select Button
              ElevatedButton(
                onPressed: onSelect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: const Text('اختيار'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
