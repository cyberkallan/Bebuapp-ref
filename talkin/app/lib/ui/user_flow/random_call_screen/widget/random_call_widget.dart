import 'dart:developer';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/edit_profile_screen/controller/edit_profile_screen_controller.dart';
import 'package:talk_in/ui/user_flow/home_screen/api/user_coin_api.dart';
import 'package:talk_in/ui/user_flow/random_call_screen/controller/random_call_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class RandomCallTopView extends StatelessWidget {
  const RandomCallTopView({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GetBuilder<RandomCallController>(
            id: Constant.idGetListener,
            builder: (controller) {
              return DottedBorder(
                borderType: BorderType.Circle,
                color: Colors.black,
                dashPattern: [3, 2],
                strokeWidth: 1,
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed(AppRoutes.myProfileScreen)?.then(
                      (value) {
                        // controller.randomCall = false;
                        // controller.update([Constant.idGetListener]);
                        // Utils.showLog("Random call ============= ${controller.randomCall}");
                      },
                    );
                  },
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    height: Get.height * 0.06,
                    width: Get.height * 0.06,
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey,
                      shape: BoxShape.circle,
                    ),
                    child: CustomProfileImage(
                      image: Database.loginUserProfilePic,
                    ),
                  ),
                ),
              ).paddingOnly(right: 10);
            }),
        GetBuilder<EditProfileController>(
            id: Constant.idProfile,
            builder: (context) {
              return Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Database.loginUserName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFontStyle.fontStyleW700(fontSize: 16, fontColor: AppColors.black),
                    ),
                    Text(
                      Database.loginType == 2 ? Database.loginUserNickName : Database.loginUserEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFontStyle.fontStyleW600(fontSize: 14, fontColor: AppColors.black),
                    )
                  ],
                ),
              );
            }),
        // Spacer(),
        8.width,
        GetBuilder<RandomCallController>(
            // id: Constant.idCoinUpdate,
            builder: (controller) {
          return GestureDetector(
            onTap: () {
              log("go to wallet screen");
              Get.toNamed(AppRoutes.myWalletScreen)?.then(
                (value) {
                  // controller.randomCall = false;
                  // controller.update([Constant.idGetListener]);
                },
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 2).copyWith(left: 10),
              decoration: BoxDecoration(
                color: Color(0xffFFFDF1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.randomCallCoin,
                ),
              ),
              child: GestureDetector(
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          Database.userCoin.toString(),
                          style: AppFontStyle.fontStyleW700(fontSize: 18, fontColor: AppColors.randomCallCoin),
                        ),
                        Text(
                          EnumLocale.txtMyBalance.name.tr,
                          style: AppFontStyle.fontStyleW600(fontSize: 14, fontColor: AppColors.randomCallCoin),
                        )
                      ],
                    ),
                    Image.asset(
                      AppAsset.starCoin,
                      height: 32,
                      width: 32,
                    ).paddingAll(8),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    ).paddingOnly(top: Get.height * 0.048, left: 18, right: 18);
  }
}

class BottomButtonsView extends StatelessWidget {
  const BottomButtonsView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RandomCallController>(builder: (controller) {
      return Column(
        children: [
          Center(
            child: Container(
              decoration: BoxDecoration(
                  boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.10), offset: Offset(0, 0), blurRadius: 18, spreadRadius: 0)]),
              child: PrimaryAppButton(
                borderColor: AppColors.lightGrey,
                color: AppColors.white,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => const ConnectCallDialog(),
                  );
                },
                width: Get.width * 0.4,
                height: Get.height * 0.047,
                borderRadius: 30,
                textStyle: AppFontStyle.fontStyleW600(fontSize: 16, fontColor: AppColors.white),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      AppAsset.callGradiant,
                      height: 19,
                      width: 19,
                    ),
                    Text(
                      controller.selectedIndex == 0
                          ? EnumLocale.txtAudioCall.name.tr
                          : controller.selectedIndex == 1
                              ? EnumLocale.txtVideoCall.name.tr
                              : EnumLocale.txtAudioCall.name.tr, // default fallback
                      style: AppFontStyle.fontStyleW600(fontSize: 16, fontColor: AppColors.black),
                    ).paddingOnly(left: 8, right: 7),
                    RotatedBox(
                      quarterTurns: 3,
                      child: Image.asset(
                        AppAsset.backArrowIcon,
                        height: 14,
                        width: 14,
                        color: AppColors.black,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          PrimaryAppButton(
            gradientColor: [
              Color(0xffCF00FD),
              Color(0xff8400FF),
            ],
            onTap: () {
              // log("Random call view before :::::: ${controller.randomCall}");

              controller.getaAvailableListener().then((value) {
                if (controller.randomAvailableListenerModel?.data != null) {
                  // controller.randomCall = true;
                  // log("Random call view after :::::: ${controller.randomCall}");

                  Get.toNamed(AppRoutes.randomMatchView)?.then(
                    (value) async {
                      controller.userCoinModel = await UserCoinApi.callApi();
                      Database.onSetUserCoin(controller.userCoinModel!.coin.toString());
                    },
                  ); // Navigate if data is fetched
                } else {
                  // Handle error or empty response scenario
                  log("No available listener found");
                  Utils.showToast(Get.context!, controller.randomAvailableListenerModel?.message ?? '');
                }
              });
            },
            height: 47,
            borderRadius: 30,
            text: EnumLocale.txtRandomMatch.name.tr,
            textStyle: AppFontStyle.fontStyleW600(fontSize: 16, fontColor: AppColors.white),
          ).paddingOnly(bottom: 20, top: 16, left: 24, right: 24),
        ],
      );
    });
  }
}

class ConnectCallDialog extends StatelessWidget {
  const ConnectCallDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RandomCallController>(
      builder: (controller) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          child: Container(
            // padding: EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: Get.width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(26),
                      ),
                      color: AppColors.black.withValues(alpha: 0.02)),
                  child: Center(
                    child: Text(
                      EnumLocale.txtSelectCallTypeLower.name.tr,
                      style: AppFontStyle.fontStyleW600(fontSize: 16, fontColor: Colors.black),
                    ),
                  ).paddingSymmetric(vertical: 13),
                ),
                _buildCallOption(
                  context,
                  controller,
                  icon: AppAsset.callGradiant,
                  title: EnumLocale.txtAudioCall.name.tr,
                  index: 0,
                  priceTag: '${Database.settingApiModel?.data?.audioCallRateRandom} Coin',
                ).paddingOnly(top: 18, bottom: 18),
                Divider(
                  color: AppColors.lightGrey,
                  height: 0,
                ),
                _buildCallOption(
                  context,
                  controller,
                  icon: AppAsset.videoCallGradiant,
                  title: EnumLocale.txtVideoCall.name.tr,
                  index: 1,
                  priceTag: '${Database.settingApiModel?.data?.videoCallRateRandom} Coin',
                ).paddingOnly(top: 18, bottom: 18),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCallOption(
    BuildContext context,
    RandomCallController controller, {
    required String icon,
    required String title,
    required int index,
    String? priceTag,
  }) {
    bool selected = controller.selectedIndex == index;
    return InkWell(
      // onTap: () => controller.selectCallType(index),
      onTap: () {
        controller.selectCallType(index);
        Get.back(result: index); // Return selected index
        log("call type ::::: ${controller.selectedIndex == 0 ? "Audio" : "Video"}");
      },

      child: Row(
        children: [
          Image.asset(
            icon,
            height: 32,
            width: 32,
          ).paddingOnly(right: 12),
          // const SizedBox(width: 12),
          Text(
            title,
            style: AppFontStyle.fontStyleW600(fontSize: 16, fontColor: AppColors.black),
          ).paddingOnly(right: 10),
          if (priceTag != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.lightOrange1,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Image.asset(
                    AppAsset.dimondCoin,
                    height: 18,
                  ).paddingOnly(right: 4),
                  Text(
                    priceTag,
                    style: AppFontStyle.fontStyleW600(
                      fontSize: 12,
                      fontColor: AppColors.lightOrange,
                    ),
                  ),
                ],
              ),
            ),
          Spacer(),
          Container(
            height: 22,
            width: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: selected ? AppColors.transparent : AppColors.grey),
              color: selected ? Colors.black : AppColors.white,
            ),
            child: selected
                ? Container(
                    decoration: BoxDecoration(
                      color: AppColors.appColor,
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      height: 22,
                      width: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white),
                        color: AppColors.appColor,
                      ),
                    ).paddingAll(0.5),
                  )
                : null,
          ),
        ],
      ).paddingSymmetric(horizontal: 18),
    );
  }
}
