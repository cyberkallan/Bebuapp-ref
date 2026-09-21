import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/utils.dart';

class PaymentHistoryShimmer extends StatelessWidget {
  const PaymentHistoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.lightGrey1,
      highlightColor: AppColors.grey.withValues(alpha: 0.2),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 18,
                width: 60,
                margin: const EdgeInsets.only(bottom: 5),
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              Spacer(),
              Container(
                height: 18,
                width: 50,
                margin: const EdgeInsets.only(bottom: 5),
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              10.width,
              Container(
                height: 18,
                width: 40,
                margin: const EdgeInsets.only(bottom: 5),
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              10.width,
              Container(
                height: 18,
                width: 50,
                margin: const EdgeInsets.only(bottom: 5),
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ).paddingSymmetric(horizontal: 16, vertical: 14),
          Divider(color: AppColors.lightGrey, height: 0),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 20,
                              width: 80,
                              margin: const EdgeInsets.only(bottom: 5),
                              decoration: BoxDecoration(
                                color: AppColors.black,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ).paddingOnly(bottom: 3),
                            Container(
                              height: 18,
                              width: 100,
                              margin: const EdgeInsets.only(bottom: 5),
                              decoration: BoxDecoration(
                                color: AppColors.black,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Container(
                          height: 18,
                          width: 50,
                          margin: const EdgeInsets.only(bottom: 5),
                          decoration: BoxDecoration(
                            color: AppColors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        10.width,
                        Container(
                          height: 18,
                          width: 40,
                          margin: const EdgeInsets.only(bottom: 5),
                          decoration: BoxDecoration(
                            color: AppColors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        10.width,

                        Container(
                          height: 18,
                          width: 50,
                          margin: const EdgeInsets.only(bottom: 5),
                          decoration: BoxDecoration(
                            color: AppColors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        // SizedBox(
                        //   width: Get.width * 0.11,
                        //   child: Image.asset(
                        //     AppAsset.downloadIcon,
                        //     height: 23,
                        //     width: 23,
                        //   ).paddingOnly(left: Get.width * 0.02),
                        // ),
                      ],
                    ).paddingSymmetric(horizontal: 14, vertical: 14),
                    Divider(color: AppColors.lightGrey, height: 0),
                  ],
                );
              },
            ),
          ),
        ],
      ).paddingOnly(left: 10, right: 10, top: 8),
    );
  }
}
