import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_service.dart';
import '../../data/models/booked_trip_model.dart';
import '../../data/models/booking_record.dart';
import '../../data/models/flight_model.dart';
import '../../logic/app_state.dart';
import '../../logic/mytrips_service.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/responsive_container.dart';

class FlightConfirmationScreen extends StatefulWidget {
  final FlightBookingData booking;

  const FlightConfirmationScreen({super.key, required this.booking});

  @override
  State<FlightConfirmationScreen> createState() =>
      _FlightConfirmationScreenState();
}

class _FlightConfirmationScreenState extends State<FlightConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  bool _recorded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _scale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _recordBookingOnce(BuildContext context) {
    if (_recorded) return;
    _recorded = true;
    final auth = context.read<AuthService>();
    final booking = widget.booking;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AppState>().addBusBooking(
            BookingRecord(
              ticketId: booking.confirmationNumber,
              company: booking.selection.flight.airline,
              date: booking.bookedAt,
              status: 'مؤكدة',
              amountSar: booking.totalPriceSar,
              userName: auth.username ?? 'غير معروف',
            ),
          );
      context.read<MyTripsService>().add(
            BookedTrip(
              id: booking.confirmationNumber,
              title:
                  'طيران ${booking.selection.flight.fromCity} → ${booking.selection.flight.toCity}',
              location: booking.selection.flight.airline,
              imageUrl:
                  'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=1200&q=80',
              priceLabel:
                  '${booking.totalPriceSar.toStringAsFixed(0)} ر.س',
              status: BookedTripStatus.upcoming,
              bookedAt: booking.bookedAt,
            ),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    _recordBookingOnce(context);
    final booking = widget.booking;
    final flight = booking.selection.flight;
    final criteria = booking.selection.criteria;

    return Scaffold(
      appBar: const BrandedAppBar(title: 'تأكيد حجز الطيران'),
      body: SafeArea(
        child: ResponsiveContainer(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: FadeTransition(
              opacity: _fade,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ScaleTransition(
                    scale: _scale,
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green.withValues(alpha: 0.1),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.check_circle,
                              size: 60,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'تم تأكيد حجز الطيران بنجاح!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.green,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    color:
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'رقم التأكيد',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            booking.confirmationNumber,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.primary,
                                  letterSpacing: 1.5,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'احتفظ بهذا الرقم للرجوع إليه',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تفاصيل الرحلة',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          _buildDetailRow('شركة الطيران', flight.airline),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            'المسار',
                            '${flight.fromCity} → ${flight.toCity}',
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            'تاريخ السفر',
                            _formatDate(criteria.departureDate),
                          ),
                          if (criteria.returnDate != null) ...[
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              'تاريخ العودة',
                              _formatDate(criteria.returnDate!),
                            ),
                          ],
                          const SizedBox(height: 12),
                          _buildDetailRow('الإقلاع', flight.departTime),
                          const SizedBox(height: 12),
                          _buildDetailRow('الوصول', flight.arriveTime),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'بيانات المسافر',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          _buildDetailRow('الاسم', booking.passengerName),
                          const SizedBox(height: 12),
                          _buildDetailRow('الهاتف', booking.passengerPhone),
                          const SizedBox(height: 12),
                          _buildDetailRow('البريد', booking.passengerEmail),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ملخص الدفع',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            'عدد الركاب',
                            criteria.passengers.toString(),
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            'إجمالي المبلغ',
                            '${booking.totalPriceSar.toStringAsFixed(0)} ر.س',
                          ),
                        ],
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

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
