import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/utils.dart';

class ChatListShimmer extends StatelessWidget {
  const ChatListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.lightGrey1,
      highlightColor: AppColors.grey.withValues(alpha: 0.2),
      child: ListView.builder(
        itemCount: 9,
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: Get.height * 0.065,
                    width: Get.height * 0.065,
                    decoration: BoxDecoration(color: AppColors.black, shape: BoxShape.circle),
                  ),
                  15.width,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 17,
                        width: 130,
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: AppColors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      4.height,
                      Container(
                        height: 18,
                        width: 160,
                        margin: const EdgeInsets.only(bottom: 5),
                        decoration: BoxDecoration(
                          color: AppColors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ],
                  ),
                  // Spacer(),
                  // Container(
                  //   height: 20,
                  //   width: 20,
                  //   decoration: BoxDecoration(
                  //     color: AppColors.black,
                  //     shape: BoxShape.circle,
                  //   ),
                  // ),
                ],
              ).paddingOnly(bottom: 12, left: 16, right: 16),
              Divider(
                color: AppColors.lightGrey,
                height: 0,
              )
            ],
          ),
        ),
      ).paddingSymmetric(vertical: 16),
    );
  }
}
