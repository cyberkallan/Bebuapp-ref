import 'package:dotted_border/dotted_border.dart' show DottedBorder, BorderType;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/utils.dart';

class AllReviewShimmer extends StatelessWidget {
  const AllReviewShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.lightGrey1,
      highlightColor: AppColors.grey.withValues(alpha: 0.2),
      child: ListView.builder(
        itemCount: 10,
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => Container(
          padding: EdgeInsets.all(10),

          // height: 60,
          width: Get.width,
          decoration: BoxDecoration(
            color: AppColors.appColor.withValues(alpha: 0.2),
            border: Border.all(color: AppColors.black),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DottedBorder(
                    borderType: BorderType.Circle,
                    color: AppColors.black,
                    dashPattern: [3, 2],
                    strokeWidth: 1,
                    child: GestureDetector(
                      onTap: () {
                        // Get.toNamed(AppRoutes.hostProfileScreen);
                      },
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ).paddingOnly(right: 13),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          height: 17, width: 120, decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(30))),
                      4.height,
                      Container(
                          height: 20, width: 140, decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(30))),
                    ],
                  ),
                  Spacer(),
                  Container(
                    height: 20,
                    width: 70,
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Color(0xffE7EBF7), borderRadius: BorderRadius.circular(34)),
                  )
                ],
              ).paddingOnly(top: 5, bottom: 6),
              Container(height: 40, width: Get.width, decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(30)))
            ],
          ),
        ).paddingOnly(left: 16, right: 16, bottom: 14),
      ).paddingOnly(top: 22),
    );
  }
}
