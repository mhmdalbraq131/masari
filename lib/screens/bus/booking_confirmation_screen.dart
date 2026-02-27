import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../data/models/booking_record.dart';
import '../../logic/app_state.dart';
import '../../logic/bus_booking_controller.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/responsive_container.dart';

class BookingConfirmationScreen extends StatefulWidget {
  const BookingConfirmationScreen({super.key});

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen>
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

  void _newBooking() {
    context.read<BusBookingController>().resetBooking();
    context.goNamed('bus-companies');
  }

  void _goHome() {
    context.goNamed('home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandedAppBar(title: 'تأكيد الحجز'),
      body: Consumer<BusBookingController>(
        builder: (context, controller, _) {
          final booking = controller.currentBooking;

          if (booking != null && !_recorded) {
            _recorded = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              context.read<AppState>().addBusBooking(
                BookingRecord(
                  ticketId: booking.id,
                  company: booking.trip.company,
                  date: booking.bookingDate,
                  status: booking.status,
                  amountSar: booking.trip.priceSAR,
                  userName: booking.passenger.fullName,
                ),
              );
            });
          }

          if (booking == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  const Text('لم يتم العثور على بيانات الحجز'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _goHome,
                    child: const Text('العودة للرئيسية'),
                  ),
                ],
              ),
            );
          }

          return ResponsiveContainer(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: FadeTransition(
                opacity: _fade,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Success Icon Animation
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
                            'تم تأكيد الحجز بنجاح!',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.green,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Confirmation Number
                    Card(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.05),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              'رقم التأكيد',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            SelectableText(
                              booking.confirmationNumber ?? 'N/A',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    letterSpacing: 1.5,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'احفظ هذا الرقم للمراجعة',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Trip Details
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تفاصيل الرحلة',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              context,
                              'الشركة',
                              booking.trip.company,
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              context,
                              'المسار',
                              '${booking.trip.fromCity} → ${booking.trip.toCity}',
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              context,
                              'التاريخ',
                              booking.trip.date.toString().split(' ')[0],
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              context,
                              'الانطلاق',
                              booking.trip.departureTime,
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              context,
                              'الوصول',
                              booking.trip.arrivalTime,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Passenger Details
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'بيانات الراكب',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 12),
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              context,
                              'الاسم',
                              booking.passenger.fullName,
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              context,
                              'الهاتف',
                              booking.passenger.phone,
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              context,
                              'سبب السفر',
                              booking.passenger.reasonForTravel,
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              context,
                              'التأشيرة',
                              booking.passenger.visaType,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Total Price
                    Card(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.05),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'السعر الإجمالي',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      '${booking.trip.priceSAR.toStringAsFixed(0)} ر.س',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          ),
                                    ),
                                    Text(
                                      'ريال سعودي',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelSmall,
                                    ),
                                  ],
                                ),
                                const Divider(height: 50, indent: 10),
                                Column(
                                  children: [
                                    Text(
                                      '${booking.trip.priceYER.toStringAsFixed(0)} ر.ي',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                          ),
                                    ),
                                    Text(
                                      'ريال يمني',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelSmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    ElevatedButton.icon(
                      onPressed: _newBooking,
                      icon: const Icon(Icons.add),
                      label: const Text('حجز رحلة أخرى'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _goHome,
                      icon: const Icon(Icons.home),
                      label: const Text('العودة للرئيسية'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          textAlign: TextAlign.start,
        ),
      ],
    );
  }
}
