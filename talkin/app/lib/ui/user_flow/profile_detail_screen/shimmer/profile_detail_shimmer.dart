import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/utils.dart';

class ProfileDetailShimmer extends StatelessWidget {
  const ProfileDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.lightGrey1,
      highlightColor: AppColors.grey.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: Get.height * 0.38,
            width: Get.width,
            decoration: BoxDecoration(
              color: AppColors.appColor.withValues(alpha: 0.5),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            height: Get.height * 0.1,
            width: Get.width,
            decoration: BoxDecoration(
              color: AppColors.appColor.withValues(alpha: 0.5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    shape: BoxShape.circle,
                  ),
                ).paddingOnly(right: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 18,
                          width: Get.width * 0.2,
                          margin: const EdgeInsets.only(bottom: 5),
                          decoration: BoxDecoration(
                            color: AppColors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ).paddingOnly(bottom: 8),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 6, bottom: 5, top: 5, left: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 18,
                            width: Get.width * 0.16,
                            margin: const EdgeInsets.only(bottom: 5),
                            decoration: BoxDecoration(
                              color: AppColors.black,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ).paddingOnly(right: 4),
                        ],
                      ),
                    )
                  ],
                ),
                Spacer(),
                Container(
                  height: 20,
                  width: Get.width * 0.21,
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.lightYellow,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: Get.height * 0.1,
            width: Get.width,
            decoration: BoxDecoration(
              color: AppColors.appColor.withValues(alpha: 0.5),
            ),
          ).paddingOnly(top: 10),
          Container(
            height: 24,
            width: Get.width * 0.4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.appColor.withValues(alpha: 0.5),
            ),
          ).paddingOnly(top: 15, left: 14),
          Row(
            children: [
              for (int i = 0; i < 3; i++)
                Container(
                  height: 20,
                  width: 60,
                  margin: const EdgeInsets.only(bottom: 5, right: 4),
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
            ],
          ).paddingOnly(top: 15, bottom: 15, left: 14),
          Row(
            children: [
              for (int i = 0; i < 3; i++)
                Expanded(
                  child: Container(
                    height: 120,
                    // width: 60,
                    margin: const EdgeInsets.only(bottom: 5, right: 6),
                    decoration: BoxDecoration(
                      color: AppColors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
            ],
          ).paddingOnly(bottom: 15, left: 14, right: 14),
        ],
      ),
    );
  }
}

class ProfileDetailButtonShimmer extends StatelessWidget {
  const ProfileDetailButtonShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.lightGrey1,
      highlightColor: AppColors.grey.withValues(alpha: 0.2),
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.10),
                offset: Offset(0, 0),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  height: Get.height * 0.06,
                  decoration: BoxDecoration(
                    color: AppColors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ).paddingOnly(bottom: 10),
              ),
              12.width,
              Expanded(
                child: Container(
                  height: Get.height * 0.06,
                  decoration: BoxDecoration(
                    color: AppColors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ).paddingOnly(bottom: 10),
              )
            ],
          )),
    );
  }
}
