import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

class LoadingShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const LoadingShimmer({
    super.key,
    this.width = double.infinity,
    this.height = 20.0,
    this.borderRadius = AppDimensions.radiusSmall,
  });

  factory LoadingShimmer.card({double height = 120.0}) {
    return LoadingShimmer(
      height: height,
      borderRadius: AppDimensions.radiusLarge,
    );
  }

  factory LoadingShimmer.listTile() {
    return const LoadingShimmer(
      height: 64.0,
      borderRadius: AppDimensions.radiusMedium,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.surface,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
