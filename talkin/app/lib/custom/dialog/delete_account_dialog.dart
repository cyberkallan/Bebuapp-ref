import 'package:cupertino_rounded_corners/cupertino_rounded_corners.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class DeleteAccountDialog extends StatelessWidget {
  final VoidCallback? onTap;
  const DeleteAccountDialog({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 351,
      child: Material(
        shape: const SquircleBorder(
          radius: BorderRadius.all(
            Radius.circular(90),
          ),
        ),
        color: AppColors.white,
        child: Column(
          children: [
            Image.asset(AppAsset.delete, height: 90),
            Text(
              EnumLocale.txtDeleteAccount.name.tr,
              style: AppFontStyle.fontStyleW700(
                fontSize: 22,
                fontColor: AppColors.red,
              ),
            ).paddingOnly(top: 8),
            Text(
              EnumLocale.desWantDeleteAccount.name.tr,
              textAlign: TextAlign.center,
              style: AppFontStyle.fontStyleW500(
                fontSize: 14,
                fontColor: AppColors.grey,
              ),
            ).paddingOnly(top: 8, bottom: 13),
            const Spacer(),
            PrimaryAppButton(
              onTap: onTap,
              height: 47,
              borderRadius: 8,
              color: AppColors.red,
              text: EnumLocale.txtDeleteAccount.name.tr,
              textStyle: AppFontStyle.fontStyleW700(
                fontSize: 17,
                fontColor: AppColors.white,
              ),
            ).paddingOnly(top: 20, bottom: 10),
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
            ).paddingOnly(bottom: 5)
          ],
        ).paddingAll(15),
      ),
    );
  }
}
