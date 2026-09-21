import 'package:cupertino_rounded_corners/cupertino_rounded_corners.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class RequestSentDialog extends StatefulWidget {
  const RequestSentDialog({super.key});

  @override
  State<RequestSentDialog> createState() => _RequestSentDialogState();
}

class _RequestSentDialogState extends State<RequestSentDialog> {
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
              AppAsset.requestSentImage,
              height: 120,
            ).paddingOnly(top: 16),
            Text(
              EnumLocale.txtYourHostRequestSentSuccessfully.name.tr,
              textAlign: TextAlign.center,
              style: AppFontStyle.fontStyleW700(
                fontSize: 24,
                fontColor: AppColors.green,
              ),
            ).paddingOnly(top: 8),
            Text(
              EnumLocale.txtYourHostRequestSentSuccessfullyDescription.name.tr,
              textAlign: TextAlign.center,
              style: AppFontStyle.fontStyleW500(
                fontSize: 14,
                fontColor: AppColors.profileMail,
              ),
            ).paddingOnly(top: 10, bottom: 13),
            // const Spacer(),
            PrimaryAppButton(
              onTap: () {
                Get.offAllNamed(AppRoutes.hostRequestSentSuccessfullyScreen);
              },
              height: 47,
              borderRadius: 8,
              text: EnumLocale.txtViewRequest.name.tr,
              textStyle: AppFontStyle.fontStyleW600(
                fontSize: 17,
                fontColor: AppColors.white,
              ),
            ).paddingOnly(top: 20, bottom: 10),
          ],
        ).paddingOnly(top: 15, bottom: 15, left: 20, right: 20),
      ),
    );
  }
}
