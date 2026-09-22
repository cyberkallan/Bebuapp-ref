import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talk_in/utils/app_color.dart';

class CoinShimmer extends StatelessWidget {
  const CoinShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.lightGrey1,
      highlightColor: AppColors.grey.withValues(alpha: 0.2),
      child: Container(
        height: 28,
        width: 50,
        decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
