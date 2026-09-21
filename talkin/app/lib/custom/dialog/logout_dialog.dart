import 'package:cupertino_rounded_corners/cupertino_rounded_corners.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/setting_screen/controller/setting_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class LogoutDialog extends StatefulWidget {
  const LogoutDialog({super.key});

  @override
  State<LogoutDialog> createState() => _LogoutDialogState();
}

class _LogoutDialogState extends State<LogoutDialog> {
  SettingController settingController = Get.put(SettingController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingController>(
      builder: (controller) {
        return SizedBox(
          // height: 365,
          child: Material(
            shape: const SquircleBorder(
              radius: BorderRadius.all(
                Radius.circular(110),
              ),
            ),
            color: AppColors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  AppAsset.logOut,
                  height: 90,
                ).paddingOnly(top: 16),
                Text(
                  EnumLocale.txtLogout.name.tr,
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 22,
                    fontColor: AppColors.appColor,
                  ),
                ).paddingOnly(top: 8),
                Text(
                  EnumLocale.txtDesLogout.name.tr,
                  textAlign: TextAlign.center,
                  style: AppFontStyle.fontStyleW500(
                    fontSize: 17,
                    fontColor: AppColors.appColor,
                  ),
                ).paddingOnly(top: 8, bottom: 13),
                // const Spacer(),
                PrimaryAppButton(
                  onTap: () {
                    Database.onLogOut();
                    // controller.signOut();
                    Get.offAllNamed(AppRoutes.main);
                    // exit(0);
                  },
                  height: 47,
                  borderRadius: 8,
                  text: EnumLocale.txtLogout.name.tr,
                  textStyle: AppFontStyle.fontStyleW600(
                    fontSize: 17,
                    fontColor: AppColors.white,
                  ),
                ).paddingOnly(top: 20, bottom: 10, left: 5, right: 5),
                PrimaryAppButton(
                  onTap: () {
                    Get.back();
                  },
                  height: 47,
                  borderRadius: 8,
                  color: AppColors.lightGrey,
                  text: EnumLocale.txtCancel.name.tr,
                  textStyle: AppFontStyle.fontStyleW700(
                    fontSize: 17,
                    fontColor: AppColors.appColor,
                  ),
                ).paddingOnly(bottom: 18, left: 5, right: 5)
              ],
            ).paddingAll(15),
          ),
        );
      },
    );
  }
}
