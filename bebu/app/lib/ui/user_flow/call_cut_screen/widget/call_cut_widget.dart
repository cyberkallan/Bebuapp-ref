import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/custom/bottom_sheet/share_app_bottom_sheet.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/call_cut_screen/controller/call_cut_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class CallCutView extends StatelessWidget {
  const CallCutView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CallCutController>(builder: (controller) {
      return Column(
        children: [
          Container(
            // height: Get.height * 0.2,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  AppAsset.callCutBg,
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "${EnumLocale.txtCompleteTrailCall.name.tr} ${controller.receiverName ?? ''} ${EnumLocale.txtCompleteTrailCall1.name.tr}",
                    style: AppFontStyle.fontStyleW700(
                      fontSize: 22,
                      fontColor: AppColors.white,
                    ),
                  ),
                ),
                Image.asset(
                  AppAsset.callIcon,
                  height: 68,
                  color: Colors.white,
                )
              ],
            ).paddingOnly(left: 16, right: 16, top: 74, bottom: 34),
          ).paddingOnly(bottom: 8),
          Container(
            padding: EdgeInsets.symmetric(vertical: 21, horizontal: 20),
            color: AppColors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    DottedBorder(
                      borderType: BorderType.Circle,
                      color: Colors.black,
                      dashPattern: [3, 2],
                      strokeWidth: 1,
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        height: Get.height * 0.06,
                        width: Get.height * 0.06,
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey,
                          shape: BoxShape.circle,
                        ),
                        child: CustomProfileImage(image: controller.receiverImage ?? '', fit: BoxFit.cover),
                      ),
                    ).paddingOnly(right: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Listener",
                          style: AppFontStyle.fontStyleW500(fontSize: 15, fontColor: AppColors.darkGrey.withValues(alpha: 0.8)),
                        ).paddingOnly(bottom: 4),
                        Text(
                          controller.receiverName ?? '',
                          style: AppFontStyle.fontStyleW700(fontSize: 17, fontColor: AppColors.black),
                        )
                      ],
                    ),
                    Spacer(),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: CallDetailContainer(
                        title: EnumLocale.txtDate.name.tr,
                        image: AppAsset.calendar,
                        subTitle: controller.date ?? '',
                      ).paddingOnly(top: 25),
                    ),
                    12.width,
                    Expanded(
                      child: CallDetailContainer(
                        title: EnumLocale.txtDuration.name.tr,
                        icon: Icons.access_time_filled_rounded,
                        subTitle: controller.callDuration ?? "",
                      ).paddingOnly(top: 25),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: CallDetailContainer(
                        title: EnumLocale.txtBalanceused.name.tr,
                        // icon: Icons.calendar_month,
                        image: AppAsset.wallet,
                        subTitle: controller.usedBalance ?? "_ _",
                      ).paddingOnly(top: 18),
                    ),
                    12.width,
                    Expanded(
                      child: CallDetailContainer(
                        title: EnumLocale.txtCallId.name.tr,
                        image: AppAsset.callIconBlack,
                        subTitle: controller.callId ?? "",
                      ).paddingOnly(top: 18),
                    ),
                  ],
                ),
              ],
            ),
          ).paddingOnly(bottom: 8),
          Container(
            padding: EdgeInsets.symmetric(vertical: 21, horizontal: 20),
            color: AppColors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  EnumLocale.txtDidYouLikeService.name.tr,
                  style: AppFontStyle.fontStyleW500(fontSize: 15, fontColor: AppColors.black),
                ).paddingOnly(bottom: 18),
                GetBuilder<CallCutController>(
                  builder: (controller) {
                    return Row(
                      children: [
                        PrimaryAppButton(
                          width: Get.width * 0.2,
                          height: Get.height * 0.045,
                          color: AppColors.transparent,
                          borderColor: controller.listenerService == 'yes' ? AppColors.black : AppColors.lightGrey,
                          text: EnumLocale.txtYes.name.tr,
                          textStyle: AppFontStyle.fontStyleW500(
                            fontSize: 14,
                            fontColor: controller.favListener == 'yes' ? AppColors.black : AppColors.profileMail,
                          ),
                          onTap: () => controller.listenerServiceSelect('yes'),
                        ).paddingOnly(right: 16),
                        PrimaryAppButton(
                          width: Get.width * 0.2,
                          height: Get.height * 0.045,
                          color: AppColors.transparent,
                          borderColor: controller.listenerService == 'no' ? AppColors.black : AppColors.lightGrey,
                          text: EnumLocale.txtNo.name.tr,
                          textStyle: AppFontStyle.fontStyleW500(
                            fontSize: 14,
                            fontColor: controller.favListener == 'no' ? AppColors.black : AppColors.profileMail,
                          ),
                          onTap: () => controller.listenerServiceSelect('no'),
                        ),
                      ],
                    );
                  },
                )
              ],
            ),
          ).paddingOnly(bottom: 8),
          Container(
            padding: EdgeInsets.symmetric(vertical: 21, horizontal: 20),
            color: AppColors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Add ${controller.receiverName} to your Favourite Listeners?",
                  style: AppFontStyle.fontStyleW500(fontSize: 15, fontColor: AppColors.black),
                ).paddingOnly(bottom: 18),
                GetBuilder<CallCutController>(
                  builder: (controller) {
                    return Row(
                      children: [
                        PrimaryAppButton(
                          width: Get.width * 0.2,
                          height: Get.height * 0.045,
                          color: AppColors.transparent,
                          borderColor: controller.favListener == 'yes' ? AppColors.black : AppColors.lightGrey,
                          text: EnumLocale.txtYes.name.tr,
                          textStyle: AppFontStyle.fontStyleW500(
                            fontSize: 14,
                            fontColor: controller.favListener == 'yes' ? AppColors.black : AppColors.profileMail,
                          ),
                          onTap: () => controller.favListenerSelect('yes'),
                        ).paddingOnly(right: 16),
                        PrimaryAppButton(
                          width: Get.width * 0.2,
                          height: Get.height * 0.045,
                          color: AppColors.transparent,
                          borderColor: controller.favListener == 'no' ? AppColors.black : AppColors.lightGrey,
                          text: EnumLocale.txtNo.name.tr,
                          textStyle: AppFontStyle.fontStyleW500(
                            fontSize: 14,
                            fontColor: controller.favListener == 'no' ? AppColors.black : AppColors.profileMail,
                          ),
                          onTap: () => controller.favListenerSelect('no'),
                        ),
                      ],
                    );
                  },
                )
              ],
            ),
          ).paddingOnly(bottom: 8),
          Container(
            padding: EdgeInsets.symmetric(vertical: 21, horizontal: 20),
            color: AppColors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        EnumLocale.txtShareListenersApp.name.tr,
                        style: AppFontStyle.fontStyleW700(fontSize: 18, fontColor: AppColors.black),
                      ).paddingOnly(bottom: 4),
                      Text(
                        EnumLocale.txtShareListenersAppDescription.name.tr,
                        style: AppFontStyle.fontStyleW500(fontSize: 14, fontColor: AppColors.darkGrey.withValues(alpha: 0.8)),
                      ).paddingOnly(bottom: 14),
                      PrimaryAppButton(
                        onTap: () {
                          controller.onClickShare();
                        },
                        width: Get.width * 0.38,
                        height: 40,
                        color: AppColors.orange200,
                        borderColor: AppColors.transparent,
                        text: EnumLocale.txtShareAppNow.name.tr,
                        textStyle: AppFontStyle.fontStyleW600(fontSize: 14, fontColor: AppColors.white),
                      ).paddingOnly(bottom: 6),
                    ],
                  ),
                ),
                Image.asset(
                  AppAsset.shareApp,
                  height: 98,
                  width: 98,
                ),
              ],
            ),
          ).paddingOnly(bottom: 8),
        ],
      );
    });
  }
}

class BottomView extends StatelessWidget {
  const BottomView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: Offset(0, 0),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: PrimaryAppButton(
                  onTap: () {
                    Get.toNamed(AppRoutes.bottomBar);
                  },
                  height: 50,
                  color: AppColors.white,
                  borderColor: AppColors.appColor,
                  // borderRadius: 30,
                  text: EnumLocale.txtSkip.name.tr,
                  textStyle: AppFontStyle.fontStyleW600(fontSize: 16, fontColor: AppColors.appColor),
                ),
              ),
              8.width,
              Expanded(
                child: PrimaryAppButton(
                  onTap: () {
                    if (Get.isBottomSheetOpen!) {
                      Get.back(); // Close any open bottom sheet before opening a new one
                    }
                    Get.bottomSheet(
                      ShareAppBottomSheet(),
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                    );
                  },
                  height: 50,
                  // borderRadius: 30,
                  text: EnumLocale.txtFeedBack.name.tr,
                  textStyle: AppFontStyle.fontStyleW600(fontSize: 16, fontColor: AppColors.white),
                ),
              ),
            ],
          ).paddingOnly(bottom: 10),
        ],
      ),
    );
  }
}

class CallDetailContainer extends StatelessWidget {
  final IconData? icon; // Icon input (optional)
  final String? image; // Image input (optional)
  final String title;
  final String subTitle;

  const CallDetailContainer({
    super.key,
    this.icon,
    this.image,
    required this.title,
    required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CallCutController>(builder: (controller) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
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
                height: 24,
                width: 24,
                fit: BoxFit.contain,
              ),
            8.width,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFontStyle.fontStyleW500(
                    fontSize: 13,
                    fontColor: AppColors.profileText,
                  ),
                ),
                Text(
                  subTitle,
                  style: AppFontStyle.fontStyleW500(
                    fontSize: 15,
                    fontColor: AppColors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
