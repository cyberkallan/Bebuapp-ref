import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/host_flow/host_listeners_detail_screen/controller/host_listeners_detail_controller.dart';
import 'package:talk_in/ui/host_flow/host_profile_screen/controller/host_profile_screen_controller.dart';
import 'package:talk_in/ui/user_flow/splash_screen_page/api/fetch_listener_profile_api.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class HostProfileTopView extends StatelessWidget {
  const HostProfileTopView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16),
      decoration: BoxDecoration(color: AppColors.appColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Spacer(),
              Text(
                EnumLocale.txtMyProfile.name.tr,
                style: AppFontStyle.fontStyleW600(fontSize: 20, fontColor: AppColors.white),
              ).paddingOnly(bottom: 20, top: 18),
              Spacer(),
            ],
          ).paddingOnly(bottom: 10),
          GetBuilder<HostListenersDetailController>(
            builder: (controller) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                        child: CustomProfileImage(
                          image: Database.fetchListenerProfileModel?.data?.image ?? '',
                        ),
                      ),
                    ).paddingAll(1),
                  ).paddingOnly(right: 12),
                  SizedBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Database.fetchListenerProfileModel?.data?.name ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: AppFontStyle.fontStyleW700(fontSize: 19, fontColor: AppColors.white),
                        ),
                        Text(
                          Database.loginType == 2 ? Database.loginUserNickName : Database.loginUserEmail,

                          // Database.loginUserEmail,
                          overflow: TextOverflow.ellipsis,
                          style: AppFontStyle.fontStyleW500(fontSize: 15, fontColor: AppColors.profileMail),
                        )
                      ],
                    ).paddingOnly(top: 5),
                  ),
                ],
              ).paddingOnly(bottom: 24);
            },
          ),
        ],
      ).paddingOnly(top: Get.height * 0.042),
    );
  }
}

class HostProfileOptionsView extends StatelessWidget {
  const HostProfileOptionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: GetBuilder<HostProfileScreenController>(builder: (controller) {
          return Column(
            children: [
              // Top 3 Boxes (Wallet, Help Center, Settings)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TopItem(
                    icon: AppAsset.listeners,
                    title: EnumLocale.txtListener.name.tr,
                    onTap: () {
                      Get.toNamed(AppRoutes.hostListenersDetailScreen)?.then(
                        (value) => FetchListenerProfileAPi.callApi(
                          loginListenerId: Database.fetchLoginUserProfileModel?.user?.listenerId,
                        ),
                      );
                    },
                  ),
                  TopItem(
                    icon: AppAsset.helpCenter,
                    title: EnumLocale.txtHelpCenter.name.tr,
                    onTap: () {
                      Get.toNamed(AppRoutes.hostHelpCenterScreen);
                    },
                  ),
                  TopItem(
                    icon: AppAsset.setting,
                    title: EnumLocale.txtSettings.name.tr,
                    onTap: () {
                      Get.toNamed(AppRoutes.hostSettingScreen);
                    },
                  ),
                ],
              ).paddingOnly(top: 16, bottom: 24, left: 9, right: 9),

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
      ),
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
            Image.asset(
              icon,
              height: 68,
              width: 68,
            ).paddingOnly(right: 12),
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
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.appColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            badgeText!,
                            style: AppFontStyle.fontStyleW700(fontSize: 11, fontColor: AppColors.white),
                          ),
                        ).paddingOnly(left: 12),
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
