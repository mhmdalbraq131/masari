import 'package:flutter/material.dart';
import '../widgets/branded_app_bar.dart';
import '../widgets/responsive_container.dart';

class HotelsScreen extends StatelessWidget {
  const HotelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandedAppBar(title: 'الفنادق'),
      body: const SafeArea(
        child: ResponsiveContainer(
          child: Center(
            child: Text('شاشة الفنادق قيد التجهيز'),
          ),
        ),
      ),
    );
  }
}
