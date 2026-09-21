import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/edit_profile_screen/controller/edit_profile_screen_controller.dart';
import 'package:talk_in/ui/user_flow/my_profile_screen/controller/my_profile_screen_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class MyProfileTopView extends StatelessWidget {
  const MyProfileTopView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditProfileController>(
        id: Constant.idProfile,
        builder: (context) {
          return Container(
            // padding: EdgeInsets.only(left: 16),
            decoration: BoxDecoration(color: AppColors.appColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      color: AppColors.transparent,
                      child: InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 22, top: 22, left: 20, right: 6),
                          child: Image.asset(
                            height: 16,
                            AppAsset.backArrowIcon,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    Text(
                      EnumLocale.txtMyProfile.name.tr,
                      style: AppFontStyle.fontStyleW600(fontSize: 20, fontColor: AppColors.white),
                    ),
                    Spacer(),
                  ],
                ).paddingOnly(bottom: 10, right: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.white),
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        // clipBehavior: Clip.hardEdge,
                        height: 54,
                        width: 54,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.appColor),
                          color: AppColors.lightGrey,
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          // child: Image.network(
                          //   Database.loginUserProfilePic,
                          //   // "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRCIyTZVXyb90oYHRiiX6YkNUc0CnzGwWjI3Q&s",
                          //   fit: BoxFit.cover,
                          // ),
                          child: CustomProfileImage(
                            image: Database.loginUserProfilePic,
                          ),
                        ),
                      ).paddingAll(1),
                    ).paddingOnly(right: 12, left: 16),
                    SizedBox(
                      width: Get.width * 0.4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Database.loginUserName,
                            overflow: TextOverflow.ellipsis,
                            style: AppFontStyle.fontStyleW700(fontSize: 19, fontColor: AppColors.white),
                          ),
                          Database.loginType == 2
                              ? Text(
                                  Database.loginUserNickName,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFontStyle.fontStyleW500(fontSize: 15, fontColor: AppColors.profileMail),
                                )
                              : Text(
                                  Database.loginUserEmail,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFontStyle.fontStyleW500(fontSize: 15, fontColor: AppColors.profileMail),
                                ),
                        ],
                      ).paddingOnly(top: 5),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(AppRoutes.editProfileScreen);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              AppAsset.editIcon,
                              height: 17,
                              width: 17,
                            ),
                            SizedBox(
                              width: Get.width * 0.2,
                              child: Text(
                                EnumLocale.txtEditProfile.name.tr,
                                overflow: TextOverflow.ellipsis,
                                style: AppFontStyle.fontStyleW700(fontSize: 12, fontColor: AppColors.appColor),
                              ).paddingOnly(left: 6, right: 2),
                            )
                          ],
                        ),
                      ).paddingOnly(right: 14),
                    ).paddingOnly(top: 3),
                  ],
                ).paddingOnly(bottom: 24),
              ],
            ).paddingOnly(top: Get.height * 0.042),
          );
        });
  }
}

class ProfileOptionsView extends StatelessWidget {
  const ProfileOptionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GetBuilder<MyProfileScreenController>(builder: (controller) {
        return Column(
          children: [
            // Top 3 Boxes (Wallet, Help Center, Settings)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TopItem(
                  icon: AppAsset.wallet,
                  title: EnumLocale.txtMyWallet.name.tr,
                  onTap: () {
                    Get.toNamed(AppRoutes.myWalletScreen);
                  },
                ),
                TopItem(
                  icon: AppAsset.helpCenter,
                  title: EnumLocale.txtHelpCenter.name.tr,
                  onTap: () {
                    Get.toNamed(AppRoutes.helpCenterScreen);
                  },
                ),
                TopItem(
                  icon: AppAsset.setting,
                  title: EnumLocale.txtSettings.name.tr,
                  onTap: () {
                    Get.toNamed(AppRoutes.settingScreen);
                  },
                ),
              ],
            ).paddingOnly(top: 16, bottom: 24, left: 9, right: 9),

            // Host Center Box
            Database.settingApiModel?.data?.allowBecomeHostOption == true
                ? CenterOption(
                    onTap: () {
                      Get.toNamed(AppRoutes.becomeHostScreen);
                    },
                    icon: AppAsset.hostCenter,
                    title: EnumLocale.txtListenersCenter.name.tr,
                    subtitle: EnumLocale.txtHostCenterDescription.name.tr,
                    badgeText: EnumLocale.txtBecomeListener.name.tr,
                  )
                : SizedBox(),
            // Privacy Center Box
            CenterOption(
              onTap: () async {
                controller.onClickPrivacyPolicy();
              },
              icon: AppAsset.privacyCenter,
              title: EnumLocale.txtPrivacyCenter.name.tr,
              subtitle: EnumLocale.txtDataPrivacy.name.tr,
            ),

            // Share App Box
            CenterOption(
              onTap: () {
                controller.onClickShare();
                // Get.toNamed(AppRoutes.shareAppScreen);
              },
              icon: AppAsset.shareApp,
              title: EnumLocale.txtShareApp.name.tr,
              subtitle: EnumLocale.txtShareAppDes.name.tr,
            ),
            CenterOption(
              onTap: () async {
                controller.onClickAboutUs();
              },
              icon: AppAsset.aboutUs,
              title: EnumLocale.txtAboutUs.name.tr,
              subtitle: EnumLocale.txtAboutUsDes.name.tr,
            ),
          ],
        );
      }),
    );
  }

/*
  Widget _buildTopItem(String icon, String title, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.only(bottom: 10, top: 15),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderColor.withValues(alpha: 0.6)),
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                icon,
                height: 60,
                width: 60,
              ).paddingSymmetric(horizontal: 25),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppFontStyle.fontStyleW600(fontSize: 14, fontColor: AppColors.black),
              ).paddingOnly(top: 8),
            ],
          ),
        ).paddingSymmetric(horizontal: 6),
      ),
    );
  }
*/

/*  Widget _buildCenterOption({
    required String icon,
    required String title,
    required String subtitle,
    String? badgeText,
    Function()? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.profileOption.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                icon,
                height: 68,
                width: 68,
              ).paddingOnly(right: 12),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: AppFontStyle.fontStyleW800(fontSize: 18, fontColor: AppColors.black),
                      ),
                      if (badgeText != null)
                        Container(
                          width: Get.width * 0.25,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.appColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            overflow: TextOverflow.ellipsis,
                            badgeText,
                            style: AppFontStyle.fontStyleW700(fontSize: 10, fontColor: AppColors.white),
                          ),
                        ).paddingOnly(left: 5),
                    ],
                  ),
                  Text(
                    subtitle,
                    style: AppFontStyle.fontStyleW500(fontSize: 10, fontColor: AppColors.profileText, height: 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).paddingOnly(left: 16, right: 16, bottom: 18),
    );
  }*/
}

class CenterOption extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String? badgeText;
  final Function()? onTap;

  const CenterOption({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badgeText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.profileOption.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                icon,
                height: 68,
                width: 68,
              ).paddingOnly(right: 12),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        softWrap: true,
                        style: AppFontStyle.fontStyleW800(fontSize: 18, fontColor: AppColors.black),
                      ),
                      if (badgeText != null)
                        Container(
                          width: Get.width * 0.25,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.appColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            overflow: TextOverflow.ellipsis,
                            badgeText!,
                            style: AppFontStyle.fontStyleW700(fontSize: 10, fontColor: AppColors.white),
                          ),
                        ).paddingOnly(left: 5),
                    ],
                  ),
                  Text(
                    subtitle,
                    style: AppFontStyle.fontStyleW500(fontSize: 10, fontColor: AppColors.profileText, height: 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).paddingOnly(left: 16, right: 16, bottom: 18),
    );
  }
}

class TopItem extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onTap;

  const TopItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.only(bottom: 10, top: 15),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderColor.withValues(alpha: 0.6)),
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                icon,
                height: 60,
                width: 60,
              ).paddingSymmetric(horizontal: 25),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppFontStyle.fontStyleW600(fontSize: 14, fontColor: AppColors.black),
              ).paddingOnly(top: 8),
            ],
          ),
        ).paddingSymmetric(horizontal: 6),
      ),
    );
  }
}
