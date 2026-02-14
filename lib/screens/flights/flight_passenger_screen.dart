import 'package:flutter/material.dart';
import '../../data/models/flight_model.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/responsive_container.dart';

class FlightPassengerScreen extends StatelessWidget {
  final FlightOption flight;

  const FlightPassengerScreen({super.key, required this.flight});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandedAppBar(title: 'بيانات المسافر'),
      body: SafeArea(
        child: ResponsiveContainer(
          child: Center(
            child: Text(
              'تم اختيار رحلة ${flight.airline} ${flight.fromCity} → ${flight.toCity}',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
