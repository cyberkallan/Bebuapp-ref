import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_bar/custom_app_bar.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/custom/range_picker/custom_range_picker.dart';
import 'package:talk_in/ui/user_flow/coin_history_screen/controller/coin_history_screen_controller.dart';
import 'package:talk_in/ui/user_flow/coin_history_screen/shimmer/coin_history_shimmer.dart';
import 'package:talk_in/ui/user_flow/coin_history_screen/shimmer/payment_history_shimmer.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class CoinHistoryScreenAppBar extends StatelessWidget {
  const CoinHistoryScreenAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(120),
      child: CustomAppBar(
        appBarColor: AppColors.lightPurple,
        title: EnumLocale.txtHistory.name.tr,
        showLeadingIcon: true,
      ),
    );
  }
}

class CoinHistoryScreenTabBar extends StatelessWidget {
  const CoinHistoryScreenTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CoinHistoryScreenController>(
      id: Constant.idTabChange, // Listen for tab switch and content change
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              height: Get.height * 0.06,
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: AppColors.borderColor),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.changeTab(0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: controller.tabIndex == 0 ? Colors.black : Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          EnumLocale.txtPayment.name.tr,
                          style: controller.tabIndex == 0
                              ? AppFontStyle.fontStyleW600(
                                  fontSize: 14,
                                  fontColor: AppColors.white,
                                )
                              : AppFontStyle.fontStyleW500(
                                  fontSize: 14,
                                  fontColor: AppColors.profileText,
                                ),
                        ),
                      ).paddingAll(controller.tabIndex == 0 ? 2 : 0),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => controller.changeTab(1),
                      child: Container(
                        decoration: BoxDecoration(
                          color: controller.tabIndex == 1 ? Colors.black : Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          EnumLocale.txtCoin.name.tr,
                          style: controller.tabIndex == 1
                              ? AppFontStyle.fontStyleW600(
                                  fontSize: 14,
                                  fontColor: AppColors.white,
                                )
                              : AppFontStyle.fontStyleW500(
                                  fontSize: 14,
                                  fontColor: AppColors.profileText,
                                ),
                        ),
                      ).paddingAll(controller.tabIndex == 1 ? 2 : 0),
                    ),
                  ),
                ],
              ),
            ),
            10.height,
            Row(
              children: [
                Text(EnumLocale.txtSelectDate.name.tr, style: AppFontStyle.fontStyleW500(fontSize: 14, fontColor: AppColors.black)),
                Spacer(),
                GetBuilder<CoinHistoryScreenController>(
                  id: Constant.idTabChange,
                  builder: (controller) {
                    String displayText = EnumLocale.txtAll.name.tr;

                    if (controller.tabIndex == 0 && controller.selectedPaymentDateRange != null) {
                      final range = controller.selectedPaymentDateRange!;
                      displayText = "${Utils.formatShortDate(range.start)} - ${Utils.formatShortDate(range.end)}";
                    } else if (controller.tabIndex == 1 && controller.selectedCoinDateRange != null) {
                      final range = controller.selectedCoinDateRange!;
                      displayText = "${Utils.formatShortDate(range.start)} - ${Utils.formatShortDate(range.end)}";
                    }

                    return GestureDetector(
                      onTap: () async {
                        final picked = await CustomRangePicker.onShow(
                          context,
                          controller.tabIndex == 0 ? controller.selectedPaymentDateRange : controller.selectedCoinDateRange,
                        );
                        if (picked != null) {
                          controller.applyDateFilter(picked.start, picked.end);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.lightGrey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Text(
                              displayText,
                              style: AppFontStyle.fontStyleW500(fontSize: 14, fontColor: AppColors.black),
                            ),
                            Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: AppColors.black),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                12.width,
                Visibility(
                  visible: (controller.tabIndex == 0 && controller.selectedPaymentDateRange != null) ||
                      (controller.tabIndex == 1 && controller.selectedCoinDateRange != null),
                  child: GestureDetector(
                    onTap: () {
                      controller.clearDateFilter();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.lightGrey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.asset(
                        AppAsset.filterClearIcon,
                        height: 20,
                        width: 20,
                      ),
                    ),
                  ),
                )
              ],
            ).paddingSymmetric(horizontal: 16),
            16.height,
          ],
        );
      },
    );
  }
}

class CoinHistoryScreenTabBarScreen extends StatelessWidget {
  const CoinHistoryScreenTabBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CoinHistoryScreenController>(
      id: Constant.idTabChange,
      builder: (controller) {
        return Expanded(
          child: controller.tabIndex == 0
              ? controller.purchaseCoinPlanModel?.data?.isEmpty == true
                  ? SizedBox(
                      height: 100,
                      child: Image.asset(
                        AppAsset.noHistoryFound,
                      )).paddingAll(90)
                  : paymentHistoryList(controller)
              : (controller.coinHistoryModel!.data!.isEmpty || controller.coinHistoryList.isEmpty)
                  ? SizedBox(
                      height: 100,
                      child: Image.asset(
                        AppAsset.noHistoryFound,
                      )).paddingAll(6090)
                  : coinHistoryList(controller),
        );
      },
    );
  }

  Widget paymentHistoryList(CoinHistoryScreenController controller) {
    return GetBuilder<CoinHistoryScreenController>(
        id: Constant.idTabChange,
        builder: (controller) {
          return controller.isLoading
              ? PaymentHistoryShimmer()
              : Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.10),
                        offset: Offset(0, 0),
                        blurRadius: 14,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: RefreshIndicator(
                    onRefresh: () async => controller.onPaymentRefresh(),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: Text(
                                EnumLocale.txtDetails.name.tr,
                                style: AppFontStyle.fontStyleW500(fontSize: 12, fontColor: AppColors.profileMail),
                              ),
                            ),

                            Expanded(
                              flex: 2,
                              child: Text(
                                textAlign: TextAlign.center,
                                EnumLocale.txtPaymentGetway.name.tr,
                                style: AppFontStyle.fontStyleW500(fontSize: 12, fontColor: AppColors.profileMail),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                textAlign: TextAlign.center,
                                EnumLocale.txtCoin.name.tr,
                                style: AppFontStyle.fontStyleW500(fontSize: 12, fontColor: AppColors.profileMail),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                textAlign: TextAlign.center,
                                EnumLocale.txtAmount.name.tr,
                                style: AppFontStyle.fontStyleW500(fontSize: 12, fontColor: AppColors.profileMail),
                              ),
                            ),
                            // SizedBox(
                            //   width: Get.width * 0.11,
                            //   child: Text(
                            //     EnumLocale.txtInvoice.name.tr,
                            //     style: AppFontStyle.fontStyleW500(fontSize: 12, fontColor: AppColors.profileMail),
                            //   ),
                            // ),
                          ],
                        ).paddingSymmetric(horizontal: 16, vertical: 14),
                        Divider(
                          color: AppColors.lightGrey,
                          height: 0,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  physics: AlwaysScrollableScrollPhysics(),
                                  controller: controller.scrollController1,
                                  itemCount: controller.purchaseCoinPlanModel?.data?.length,
                                  itemBuilder: (context, index) {
                                    final item = controller.purchaseCoinPlanModel?.data?[index];
                                    return Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 5,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item?.uniqueId.toString() ?? '',
                                                    style: AppFontStyle.fontStyleW600(
                                                      fontSize: 14,
                                                      fontColor: AppColors.black,
                                                    ),
                                                  ).paddingOnly(bottom: 3),
                                                  Text(
                                                    item?.date ?? '',
                                                    style: AppFontStyle.fontStyleW500(fontSize: 11, fontColor: AppColors.profileText),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                textAlign: TextAlign.center,
                                                item?.paymentGateway ?? '',
                                                style: AppFontStyle.fontStyleW500(
                                                  fontSize: 13,
                                                  fontColor: AppColors.black,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                                flex: 1,
                                                child: Text(
                                                  item?.userCoin.toString() ?? '',
                                                  textAlign: TextAlign.center,
                                                  style: AppFontStyle.fontStyleW600(fontSize: 13, fontColor: AppColors.black),
                                                )),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                textAlign: TextAlign.center,
                                                "${Database.settingApiModel?.data?.currency?.symbol}${item?.price ?? ''}",
                                                style: AppFontStyle.fontStyleW700(
                                                  fontSize: 16,
                                                  fontColor: AppColors.darkOrange,
                                                ),
                                              ),
                                            ),
                                            // SizedBox(
                                            //   width: Get.width * 0.11,
                                            //   child: Image.asset(
                                            //     AppAsset.downloadIcon,
                                            //     height: 23,
                                            //     width: 23,
                                            //   ).paddingOnly(left: Get.width * 0.02),
                                            // ),
                                          ],
                                        ).paddingSymmetric(horizontal: 14, vertical: 14),
                                        Divider(
                                          color: AppColors.historyDivider,
                                          height: 0,
                                          thickness: 0.8,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              GetBuilder<CoinHistoryScreenController>(
                                id: Constant.idPaginationListener,
                                builder: (controller) => Visibility(
                                  visible: controller.isPaginationLoading,
                                  child: CircularProgressIndicator(color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ).paddingOnly(left: 10, right: 10, top: 8);
        });
  }

  Widget coinHistoryList(CoinHistoryScreenController controller) {
    return GetBuilder<CoinHistoryScreenController>(
        id: Constant.idTabChange,
        builder: (controller) {
          return controller.isLoading
              ? CoinHistoryShimmer()
              : Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.10),
                        offset: Offset(0, 0),
                        blurRadius: 14,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            EnumLocale.txtDetails.name.tr,
                            style: AppFontStyle.fontStyleW500(fontSize: 12, fontColor: AppColors.profileMail),
                          ),
                          Text(
                            textAlign: TextAlign.center,
                            EnumLocale.txtCoin.name.tr,
                            style: AppFontStyle.fontStyleW500(fontSize: 12, fontColor: AppColors.profileMail),
                          ),
                          // SizedBox(
                          //   width: Get.width * 0.14,
                          //   child: Text(
                          //     textAlign: TextAlign.center,
                          //     EnumLocale.txtCoin.name.tr,
                          //     style: AppFontStyle.fontStyleW500(fontSize: 12, fontColor: AppColors.profileMail),
                          //   ),
                          // ),
                        ],
                      ).paddingSymmetric(horizontal: 16, vertical: 14),
                      Divider(
                        color: AppColors.lightGrey,
                        height: 0,
                      ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async => controller.onRefresh(),
                          child: Column(
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  physics: AlwaysScrollableScrollPhysics(),
                                  controller: controller.scrollController,
                                  itemCount: controller.coinHistoryList.length, // Safe count
                                  itemBuilder: (context, index) {
                                    final item = controller.coinHistoryList[index];
                                    return Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    height: 40,
                                                    width: 40,
                                                    child: ClipOval(
                                                        child: CustomProfileImage(
                                                      image:
                                                          item.type == 1 || item.type == 2 ? Database.loginUserProfilePic : item.receiverImage ?? '',
                                                    )),
                                                  ).paddingOnly(right: 10),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        item.type == 1 || item.type == 2 ? Database.loginUserName : item.receiverName ?? '',
                                                        style: AppFontStyle.fontStyleW700(
                                                          fontSize: 13,
                                                          fontColor: AppColors.black,
                                                        ),
                                                      ).paddingOnly(bottom: 3),
                                                      Row(
                                                        children: [
                                                          Image.asset(
                                                            item.type == 2
                                                                ? AppAsset.coinPurchaseIcon
                                                                : item.type == 3
                                                                    ? AppAsset.callIcon
                                                                    : item.type == 4
                                                                        ? AppAsset.videoCallIcon
                                                                        : item.type == 5
                                                                            ? AppAsset.callIcon
                                                                            : item.type == 6
                                                                                ? AppAsset.videoCallIcon
                                                                                : AppAsset.loginBonusIcon,
                                                            color: AppColors.historyCallType,
                                                            height: 12,
                                                            width: 12,
                                                            fit: BoxFit.fill,
                                                          ).paddingOnly(right: 4),
                                                          Text(
                                                            item.type == 2
                                                                ? "Coin Purchase"
                                                                : item.type == 3
                                                                    ? "Private audio call"
                                                                    : item.type == 4
                                                                        ? "private video call"
                                                                        : item.type == 5
                                                                            ? "Random audio call"
                                                                            : item.type == 6
                                                                                ? "Random video call"
                                                                                : "Log In Bonus",
                                                            style: AppFontStyle.fontStyleW500(fontSize: 11, fontColor: AppColors.historyCallType),
                                                          ).paddingOnly(right: 6),
                                                          Text(
                                                            textAlign: TextAlign.center,
                                                            item.type == 1 || item.type == 2
                                                                ? ""
                                                                : item.duration == null
                                                                    ? ''
                                                                    : "${item.duration}",
                                                            style: AppFontStyle.fontStyleW600(
                                                              fontSize: 11,
                                                              fontColor: AppColors.darkOrange,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  textAlign: TextAlign.center,
                                                  "${item.isIncome == true ? '+' : '-'} ${item.userCoin}",
                                                  style: AppFontStyle.fontStyleW700(
                                                    fontSize: 13,
                                                    fontColor: item.isIncome == true ? AppColors.green : AppColors.red,
                                                  ),
                                                ).paddingOnly(bottom: 4),
                                                Text(
                                                  item.date.toString(),
                                                  style: AppFontStyle.fontStyleW500(fontSize: 10, fontColor: AppColors.profileMail),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ).paddingOnly(right: 14, bottom: 14, top: 14, left: 10),
                                        Divider(
                                          color: AppColors.historyDivider,
                                          height: 0,
                                          thickness: 0.8,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              GetBuilder<CoinHistoryScreenController>(
                                id: Constant.idPaginationListener,
                                builder: (controller) => Visibility(
                                  visible: controller.isPaginationLoading,
                                  child: CircularProgressIndicator(color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ).paddingOnly(left: 10, right: 10, top: 8);
        });
  }
}
