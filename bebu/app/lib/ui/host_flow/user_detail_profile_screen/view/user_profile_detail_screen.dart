import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/host_flow/user_detail_profile_screen/controller/user_profile_deatil_controller.dart';
import 'package:talk_in/ui/host_flow/user_detail_profile_screen/shimmer/user_profile_shimmer.dart';
import 'package:talk_in/ui/host_flow/user_detail_profile_screen/widget/user_profile_detail_widget.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';

class UserProfileDetailScreen extends StatefulWidget {
  const UserProfileDetailScreen({super.key});

  @override
  State<UserProfileDetailScreen> createState() => _UserProfileDetailScreenState();
}

class _UserProfileDetailScreenState extends State<UserProfileDetailScreen> {
  UserProfileDetailController controller = Get.put(UserProfileDetailController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPurple,
      bottomNavigationBar: UserProfileBottomButtonView(),
      body: SafeArea(
        child: GetBuilder<UserProfileDetailController>(
            id: Constant.listenerProfile,
            builder: (controller) {
              return Stack(
                children: [
                  SingleChildScrollView(
                    child: controller.isLoading
                        ? UserProfileShimmer()
                        : Column(
                            children: [
                              UserProfileTopImageView(),
                              UserProfileInfoView(),
                            ],
                          ),
                  ),
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
              );
            }),
      ),
    );
  }
}
