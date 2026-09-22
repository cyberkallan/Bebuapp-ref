import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_bar/custom_app_bar.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/ui/host_flow/host_withdraw_coin_screen/controller/host_withdraw_coin_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class HostWithdrawCoinAppBar extends StatelessWidget {
  const HostWithdrawCoinAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(120),
      child: CustomAppBar(
        appBarColor: AppColors.lightPurple,
        // action: [
        //   Padding(
        //     padding: const EdgeInsets.all(16),
        //     child: Image.asset(AppAsset.withdrawTimeBookIcon),
        //   ),
        // ],
        title: EnumLocale.txtWithdrawCoin.name.tr,
        showLeadingIcon: true,
      ),
    );
  }
}

class HostWithdrawCoinTopView extends StatelessWidget {
  const HostWithdrawCoinTopView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 200,
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(AppAsset.withdrawBg), fit: BoxFit.cover),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.white.withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 6,
                  offset: Offset(1, 1),
                ),
              ],
            ),
            child: Center(
                child: Image.asset(
              AppAsset.starCoinBig,
              height: 114,
              width: 114,
            )),
          ),
          Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                EnumLocale.txtAvailableCoinBalance.name.tr,
                style: AppFontStyle.fontStyleW600(
                  fontSize: 14,
                  fontColor: AppColors.yellowDark800,
                  decorationColor: AppColors.yellowDark800,
                  textDecoration: TextDecoration.underline,
                ),
              ).paddingOnly(bottom: 6, top: 15),
              Text(
                Database.listenerCoin,
                style: AppFontStyle.fontStyleW900(fontSize: 44, fontColor: AppColors.yellowDark800),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      AppAsset.starCoin,
                      height: 26,
                      width: 26,
                    ).paddingOnly(right: 6),
                    Text(
                      "${Database.settingApiModel?.data?.minimumCoinsForConversion} Coin = ${Database.settingApiModel?.data?.currency?.symbol} 1.00",
                      style: AppFontStyle.fontStyleW700(fontSize: 16, fontColor: AppColors.orangeButton),
                    ).paddingOnly(right: 4),
                  ],
                ),
              ).paddingOnly(right: 14).paddingOnly(bottom: 20, top: 4),
            ],
          ),
        ],
      ).paddingOnly(bottom: 7, left: 12, right: 16, top: 7),
    );
  }
}

class HostWithdrawCoinView extends StatelessWidget {
  const HostWithdrawCoinView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HostWithdrawCoinController>(builder: (controller) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            EnumLocale.txtWalletGuide.name.tr,
            style: AppFontStyle.fontStyleW800(fontSize: 17, fontColor: AppColors.black),
          ).paddingOnly(top: 22, left: 16, right: 16),
          Text(
            EnumLocale.txtUserGuide.name.tr,
            style: AppFontStyle.fontStyleW500(fontSize: 11, fontColor: AppColors.profileText, height: 1.7),
          ).paddingOnly(top: 8, bottom: 24, left: 16, right: 16),
          Container(
            width: Get.width,
            decoration: BoxDecoration(color: AppColors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  EnumLocale.txtWithdrawalDetails.name.tr,
                  style: AppFontStyle.fontStyleW700(fontSize: 17, fontColor: AppColors.black),
                ).paddingOnly(top: 16, bottom: 16),

                TextFormField(
                  controller: controller.coinController,
                  keyboardType: TextInputType.number,
                  style: AppFontStyle.fontStyleW600(
                    fontSize: 13,
                    fontColor: AppColors.black,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), // Only digits allowed
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      Utils.showToast(Get.context!, "Please enter coins");
                      return '';
                    } else if (value.contains(' ') || value.contains('.')) {
                      Utils.showToast(Get.context!, "Invalid characters (space or .) not allowed");
                      return '';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.transparent),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.transparent),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.2)),
                    ),
                    fillColor: AppColors.white,
                    hintText: "Enter Coin",
                    hintStyle: AppFontStyle.fontStyleW500(
                      fontSize: 13,
                      fontColor: AppColors.black.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "${EnumLocale.txtMinimumWithdrawCoin.name.tr}${Database.settingApiModel?.data?.minimumCoinsForPayout}",
                    style: AppFontStyle.fontStyleW500(fontSize: 11, fontColor: AppColors.red),
                  ).paddingOnly(top: 8, bottom: 18),
                ),
                GetBuilder<HostWithdrawCoinController>(
                  builder: (controller) => GestureDetector(
                    onTap: controller.onSwitchWithdrawMethod,
                    child: Container(
                      height: 54,
                      width: Get.width,
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        // color: AppColors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.grey.withValues(alpha: 0.2)),
                      ),
                      child: controller.selectedPaymentMethod == null
                          ? Row(
                              children: [
                                // 5.width,
                                Text(
                                  EnumLocale.txtSelectPaymentGateway.name.tr,
                                  style: AppFontStyle.fontStyleW500(fontColor: AppColors.black.withValues(alpha: 0.3), fontSize: 14),
                                ),
                                Spacer(),
                                Icon(
                                  Icons.arrow_drop_down,
                                  size: 20,
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                SizedBox(
                                  width: 35,
                                  child: Center(
                                    child: CustomProfileImage(
                                      image: controller.withdrawMethods[controller.selectedPaymentMethod ?? 0].image ?? "",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                15.width,
                                Text(
                                  controller.withdrawMethods[controller.selectedPaymentMethod ?? 0].name ?? "",
                                  style: AppFontStyle.fontStyleW700(fontColor: AppColors.black, fontSize: 15),
                                ),
                                Spacer(),
                                Icon(Icons.arrow_drop_down)
                              ],
                            ),
                    ),
                  ),
                ),
                GetBuilder<HostWithdrawCoinController>(
                  builder: (controller) => AnimatedContainer(
                    duration: Duration(milliseconds: 1000),
                    height: controller.isShowPaymentMethod ? (controller.withdrawMethods.length * 70) : 0,
                    color: AppColors.transparent,
                    curve: Curves.linearToEaseOut,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          15.height,
                          for (int index = 0; index < controller.withdrawMethods.length; index++)
                            GestureDetector(
                              onTap: () => controller.onChangePaymentMethod(index),
                              child: Container(
                                height: 54,
                                width: Get.width,
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                margin: EdgeInsets.only(bottom: 15),
                                decoration: BoxDecoration(
                                  // color: AppColors.grey.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.grey.withValues(alpha: 0.2)),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 35,
                                      child: Center(
                                        child: CustomProfileImage(
                                          image: controller.withdrawMethods[index].image ?? "",
                                        ),
                                      ),
                                    ),
                                    15.width,
                                    Text(
                                      controller.withdrawMethods[index].name ?? "",
                                      style: AppFontStyle.fontStyleW700(fontColor: AppColors.black, fontSize: 15),
                                    ),
                                    Spacer(),
                                    // RadioItem(isSelected: controller.selectedPaymentMethod == index),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                15.height,
                GetBuilder<HostWithdrawCoinController>(
                  builder: (controller) => controller.selectedPaymentMethod == null
                      ? Offstage()
                      : Column(
                          children: [
                            for (int i = 0; i < controller.withdrawMethods[controller.selectedPaymentMethod ?? 0].details!.length; i++)
                              WithdrawDetailsItemUi(
                                title: controller.withdrawMethods[controller.selectedPaymentMethod ?? 0].details?[i] ?? "",
                                controller: controller.withdrawPaymentDetails[i],
                              ),
                          ],
                        ),
                ),
                PrimaryAppButton(
                  height: 47,
                  onTap: () {
                    controller.onClickWithdraw();
                  },
                  // borderRadius: 30,
                  child: Center(
                    child: Text(
                      EnumLocale.txtWithdrawCoin.name.tr,
                      style: AppFontStyle.fontStyleW600(fontSize: 16, fontColor: AppColors.white),
                    ),
                  ),
                ).paddingOnly(bottom: 16, top: 18) // borderRadius: 30,
              ],
            ).paddingOnly(left: 16, right: 16),
          ).paddingOnly(bottom: 10),
        ],
      );
    });
  }
}

class WithdrawDetailsItemUi extends StatelessWidget {
  const WithdrawDetailsItemUi({
    super.key,
    required this.title,
    required this.controller,
  });

  final String title;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppFontStyle.fontStyleW500(fontColor: AppColors.black.withValues(alpha: 0.3), fontSize: 13),
        ),
        5.height,
        TextFormField(
          maxLines: 1,
          keyboardType: TextInputType.name,
          controller: controller,
          style: AppFontStyle.fontStyleW700(fontColor: AppColors.black, fontSize: 14),
          cursorColor: AppColors.grey,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.transparent),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.transparent),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.grey.withValues(alpha: 0.2)),
            ),
            hintText: "Enter your ${title.toLowerCase()}...",
            hintStyle: AppFontStyle.fontStyleW400(fontColor: AppColors.grey, fontSize: 12),
          ),
        ).paddingOnly(bottom: 14),
      ],
    );
  }
}
