import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_bar/custom_app_bar.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/ui/user_flow/listener_screen/controller/listeners_screen_controller.dart';
import 'package:talk_in/ui/user_flow/listener_screen/widget/app_language_bottom_sheet.dart';
import 'package:talk_in/ui/user_flow/listener_screen/widget/talk_about_bottom_sheet.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class ListenersAppBarView extends StatelessWidget {
  const ListenersAppBarView({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(120),
      child: CustomAppBar(
        appBarColor: AppColors.lightPurple1,
        showBoxShadow: false,
        title: EnumLocale.txtAllListeners.name.tr,
        showLeadingIcon: false,
      ),
    );
  }
}

class ListenersTopButtonView extends StatelessWidget {
  const ListenersTopButtonView({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GetBuilder<ListenersScreenController>(
          builder: (controller) {
            return Expanded(
              child: PrimaryAppButton(
                borderColor: AppColors.border,
                color: AppColors.white,
                onTap: () {
                  Get.bottomSheet(
                    AppLanguageBottomSheet(),
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      AppAsset.speakingBoy,
                      height: 25,
                      width: 25,
                      color: AppColors.darkOrange,
                    ).paddingSymmetric(vertical: 10),
                    Text(
                      EnumLocale.txtLanguage.name.tr,
                      style: AppFontStyle.fontStyleW500(fontSize: 14, fontColor: AppColors.black),
                    ),
                    RotatedBox(
                      quarterTurns: 3,
                      child: Image.asset(
                        AppAsset.backArrowIcon,
                        height: 16,
                        width: 16,
                        color: AppColors.darkGrey.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ).paddingSymmetric(horizontal: 10),
              ),
            );
          },
        ),
        SizedBox(
          width: 16,
        ),
        Expanded(
          child: PrimaryAppButton(
            borderColor: AppColors.border,
            color: AppColors.white,
            onTap: () {
              Get.bottomSheet(
                TalkAboutBottomSheet(),
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  AppAsset.talkAboutIcon,
                  height: 25,
                  width: 25,
                  color: AppColors.blue,
                ).paddingSymmetric(vertical: 10),
                Text(
                  EnumLocale.txtTalkAbout.name.tr,
                  style: AppFontStyle.fontStyleW500(fontSize: 14, fontColor: AppColors.black),
                ),
                RotatedBox(
                  quarterTurns: 3,
                  child: Image.asset(
                    AppAsset.backArrowIcon,
                    height: 16,
                    width: 16,
                    color: AppColors.darkGrey.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ).paddingSymmetric(horizontal: 10),
          ),
        ),
      ],
    ).paddingOnly(left: 20, right: 20, bottom: 14);
  }
}
