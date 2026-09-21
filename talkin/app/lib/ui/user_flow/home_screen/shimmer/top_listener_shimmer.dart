import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/utils.dart';

class TopListenerShimmer extends StatelessWidget {
  const TopListenerShimmer({super.key});

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: Get.height * 0.11,
                      width: Get.height * 0.11,
                      decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(12)),
                    ),
                    12.width,
                    Column(
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
                        ),
                        4.height,
                        Container(
                          height: 18,
                          width: 150,
                          margin: const EdgeInsets.only(bottom: 5),
                          decoration: BoxDecoration(
                            color: AppColors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        6.height,
                        Container(
                          height: 1,
                          width: Get.width / 1.8,
                          margin: const EdgeInsets.only(bottom: 5),
                          decoration: BoxDecoration(
                            color: AppColors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        6.height,
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
                        ),
                      ],
                    ),
                  ],
                ),
                10.height,
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    10.width,
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
