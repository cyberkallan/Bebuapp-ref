import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/bottom_sheet/talk_now_button_bottom_sheet.dart';
import 'package:talk_in/custom/listeners/listeners.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/home_screen/controller/home_screen_controller.dart';
import 'package:talk_in/ui/user_flow/home_screen/shimmer/top_listener_shimmer.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class TopListenerWidget extends StatelessWidget {
  const TopListenerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.08),
            blurRadius: 1,
            offset: Offset(0, 1),
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
                EnumLocale.txtTopListener.name.tr,
                style: AppFontStyle.fontStyleW600(fontSize: 18, fontColor: AppColors.appDarkColor),
              ),
              InkWell(
                onTap: () {
                  Get.toNamed(AppRoutes.topListenersViewAll);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4).copyWith(left: 5),
                  color: AppColors.transparent,
                  child: Text(
                    EnumLocale.txtViewAll.name.tr,
                    style: AppFontStyle.fontStyleW500(
                        decorationColor: AppColors.appTextColor,
                        textDecoration: TextDecoration.underline,
                        fontSize: 13,
                        fontColor: AppColors.appTextColor),
                  ),
                ),
              ),
            ],
          ).paddingOnly(top: 16, bottom: 16),
          GetBuilder<HomeScreenController>(
            id: Constant.idGetListener,
            builder: (controller) {
              return controller.isLoading
                  ? TopListenerShimmer()
                  : controller.topListenersModel?.data?.isEmpty == true
                      ? Image.asset(AppAsset.noListenerFound).paddingAll(50)
                      : ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: controller.topListeners.take(4).length,
                          itemBuilder: (context, index) {
                            return CustomListeners(
                                fake: controller.topListeners[index].isFake ?? false,
                                availableForPrivateAudioCall: controller.topListeners[index].isAvailableForPrivateAudioCall ?? false,
                                availableForPrivateVideoCall: controller.topListeners[index].isAvailableForPrivateVideoCall ?? false,
                                uniqueId: controller.topListeners[index].uniqueId ?? '',
                                statusTxtColor: controller.topListeners[index].statusLabel == "Offline" ? AppColors.appTextColor : AppColors.white,
                                statusColor: controller.topListeners[index].statusLabel == "Available"
                                    ? AppColors.green
                                    : controller.topListeners[index].statusLabel == "On Call"
                                        ? AppColors.red
                                        : AppColors.lightGrey1,
                                statusImage: controller.topListeners[index].statusLabel == "Available"
                                    ? Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.white.withValues(alpha: 0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Container(
                                          height: 7,
                                          width: 7,
                                          decoration: BoxDecoration(
                                            color: AppColors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        ).paddingAll(1.8),
                                      ).paddingOnly(right: 4)
                                    : controller.topListeners[index].statusLabel == "On Call"
                                        ? Image.asset(
                                            AppAsset.onCallIcon,
                                            height: 10,
                                            width: 10,
                                          ).paddingOnly(right: 3)
                                        : Container(
                                            // height: 12,
                                            // width: 12,
                                            decoration: BoxDecoration(
                                              color: AppColors.onBoardingTxt.withValues(alpha: 0.3),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Container(
                                              height: 7,
                                              width: 7,
                                              decoration: BoxDecoration(
                                                color: AppColors.onBoardingTxt,
                                                shape: BoxShape.circle,
                                              ),
                                            ).paddingAll(1.8),
                                          ).paddingOnly(right: 4),
                                image: controller.topListeners[index].image ?? '',
                                status: controller.topListeners[index].statusLabel ?? '',
                                language: controller.topListeners[index].language?[0].toString() ?? '',
                                callCount: controller.topListeners[index].callCount ?? 0,
                                talkTopicName: controller.topListeners[index].talkTopics ?? [],
                                talkTopicLength: controller.topListeners[index].talkTopics?.length ?? 0,
                                index: index,
                                name: controller.topListeners[index].name ?? '',
                                age: controller.topListeners[index].age == null ? "" : ",${controller.topListeners[index].age.toString()}",
                                viewProfileOnTap: () {
                                  Get.toNamed(
                                    AppRoutes.profileDetailScreenView,
                                    arguments: controller.topListeners[index].id,
                                  );
                                },
                                talkNowOnTap: () {
                                  String role = Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'user' : 'listener';

                                  log("################################$role");
                                  // if (controller.topListenersModel?.data?[index].isFake == true) {
                                  //   Utils.showLog("this is fake Listener>>>>>>>>>");
                                  //   Get.toNamed(
                                  //     AppRoutes.fakeOutgoingCall,
                                  //     arguments: [
                                  //       controller.topListenersModel?.data?[index].name,
                                  //       controller.topListenersModel?.data?[index].image,
                                  //       controller.topListenersModel?.data?[index].video,
                                  //       controller.isBackProfile,
                                  //     ],
                                  //   );
                                  // }
                                  // else {
                                  Get.bottomSheet(
                                    TalkNowButtonBottomSheet(
                                      chatOnTap: () {
                                        Get.toNamed(
                                          AppRoutes.personalChatScreen,
                                          arguments: [
                                            controller.topListenersModel?.data?[index].id,
                                            controller.topListenersModel?.data?[index].name,
                                            controller.topListenersModel?.data?[index].statusLabel,
                                            controller.topListenersModel?.data?[index].image,
                                            controller.topListenersModel?.data?[index].ratePrivateAudioCall,
                                            controller.topListenersModel?.data?[index].ratePrivateVideoCall,
                                            controller.topListenersModel?.data?[index].isFake,
                                            controller.topListenersModel?.data?[index].video,
                                            controller.topListenersModel?.data?[index].isAvailableForPrivateVideoCall,
                                            controller.topListenersModel?.data?[index].isAvailableForPrivateAudioCall,
                                          ],
                                        );
                                      },
                                      availableForPrivateAudioCall:
                                          controller.topListenersModel?.data?[index].isAvailableForPrivateAudioCall ?? false,
                                      availableForPrivateVideoCall:
                                          controller.topListenersModel?.data?[index].isAvailableForPrivateVideoCall ?? false,
                                      fakeVideo: controller.topListenersModel?.data?[index].video ?? [],
                                      fakeAudio: controller.topListenersModel?.data?[index].audio ?? "",
                                      isFake: controller.topListenersModel?.data?[index].isFake ?? false,
                                      videoCallRatePrivate: controller.topListenersModel?.data?[index].ratePrivateVideoCall.toString() ?? '',
                                      audioCallRatePrivate: controller.topListenersModel?.data?[index].ratePrivateAudioCall.toString() ?? '',
                                      callerId: Database.fetchLoginUserProfileModel?.user?.isListener == false
                                          ? Database.fetchLoginUserProfileModel?.user?.id ?? ''
                                          : Database.fetchLoginUserProfileModel?.user?.listenerId ?? '',
                                      receiverId: controller.topListeners[index].id ?? '',
                                      receiverName: controller.topListeners[index].name ?? '',
                                      receiverImage: controller.topListeners[index].image ?? '',
                                      callerName: Database.fetchLoginUserProfileModel?.user?.fullName ?? '',
                                      callerImage: Database.fetchLoginUserProfileModel?.user?.profilePic ?? '',
                                      // callType: "video",
                                      callerRole: Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'user' : 'listener',
                                      receiverRole: Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'listener' : 'user',
                                    ),
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                  );
                                }
                                // },
                                ).paddingOnly(bottom: 12);
                          },
                        );
            },
          ),
        ],
      ),
    );
  }
}
