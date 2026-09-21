import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talk_in/utils/app_color.dart';

class SearchListShimmer extends StatelessWidget {
  const SearchListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.lightGrey1,
      highlightColor: AppColors.grey.withValues(alpha: 0.2),
      child: ListView.builder(
        itemCount: 4,
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            children: [
              GestureDetector(
                child: Container(
                  color: AppColors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: Get.height * 0.07,
                        width: Get.height * 0.07,
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: AppColors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ).paddingOnly(right: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 17,
                              width: 100,
                              margin: const EdgeInsets.only(bottom: 4),
                              decoration: BoxDecoration(
                                color: AppColors.black,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ).paddingOnly(bottom: 6),
                            Row(
                              children: [
                                Container(
                                  height: 15,
                                  width: 15,
                                  margin: const EdgeInsets.only(bottom: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.black,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ).paddingOnly(right: 5),
                                SizedBox(
                                  width: Get.width * 0.18,
                                  child: Container(
                                    height: 17,
                                    width: 100,
                                    margin: const EdgeInsets.only(bottom: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.black,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ).paddingOnly(right: 16),
                                ),
                                Container(
                                  height: 15,
                                  width: 15,
                                  margin: const EdgeInsets.only(bottom: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.black,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ).paddingOnly(right: 5),
                                Container(
                                  height: 17,
                                  width: Get.width * 0.18,
                                  margin: const EdgeInsets.only(bottom: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.black,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ).paddingOnly(right: 16),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).paddingOnly(left: 16, right: 16),
                ),
              ),
              Divider(
                color: AppColors.lightGrey,
                height: Get.height * 0.04,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
