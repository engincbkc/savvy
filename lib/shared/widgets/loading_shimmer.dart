import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';

/// Shimmer loading skeleton — NEVER use CircularProgressIndicator.
class SavvyShimmer extends StatelessWidget {
  final Widget child;

  const SavvyShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark
          ? AppColors.darkSurfaceElevated
          : AppColors.of(context).surfaceOverlay,
      highlightColor: isDark
          ? AppColors.darkSurfaceCard
          : AppColors.of(context).surfaceCard,
      child: child,
    );
  }
}

class ShimmerBox extends StatelessWidget {
  final double? height;
  final double? width;
  final double radius;

  const ShimmerBox({
    super.key,
    this.height,
    this.width,
    this.radius = AppRadius.lg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.of(context).surfaceCard,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
