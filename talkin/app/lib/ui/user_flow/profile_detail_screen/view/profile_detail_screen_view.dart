import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/profile_detail_screen/controller/profile_detail_screen_controller.dart';
import 'package:talk_in/ui/user_flow/profile_detail_screen/shimmer/profile_detail_shimmer.dart';
import 'package:talk_in/ui/user_flow/profile_detail_screen/widget/profile_detail_screen_widget.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';

class ProfileDetailScreenView extends StatelessWidget {
  const ProfileDetailScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      bottomNavigationBar: ProfileBottomButtonView(),
      body: SafeArea(
        child: Stack(
          children: [
            GetBuilder<ProfileDetailScreenController>(
                id: Constant.listenerProfile,
                builder: (controller) {
                  return RefreshIndicator(
                    onRefresh: () => controller.onRefresh(),
                    child: SingleChildScrollView(
                      child: controller.isLoading == true
                          ? ProfileDetailShimmer()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TopImageView(),
                                UserProfileInfoView(),
                                StatusView(),
                                ReviewShow(),
                              ],
                            ),
                    ),
                  );
                }),
            Positioned(
              left: 17,
              top: 8,
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      padding: EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: AppColors.black.withValues(alpha: 0.18),
                      ),
                      child: Center(
                        child: Image.asset(
                          AppAsset.backArrowIcon,
                          height: 17,
                          width: 17,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
