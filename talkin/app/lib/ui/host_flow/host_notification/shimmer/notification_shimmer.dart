import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/utils.dart';

class NotificationShimmer extends StatelessWidget {
  const NotificationShimmer({super.key});

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
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 22,
                width: 150,
                decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(20)),
              ).paddingOnly(bottom: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      height: 35,
                      width: 120,
                      decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                  12.width,
                  Container(
                    height: 20,
                    width: 50,
                    decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(20)),
                  ),
                ],
              ),
              Divider(
                color: AppColors.lightGrey,
                height: 30,
              )
            ],
          ).paddingOnly(bottom: 12),
        ),
      ),
    );
  }
}
