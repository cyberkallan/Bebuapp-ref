import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_bar/custom_app_bar.dart';
import 'package:talk_in/custom/dialog/delete_account_dialog.dart';
import 'package:talk_in/custom/dialog/logout_dialog.dart';
import 'package:talk_in/custom/setting_menu_ui/setting_menu.dart';
import 'package:talk_in/custom/switch/switch.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/setting_screen/controller/setting_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/enums.dart';

class SettingScreenAppBar extends StatelessWidget {
  const SettingScreenAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(120),
      child: CustomAppBar(
        appBarColor: AppColors.lightPurple,
        title: EnumLocale.txtSettings.name.tr,
        showLeadingIcon: true,
      ),
    );
  }
}

class SettingView extends StatelessWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingMainMenu(
          rightSpace: Get.width * -0.07,
          text: EnumLocale.txtManageYourAccountSettings.name.tr,
          subText: EnumLocale.txtManageYourAccountSettingsSubText.name.tr,
          topImage: AppAsset.settingBlur,
        ).paddingOnly(bottom: 20),
        GetBuilder<SettingController>(
          builder: (controller) {
            return SettingMenu(
              widget: CommonCupertinoSwitch(
                value: controller.isShowNotification,
                onChanged: (bool val) {
                  controller.onSwitchNotification(val);
                },
                activeColor: CupertinoColors.activeGreen,
                trackColor: CupertinoColors.destructiveRed,
                scale: 0.8,
              ),
              icon: AppAsset.notification,
              title: EnumLocale.txtNotification.name.tr,
              onTap: () {},
            ).paddingOnly(bottom: 22);
          },
        ),
        SettingMenu(
          icon: AppAsset.settingAppLanguage,
          title: EnumLocale.txtAPPLanguage.name.tr,
          onTap: () {
            Get.toNamed(AppRoutes.appLanguageScreen);
          },
        ).paddingOnly(bottom: 22),
        SettingMenu(
          icon: AppAsset.logOut,
          title: EnumLocale.txtLogoutApp.name.tr,
          onTap: () {
            Get.dialog(
              barrierColor: AppColors.black.withValues(alpha: 0.8),
              Dialog(
                backgroundColor: AppColors.transparent,
                shadowColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                child: LogoutDialog(),
              ),
            );
          },
        ).paddingOnly(bottom: 22),
        GetBuilder<SettingController>(builder: (controller) {
          return SettingMenu(
            icon: AppAsset.delete,
            title: EnumLocale.txtDeleteAccount.name.tr,
            onTap: () {
              Get.dialog(
                barrierColor: AppColors.black.withValues(alpha: 0.8),
                Dialog(
                  backgroundColor: AppColors.transparent,
                  shadowColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  child: DeleteAccountDialog(
                    onTap: () {
                      controller.onDeleteAccount();
                    },
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }
}
