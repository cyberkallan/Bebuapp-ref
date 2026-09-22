import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/utils.dart';

class UserProfileShimmer extends StatelessWidget {
  const UserProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.lightGrey1,
      highlightColor: AppColors.grey.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile image section
          Container(
            height: Get.height * 0.35,
            width: Get.width,
            color: AppColors.lightGrey,
          ),

          // Profile details: avatar + name + ID + online status
          Container(
            color: AppColors.lightGrey,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar shimmer
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                // Name, Age, Status, ID shimmer
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: 120,
                        color: AppColors.black,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            height: 20,
                            width: 60,
                            decoration: BoxDecoration(
                              color: AppColors.green,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            height: 20,
                            width: 80,
                            decoration: BoxDecoration(
                              color: AppColors.grey,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          8.height,

          // User Details section
          _sectionTitle(),
          3.height,
          _detailRow(),
          3.height,

          _detailRow(),
          12.height,

          // Personal Details section
          _sectionTitle(title: "Personal Details :"),
          _detailRow(),
          _detailRow(),
          _detailRow(),
          _detailRow(),

          const SizedBox(height: 12),

          // Talk Now Button
        ],
      ),
    );
  }

  Widget _sectionTitle({String title = "User Details :"}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        height: 18,
        width: 140,
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _detailRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            height: 20,
            width: 30,
            decoration: BoxDecoration(
              color: AppColors.grey,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 18,
            width: 120,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    );
  }
}
