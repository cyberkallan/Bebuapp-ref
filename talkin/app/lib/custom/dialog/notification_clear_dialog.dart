import 'package:cupertino_rounded_corners/cupertino_rounded_corners.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/ui/host_flow/host_notification/controller/host_notification_controller.dart';
import 'package:talk_in/ui/user_flow/user_notification/controller/user_notification_controller.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class NotificationClearDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const NotificationClearDialog({super.key, required this.onConfirm});

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
        child: GetBuilder<UserNotificationController>(builder: (controller) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image.asset(
              //   AppAsset.logOut,
              //   height: 90,
              // ).paddingOnly(top: 16),
              // Text(
              //   EnumLocale.txtSureClearNotification.name.tr,
              //   style: AppFontStyle.fontStyleW700(
              //     fontSize: 22,
              //     fontColor: AppColors.appColor,
              //   ),
              // ).paddingOnly(top: 8),
              Text(
                EnumLocale.txtSureClearNotification.name.tr,
                textAlign: TextAlign.center,
                style: AppFontStyle.fontStyleW500(
                  fontSize: 17,
                  fontColor: AppColors.appColor,
                ),
              ).paddingOnly(top: 8, bottom: 13),
              // const Spacer(),
              PrimaryAppButton(
                onTap: () {
                  Get.back();

                  onConfirm(); // callback passed from parent
                },
                height: 47,
                borderRadius: 8,
                text: EnumLocale.txtSure.name.tr,
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
          ).paddingAll(15);
        }),
      ),
    );
  }
}

class HostNotificationClearDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const HostNotificationClearDialog({super.key, required this.onConfirm});

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
        child: GetBuilder<HostNotificationController>(builder: (controller) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image.asset(
              //   AppAsset.logOut,
              //   height: 90,
              // ).paddingOnly(top: 16),
              // Text(
              //   EnumLocale.txtSureClearNotification.name.tr,
              //   style: AppFontStyle.fontStyleW700(
              //     fontSize: 22,
              //     fontColor: AppColors.appColor,
              //   ),
              // ).paddingOnly(top: 8),
              Text(
                EnumLocale.txtSureClearNotification.name.tr,
                textAlign: TextAlign.center,
                style: AppFontStyle.fontStyleW500(
                  fontSize: 17,
                  fontColor: AppColors.appColor,
                ),
              ).paddingOnly(top: 8, bottom: 13),
              // const Spacer(),
              PrimaryAppButton(
                onTap: () {
                  Get.back();

                  onConfirm(); // callback passed from parent
                },
                height: 47,
                borderRadius: 8,
                text: EnumLocale.txtSure.name.tr,
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
          ).paddingAll(15);
        }),
      ),
    );
  }
}
