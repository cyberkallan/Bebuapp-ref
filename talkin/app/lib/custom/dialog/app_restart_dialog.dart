import 'package:cupertino_rounded_corners/cupertino_rounded_corners.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/setting_screen/controller/setting_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class AppRestartDialog extends StatefulWidget {
  const AppRestartDialog({super.key});

  @override
  State<AppRestartDialog> createState() => _AppRestartDialogState();
}

class _AppRestartDialogState extends State<AppRestartDialog> {
  SettingController settingController = Get.put(SettingController());

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: 365,
      child: Material(
        shape: const SquircleBorder(
          radius: BorderRadius.all(
            Radius.circular(100),
          ),
        ),
        color: AppColors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AppAsset.listenersVerification,
              height: 50,
            ).paddingOnly(bottom: 20),
            Text(
              EnumLocale.txtAppRestart.name.tr,
              textAlign: TextAlign.center,
              style: AppFontStyle.fontStyleW700(
                fontSize: 25,
                fontColor: AppColors.appColor,
              ),
            ).paddingOnly(top: 8, bottom: 9),
            Text(
              EnumLocale.txtAppRestart.name.tr,
              textAlign: TextAlign.center,
              style: AppFontStyle.fontStyleW500(
                fontSize: 15,
                fontColor: AppColors.onBoardingTxt,
              ),
            ).paddingOnly(top: 8, bottom: 13),
            // const Spacer(),
            PrimaryAppButton(
              color: AppColors.red,
              onTap: () {
                Get.offAllNamed(AppRoutes.splashScreenPage);
                // exit(0);
              },
              height: 47,
              borderRadius: 8,
              text: "Re-Start APP",
              textStyle: AppFontStyle.fontStyleW600(
                fontSize: 17,
                fontColor: AppColors.white,
              ),
            ).paddingOnly(top: 20, bottom: 10, left: 5, right: 5),
          ],
        ).paddingAll(20),
      ),
    );
  }
}
