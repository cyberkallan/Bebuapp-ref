import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class HostRateUsBottomSheet extends StatelessWidget {
  const HostRateUsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 17, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Spacer(),
              Text(
                EnumLocale.txtRateUs.name.tr,
                style: AppFontStyle.fontStyleW700(
                  fontSize: 18,
                  fontColor: AppColors.black,
                ),
              ).paddingOnly(left: 30, bottom: 25),
              Spacer(),
              InkWell(
                onTap: () {
                  Get.back();
                },
                child: Image.asset(
                  AppAsset.closeFillIcon,
                  height: 26,
                ),
              )
            ],
          ),
          Image.asset(
            AppAsset.rateStar,
            width: 118,
            height: 118,
          ).paddingOnly(bottom: 28),
          Text(
            EnumLocale.txtRateYourExperienceWithUs.name.tr,
            style: AppFontStyle.fontStyleW700(
              fontSize: 18,
              fontColor: AppColors.darkOrange,
            ),
          ).paddingOnly(bottom: 26),
          Image.asset(
            AppAsset.ratingImage,
            width: 264,
            height: 32,
          ).paddingOnly(bottom: 18),
        ],
      ),
    );
  }
}
