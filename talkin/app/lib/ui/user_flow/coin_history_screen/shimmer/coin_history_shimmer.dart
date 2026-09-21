import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talk_in/utils/app_color.dart';

class CoinHistoryShimmer extends StatelessWidget {
  const CoinHistoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.lightGrey1,
      highlightColor: AppColors.grey.withValues(alpha: 0.2),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 18,
                width: 80,
                margin: const EdgeInsets.only(bottom: 5),
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              Container(
                height: 18,
                width: 80,
                margin: const EdgeInsets.only(bottom: 5),
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
              )
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
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              Container(
                                height: 40,
                                width: 40,
                                margin: const EdgeInsets.only(bottom: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.black,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ).paddingOnly(right: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 18,
                                    width: 90,
                                    margin: const EdgeInsets.only(bottom: 5),
                                    decoration: BoxDecoration(
                                      color: AppColors.black,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ).paddingOnly(bottom: 3),
                                  Row(
                                    children: [
                                      Container(
                                        height: 20,
                                        width: 120,
                                        margin: const EdgeInsets.only(bottom: 5),
                                        decoration: BoxDecoration(
                                          color: AppColors.black,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              height: 18,
                              width: 40,
                              margin: const EdgeInsets.only(bottom: 5),
                              decoration: BoxDecoration(
                                color: AppColors.black,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ).paddingOnly(bottom: 4),
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
                      ],
                    ).paddingOnly(right: 14, bottom: 14, top: 14, left: 10),
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
