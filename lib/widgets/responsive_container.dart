import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final bool showWatermark;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 520,
    this.showWatermark = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    );

    if (!showWatermark) {
      return Center(child: content);
    }

    return Center(
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: Align(
                alignment: Alignment.center,
                child: Opacity(
                  opacity: 0.05,
                  child: Image.asset(
                    'assets/logo/masari_logo.png',
                    width: 260,
                    fit: BoxFit.contain,
                    color: AppColors.textPrimary,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),
          content,
        ],
      ),
    );
  }
}
