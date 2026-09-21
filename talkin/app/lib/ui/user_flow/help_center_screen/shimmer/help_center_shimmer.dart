import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talk_in/utils/app_color.dart';

class HelpCenterShimmer extends StatelessWidget {
  const HelpCenterShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.lightGrey1,
      highlightColor: AppColors.grey.withValues(alpha: 0.2),
      child: ListView.builder(
        itemCount: 7,
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            height: 60,
            width: Get.width,
            decoration: BoxDecoration(
              color: AppColors.appColor.withValues(alpha: 0.2),
              border: Border.all(color: AppColors.black),
              borderRadius: BorderRadius.circular(14),
            ),
            // padding: EdgeInsets.all(6),
            // child: Column(
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Container(
            //           height: Get.height * 0.078,
            //           width: Get.height * 0.078,
            //           decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(12)),
            //         ),
            //         12.width,
            //         Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             Container(
            //               height: 17,
            //               width: 120,
            //               margin: const EdgeInsets.only(bottom: 4),
            //               decoration: BoxDecoration(
            //                 color: AppColors.black,
            //                 borderRadius: BorderRadius.circular(20),
            //               ),
            //             ),
            //             4.height,
            //             Container(
            //               height: 18,
            //               width: 100,
            //               margin: const EdgeInsets.only(bottom: 5),
            //               decoration: BoxDecoration(
            //                 color: AppColors.black,
            //                 borderRadius: BorderRadius.circular(20),
            //               ),
            //             ),
            //             6.height,
            //             Container(
            //               height: 18,
            //               width: 120,
            //               margin: const EdgeInsets.only(bottom: 5),
            //               decoration: BoxDecoration(
            //                 color: AppColors.black,
            //                 borderRadius: BorderRadius.circular(20),
            //               ),
            //             ),
            //           ],
            //         ),
            //         Spacer(),
            //         Container(
            //           height: 30,
            //           width: 80,
            //           margin: const EdgeInsets.only(bottom: 4),
            //           decoration: BoxDecoration(
            //             color: AppColors.black,
            //             borderRadius: BorderRadius.circular(20),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ],
            // ),
          ).paddingOnly(left: 16, right: 16, bottom: 16),
        ),
      ).paddingOnly(top: 22),
    );
  }
}
