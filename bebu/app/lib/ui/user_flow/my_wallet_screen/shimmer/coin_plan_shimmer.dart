import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talk_in/utils/app_theme.dart';

/// Placeholder grid matching [CoinPlanGrid] geometry.
class CoinPlanShimmer extends StatelessWidget {
  const CoinPlanShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: BebuTheme.surface,
      highlightColor: BebuTheme.surface3,
      child: Column(
        children: [
          for (var i = 0; i < 4; i++)
            Container(
              height: 92,
              margin: EdgeInsets.only(bottom: i == 3 ? 0 : 12),
              decoration: BoxDecoration(color: BebuTheme.surface, borderRadius: BorderRadius.circular(BebuTheme.radiusLg)),
            ),
        ],
      ),
    );
  }
}
