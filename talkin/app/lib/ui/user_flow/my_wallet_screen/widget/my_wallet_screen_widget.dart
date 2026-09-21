import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/my_wallet_screen/controller/my_wallet_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class MyWalletScreenTopView extends StatelessWidget {
  const MyWalletScreenTopView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(AppAsset.walletBg), fit: BoxFit.cover),
      ),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  Get.back();
                },
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Image.asset(
                    height: 16,
                    AppAsset.backArrowIcon,
                    color: AppColors.white,
                  ),
                ),
              ),
              Spacer(),
              Text(
                EnumLocale.txtMyWallet.name.tr,
                style: AppFontStyle.fontStyleW600(fontSize: 20, fontColor: AppColors.white),
              ).paddingOnly(right: Get.width * 0.16),
              Spacer(),
            ],
          ).paddingOnly(bottom: 10),
          GetBuilder<MyWalletController>(
              id: Constant.idGetCoinPlan,
              builder: (controller) {
                return Container(
                  padding: EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        AppAsset.walletCross,
                        height: 147,
                        width: 147,
                      ).paddingOnly(right: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: Get.width * 0.45,
                            child: FittedBox(
                              child: Text(
                                EnumLocale.txtCurrentCoinBalance.name.tr,
                                // overflow: TextOverflow.ellipsis,
                                style: AppFontStyle.fontStyleW600(
                                  fontSize: 14,
                                  fontColor: AppColors.yellowDark800,
                                  decorationColor: AppColors.yellowDark800,
                                  textDecoration: TextDecoration.underline,
                                ),
                              ).paddingOnly(bottom: 6, top: 15),
                            ),
                          ),
                          Text(
                            "${controller.fetchCoinPlan?.userCoin ?? 0}",
                            style: AppFontStyle.fontStyleW900(fontSize: 44, fontColor: AppColors.yellowDark800),
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.toNamed(AppRoutes.coinHistoryScreen);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 2, vertical: 7),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    EnumLocale.txtViewCoinHistory.name.tr,
                                    style: AppFontStyle.fontStyleW600(fontSize: 12, fontColor: AppColors.yellowDark800),
                                  ).paddingOnly(left: 6, right: 6),
                                  RotatedBox(
                                    quarterTurns: 2,
                                    child: Image.asset(
                                      AppAsset.backArrowIcon,
                                      height: 10,
                                      width: 10,
                                      color: AppColors.yellowDark800,
                                    ),
                                  ).paddingOnly(right: 4),
                                ],
                              ),
                            ).paddingOnly(right: 14),
                          ).paddingOnly(top: 4, bottom: 14),
                        ],
                      ),
                    ],
                  ),
                ).paddingOnly(bottom: 24, left: 20, right: 20);
              }),
        ],
      ).paddingOnly(top: Get.height * 0.042),
    );
  }
}

class WalletGuideView extends StatelessWidget {
  const WalletGuideView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          EnumLocale.txtWalletGuide.name.tr,
          style: AppFontStyle.fontStyleW800(fontSize: 17, fontColor: AppColors.black),
        ),
        Text(
          EnumLocale.txtUserGuide.name.tr,
          // "1. Your wallet balance represents the number of coins available in your account. These coins can be used to access premium features, connect with listeners, or make in-app purchases.\n\n2. You can top up your coin balance by selecting a plan from the options below. Each plan offers a different coin-to-dollar rate, so choose the one that best fits your needs.\n\n3. The more coins you buy, the better the value. Higher plans often come with bonus coins or special offers. Make sure to check for the 'Most Popular Plan' tag for recommended choices.",
          style: AppFontStyle.fontStyleW500(fontSize: 11, fontColor: AppColors.profileText, height: 1.7),
        ).paddingOnly(top: 8),
      ],
    ).paddingSymmetric(horizontal: 14);
  }
}
