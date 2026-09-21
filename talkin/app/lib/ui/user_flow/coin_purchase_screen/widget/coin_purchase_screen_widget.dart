import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/coin_purchase_screen/controller/coin_purchase_screen_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class CoinPurchaseTopView extends StatelessWidget {
  const CoinPurchaseTopView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            AppAsset.callCutBg,
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              "Congratulations on taking a step towards combating loneliness",
              style: AppFontStyle.fontStyleW700(
                fontSize: 18,
                fontColor: Colors.white,
              ),
            ).paddingOnly(left: 16, top: 75, right: 3, bottom: 18),
          ),
          Image.asset(
            AppAsset.requestSentImage,
            height: 100,
          ).paddingOnly(right: 20, top: 45, bottom: 6),
        ],
      ),
    );
  }
}

class CoinPurchaseView extends StatelessWidget {
  const CoinPurchaseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GetBuilder<CoinPurchaseScreenController>(builder: (controller) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 18),
            width: Get.width,
            decoration: BoxDecoration(color: Colors.white),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      EnumLocale.txtAmountCredited.name.tr,
                      style: AppFontStyle.fontStyleW500(fontSize: 16, fontColor: Colors.black),
                    ),
                    Text(
                      "${Database.settingApiModel?.data?.currency?.symbol}${controller.amountPaid ?? 0}",
                      style: AppFontStyle.fontStyleW800(fontSize: 20, fontColor: Colors.black),
                    ),
                  ],
                ),
                Image.asset(
                  AppAsset.wallet,
                  height: 60,
                  width: 60,
                ),
              ],
            ),
          ).paddingOnly(bottom: 6);
        }),
        GetBuilder<CoinPurchaseScreenController>(builder: (controller) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 18),
            width: Get.width,
            decoration: BoxDecoration(color: Colors.white),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CoinPurchaseDetailContainer(
                        title: EnumLocale.txtDate.name.tr,
                        image: AppAsset.calendar,
                        subTitle: controller.date ?? '_ _',
                      ),
                    ),
                    12.width,
                    Expanded(
                      child: CoinPurchaseDetailContainer(
                        title: EnumLocale.txtAmountPaid.name.tr,
                        image: AppAsset.amountIcon,
                        height: 30,
                        width: 30,
                        subTitle: "${Database.settingApiModel?.data?.currency?.symbol}${controller.amountPaid ?? 0}",
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: CoinPurchaseDetailContainer(
                        title: EnumLocale.txtPaymentMode.name.tr,
                        image: AppAsset.paymentMode,
                        height: 30,
                        width: 30,
                        subTitle: controller.paymentMode ?? "_ _",
                      ).paddingOnly(top: 18),
                    ),
                    12.width,
                    Expanded(
                      child: CoinPurchaseDetailContainer(
                        title: EnumLocale.txtTransactionId.name.tr,
                        image: AppAsset.transactionId,
                        subTitle: controller.transactionId ?? "_ _",
                      ).paddingOnly(top: 18),
                    ),
                  ],
                ),
              ],
            ),
          ).paddingOnly(bottom: 6);
        }),
      ],
    );
  }
}

class CoinPurchaseDetailContainer extends StatelessWidget {
  final IconData? icon; // Icon input (optional)
  final String? image; // Image input (optional)
  final String title;
  final String subTitle;
  final double? height;
  final double? width;
  const CoinPurchaseDetailContainer({super.key, this.icon, required this.title, required this.subTitle, this.image, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.grey,
          ),
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          if (icon != null)
            Icon(
              icon,
              color: AppColors.appColor,
              size: 20,
            ),
          if (image != null)
            Image.asset(
              image!.toString(),
              height: height ?? 24,
              width: width ?? 24,
              fit: BoxFit.contain,
            ),
          8.width,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppFontStyle.fontStyleW500(
                  fontSize: 11,
                  fontColor: AppColors.profileText.withValues(alpha: 0.6),
                ),
              ),
              Text(
                subTitle,
                style: AppFontStyle.fontStyleW500(
                  fontSize: 13,
                  fontColor: AppColors.black,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
