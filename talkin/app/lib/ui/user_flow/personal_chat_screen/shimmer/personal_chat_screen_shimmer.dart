import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talk_in/utils/app_color.dart';

class PersonalChatScreenShimmer extends StatelessWidget {
  const PersonalChatScreenShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.lightGrey1,
      highlightColor: AppColors.grey.withValues(alpha: 0.2),
      child: ListView.builder(
        itemCount: 12,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        itemBuilder: (context, index) {
          final isMe = index % 2 == 0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (!isMe) ...[
                  Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.grey.withValues(alpha: 0.5),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.grey.withValues(alpha: 0.5),
                        ),
                        child: Container(
                          // clipBehavior: Clip.hardEdge,
                          height: 36,
                          width: 36,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.white, width: 1),
                            shape: BoxShape.circle,
                          ),
                        ).paddingAll(1),
                      )).paddingOnly(bottom: 4),
                  const SizedBox(width: 6),
                ],
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: Radius.circular(isMe ? 12 : 0),
                      bottomRight: Radius.circular(isMe ? 0 : 12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 10,
                        width: Get.width * 0.5,
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: AppColors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      Container(
                        height: 10,
                        width: Get.width * 0.3,
                        decoration: BoxDecoration(
                          color: AppColors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 6),
                  Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.grey.withValues(alpha: 0.5),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.grey.withValues(alpha: 0.5),
                        ),
                        child: Container(
                          // clipBehavior: Clip.hardEdge,
                          height: 36,
                          width: 36,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.white, width: 1),
                            shape: BoxShape.circle,
                          ),
                        ).paddingAll(1),
                      )).paddingOnly(bottom: 4),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
