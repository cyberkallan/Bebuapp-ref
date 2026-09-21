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
      child: LayoutBuilder(
        builder: (context, box) {
          const gap = 12.0;
          final cols = box.maxWidth >= 560 ? 3 : 2;
          final w = (box.maxWidth - gap * (cols - 1)) / cols;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (var i = 0; i < 4; i++)
                Container(
                  width: w,
                  height: 158,
                  decoration: BoxDecoration(color: BebuTheme.surface, borderRadius: BorderRadius.circular(BebuTheme.radiusLg)),
                ),
            ],
          );
        },
      ),
    );
  }
}
