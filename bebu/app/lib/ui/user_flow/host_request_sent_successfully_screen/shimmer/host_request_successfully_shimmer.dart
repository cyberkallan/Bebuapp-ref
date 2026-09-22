import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/utils.dart';

class HostRequestSuccessfullyShimmer extends StatelessWidget {
  const HostRequestSuccessfullyShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.lightGrey1,
      highlightColor: AppColors.grey.withValues(alpha: 0.2),
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), border: Border.all(color: AppColors.grey)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.grey.withValues(alpha: 0.5),
                  ),
                  child: Container(
                    // clipBehavior: Clip.hardEdge,
                    height: 76,
                    width: 76,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey, width: 1),
                      shape: BoxShape.circle,
                    ),
                  ).paddingAll(1),
                ).paddingOnly(right: 12),
                SizedBox(
                  width: Get.width * 0.3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 22,
                        width: 100,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: AppColors.grey),
                      ),
                      4.height,
                      Container(
                        height: 20,
                        width: 100,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: AppColors.grey),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Container(
                  height: 30,
                  width: 90,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColors.lightGrey),
                )
              ],
            ),
            6.height,
            DottedLine(
              direction: Axis.horizontal,
              alignment: WrapAlignment.center,
              lineLength: double.infinity,
              lineThickness: 1,
              dashLength: 4.0,
              dashColor: AppColors.grey.withValues(alpha: 0.3),
              dashRadius: 0.0,
              dashGapLength: 4.0,
              dashGapColor: Colors.transparent,
              dashGapRadius: 0.0,
            ).paddingOnly(bottom: 15, top: 15),
            6.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 22,
                  width: 120,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: AppColors.grey),
                ),
                Container(
                  height: 25,
                  width: Get.width * 0.43,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: AppColors.grey),
                ),
              ],
            ).paddingOnly(bottom: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 22,
                  width: 120,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: AppColors.grey),
                ),
                Container(
                  height: 25,
                  width: Get.width * 0.43,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: AppColors.grey),
                ),
              ],
            ).paddingOnly(bottom: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 22,
                  width: 120,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: AppColors.grey),
                ),
                Container(
                  height: 25,
                  width: Get.width * 0.43,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: AppColors.grey),
                ),
              ],
            ).paddingOnly(bottom: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 22,
                  width: 120,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: AppColors.grey),
                ),
                Container(
                  height: 25,
                  width: Get.width * 0.43,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: AppColors.grey),
                ),
              ],
            ).paddingOnly(bottom: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 22,
                  width: 120,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: AppColors.grey),
                ),
                Container(
                  height: 25,
                  width: Get.width * 0.43,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: AppColors.grey),
                ),
              ],
            ).paddingOnly(bottom: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 22,
                  width: 120,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: AppColors.grey),
                ),
                Container(
                  height: 25,
                  width: Get.width * 0.43,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: AppColors.grey),
                ),
              ],
            ),
            28.height,
            Container(
              height: 22,
              width: 120,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: AppColors.grey),
            ),
            16.height,
            Container(
              width: Get.width,
              height: 90,
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.grey.withValues(alpha: 0.4),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            28.height
          ],
        ),
      ).paddingAll(16),
    );
  }
}
