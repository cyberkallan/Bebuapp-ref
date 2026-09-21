import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/ui/user_flow/my_wallet_screen/controller/my_wallet_controller.dart';
import 'package:talk_in/ui/user_flow/my_wallet_screen/shimmer/coin_plan_shimmer.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

import '../model/fetch_coin_plan.dart';

class CoinPlanWidget extends GetView<MyWalletController> {
  const CoinPlanWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            EnumLocale.txtAddCoinBalanceSelectPlan.name.tr,
            style: AppFontStyle.fontStyleW800(
              fontSize: 17,
              fontColor: AppColors.black,
            ),
          ).paddingOnly(top: 22),
          22.height,
          GetBuilder<MyWalletController>(
            id: Constant.idGetCoinPlan,
            builder: (controller) {
              return controller.isLoading
                  ? CoinPlanShimmer()
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: controller.coinPlan.length,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            controller.selectedPaymentMethod = -1;
                            controller.update([Constant.onChangePaymentMethod]);
                            controller.selectedCoinPlan = controller.coinPlan[index];
                            controller.update([Constant.idGetCoinPlan]);
                            Utils.showLog('.,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,${controller.selectedCoinPlan?.productId.toString() ?? ' '}');

                            Get.bottomSheet(
                              PaymentOptionBottomSheet(index: index),
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent, // or keep AppColors.white if you're not wrapping in Container
                            );
                          },
                          child: CoinPlanTile(
                            coinPlan: controller.coinPlan[index],
                          ),
                        );
                      },
                    );
            },
          ),
        ],
      ).paddingSymmetric(horizontal: 14),
    );
  }
}

class PaymentOptionTile extends StatelessWidget {
  final int index;
  final double? width;
  final double? height;
  final String title;
  final String image;
  final MyWalletController controller;

  const PaymentOptionTile({
    super.key,
    required this.index,
    required this.title,
    required this.image,
    required this.controller,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = controller.selectedPaymentMethod == index;

    return InkWell(
      onTap: () => controller.onChangePaymentMethod(index),
      child: Container(
        height: 60,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(
            color: isSelected ? AppColors.appColor : AppColors.grey.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Image.asset(
              image,
              width: width ?? 50,
              height: height ?? 50,
              fit: BoxFit.contain,
            ),
            Text(
              title,
              style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: AppColors.black),
            ).paddingOnly(left: 16),
            const Spacer(),
            Container(
              height: 22,
              width: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.transparent : AppColors.grey,
                ),
                color: isSelected ? Colors.black : AppColors.white,
              ),
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.all(0.5),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.appColor,
                          border: Border.all(color: AppColors.white),
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class CoinPlanTile extends StatelessWidget {
  const CoinPlanTile({super.key, required this.coinPlan});

  final CoinPlan coinPlan;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.coinTileColor.withValues(alpha: 0.6),
            border: Border.all(color: AppColors.yellowBorder),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.yellowBorder),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  AppAsset.starCoin,
                  height: 41,
                  width: 41,
                ),
              ).paddingAll(6),
              Expanded(
                child: Text(
                  '${coinPlan.coins} coin',
                  style: AppFontStyle.fontStyleW700(
                    fontSize: 16,
                    fontColor: AppColors.yellowDark800,
                  ),
                ).paddingOnly(left: 6),
              ),
              Text(
                "${Database.settingApiModel?.data?.currency?.symbol} ${coinPlan.price}",
                style: AppFontStyle.fontStyleW700(
                  fontSize: 22,
                  fontColor: AppColors.darkOrange,
                ),
              ).paddingOnly(right: 14),
              RotatedBox(
                quarterTurns: 2,
                child: Image.asset(
                  AppAsset.backArrowIcon,
                  height: 12,
                  width: 12,
                  color: AppColors.yellowDark800,
                ),
              ).paddingOnly(right: 8),
            ],
          ),
        ).paddingOnly(bottom: 16),
        if (coinPlan.isPopular == true)
          Positioned(
            top: Get.height * -0.011,
            right: Get.width * 0.07,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.yellowBorder),
              ),
              child: Text(
                EnumLocale.txtMostPopularPlan.name.tr,
                style: AppFontStyle.fontStyleW600(fontSize: 10, fontColor: AppColors.darkOrange),
              ),
            ),
          ),
      ],
    );
  }
}

class PaymentOptionBottomSheet extends StatelessWidget {
  final int index;
  const PaymentOptionBottomSheet({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(16.0),
      child: GetBuilder<MyWalletController>(
        id: Constant.onChangePaymentMethod,
        builder: (controller) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                EnumLocale.txtPaymentMethod.name.tr,
                style: AppFontStyle.fontStyleW600(fontSize: 17, fontColor: AppColors.black),
              ).paddingOnly(bottom: 15, top: 5),

              if (Database.settingApiModel?.data?.isRazorpayEnabled == true)
                PaymentOptionTile(
                  index: 0,
                  title: "Razorpay",
                  controller: controller,
                  image: AppAsset.razorpay,
                ),
              if (Database.settingApiModel?.data?.isStripeEnabled == true)
                PaymentOptionTile(
                  index: 1,
                  title: "Stripe",
                  controller: controller,
                  image: AppAsset.stripe,
                ),
              if (Database.settingApiModel?.data?.isFlutterwaveEnabled == true)
                PaymentOptionTile(
                  index: 2,
                  title: "Flutterwave",
                  controller: controller,
                  image: AppAsset.flutterWave,
                ),
              if (Database.settingApiModel?.data?.isGooglePlayEnabled == true)
                PaymentOptionTile(
                  index: 3,
                  title: "In App Purchase",
                  controller: controller,
                  image: Platform.isIOS ? AppAsset.appStoreImage : AppAsset.googleIcon,
                  width: 50,
                  height: 26,
                  // width: Platform.isIOS == false ? 60 : 50,
                ),

              // _buildPaymentOption(
              //   context,
              //   index: 1,
              //   title: "Stripe",
              //   controller: controller,
              //   image: AppAsset.stripe,
              // ),
              // _buildPaymentOption(
              //   context,
              //   index: 2,
              //   title: "Flutterwave",
              //   controller: controller,
              //   image: AppAsset.flutterWave,
              // ),
              PrimaryAppButton(
                onTap: () {
                  log("message ${controller.coinPlan[index].id}");
                  log("message ${controller.selectedCoinPlan?.productId}");
                  controller.onClickPayNow(
                      id: controller.coinPlan[index].id ?? '',
                      amount: controller.coinPlan[index].price ?? 0,
                      productKey: controller.selectedCoinPlan?.productId ?? '');
                },
                height: 50,
                borderRadius: 30,
                text: EnumLocale.txtPay.name.tr,
                textStyle: AppFontStyle.fontStyleW600(fontSize: 16, fontColor: AppColors.white),
              ).paddingOnly(bottom: 10, top: 18),
            ],
          );
        },
      ),
    );
  }
}
