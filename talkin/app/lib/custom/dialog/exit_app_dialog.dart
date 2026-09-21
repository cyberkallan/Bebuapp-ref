import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cupertino_rounded_corners/cupertino_rounded_corners.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class ExitAppDialog extends StatelessWidget {
  const ExitAppDialog({super.key});

  @override
  Widget build(BuildContext context) {
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
              EnumLocale.txtExitApp.name.tr,
              style: AppFontStyle.fontStyleW700(
                fontSize: 22,
                fontColor: AppColors.appColor,
              ),
            ).paddingOnly(top: 8),
            Text(
              EnumLocale.desWantExitApp.name.tr,
              textAlign: TextAlign.center,
              style: AppFontStyle.fontStyleW500(
                fontSize: 17,
                fontColor: AppColors.appColor,
              ),
            ).paddingOnly(top: 8, bottom: 13),
            // const Spacer(),
            PrimaryAppButton(
              onTap: () {
                exit(0);
              },
              height: 47,
              borderRadius: 8,
              text: EnumLocale.txtExitApp.name.tr,
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
  }
}

class AppNotLiveDialog extends StatelessWidget {
  const AppNotLiveDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: 365,
      child: Material(
        shape: const SquircleBorder(
          radius: BorderRadius.all(
            Radius.circular(50),
          ),
        ),
        color: AppColors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 180,
              width: 180,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppAsset.underMaintenanceImage),
                  fit: BoxFit.cover,
                ),
                // color: Colors.red,
              ),
              // child: Image.asset(
              //   AppAsset.underMaintenanceImage,
              //   height: 180,
              //   width: 180,
              // ),
            ),
            Text(
              "Your app is under maintenance.",
              textAlign: TextAlign.center,
              style: AppFontStyle.fontStyleW500(
                fontSize: 19,
                fontColor: AppColors.appColor,
              ),
            ).paddingOnly(bottom: 13),
            // const Spacer(),
            PrimaryAppButton(
              onTap: () {
                exit(0);
              },
              height: 47,
              borderRadius: 8,
              text: EnumLocale.txtExitApp.name.tr,
              textStyle: AppFontStyle.fontStyleW600(
                fontSize: 17,
                fontColor: AppColors.white,
              ),
            ).paddingOnly(top: 20, bottom: 10, left: 5, right: 5),
          ],
        ).paddingAll(15),
      ),
    );
  }
}
