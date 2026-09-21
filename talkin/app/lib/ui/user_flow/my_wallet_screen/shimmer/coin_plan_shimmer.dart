import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/utils.dart';

class CoinPlanShimmer extends StatelessWidget {
  const CoinPlanShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.lightGrey1,
      highlightColor: AppColors.grey.withValues(alpha: 0.2),
      child: ListView.builder(
        itemCount: 3,
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.appColor.withValues(alpha: 0.2),
              border: Border.all(color: AppColors.black),
              borderRadius: BorderRadius.circular(14),
            ),
            padding: EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: Get.height * 0.060,
                      width: Get.height * 0.060,
                      decoration: BoxDecoration(
                        color: AppColors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    12.width,
                    Container(
                      height: 22,
                      width: 100,
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: AppColors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    Spacer(),
                    Container(
                      height: 30,
                      width: 70,
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: AppColors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
