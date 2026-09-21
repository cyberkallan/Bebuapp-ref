import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_bar/custom_app_bar.dart';
import 'package:talk_in/custom/bottom_sheet/talk_now_button_bottom_sheet.dart';
import 'package:talk_in/custom/listeners/listeners.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/home_screen/shimmer/top_listener_shimmer.dart';
import 'package:talk_in/ui/user_flow/top_listeners_view_all/controller/top_listeners_view_all_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';

class TopListenersViewAllAppBar extends StatelessWidget {
  const TopListenersViewAllAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: EnumLocale.txtTopListener.name.tr,
      showLeadingIcon: true,
      action: [
        GestureDetector(
          onTap: () {
            Get.toNamed(AppRoutes.searchScreen);
            log(">>>>>>>>>>.");
          },
          child: Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: AppColors.lightGrey.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Image.asset(
                AppAsset.searchIcon,
                height: 18,
                width: 18,
              ),
            ),
          ).paddingOnly(right: 18),
        )
      ],
    );
  }
}

class TopListenersViewAllView extends StatelessWidget {
  const TopListenersViewAllView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TopListenersViewAllController>(
      id: Constant.idGetListener,
      builder: (controller) {
        return RefreshIndicator(
          onRefresh: () async => controller.onRefresh(),
          child: controller.isLoading
              ? TopListenerShimmer().paddingSymmetric(horizontal: 14, vertical: 12)
              : controller.topListeners.isEmpty
                  ? Center(child: Image.asset(AppAsset.noListenerFound).paddingAll(60))
                  : SingleChildScrollView(
                      controller: controller.scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.topListeners.length,
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
                                            decoration: BoxDecoration(
                                              color: AppColors.appTextColor.withValues(alpha: 0.3),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Container(
                                              height: 7,
                                              width: 7,
                                              decoration: BoxDecoration(
                                                color: AppColors.appTextColor,
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
                                  // if (controller.topListeners[index].isFake == true) {
                                  //   Utils.showLog("this is fake Listener>>>>>>>>>");
                                  //   Get.toNamed(
                                  //     AppRoutes.fakeOutgoingCall,
                                  //     arguments: [
                                  //       controller.topListeners[index].name,
                                  //       controller.topListeners[index].image,
                                  //       controller.topListeners[index].video,
                                  //       controller.isBackProfile
                                  //     ],
                                  //   );
                                  // } else {
                                  Get.bottomSheet(
                                    TalkNowButtonBottomSheet(
                                      availableForPrivateAudioCall: controller.topListeners[index].isAvailableForPrivateAudioCall ?? false,
                                      availableForPrivateVideoCall: controller.topListeners[index].isAvailableForPrivateVideoCall ?? false,
                                      isFake: controller.topListeners[index].isFake ?? false,
                                      fakeVideo: controller.topListeners[index].video ?? [],
                                      fakeAudio: controller.topListeners[index].audio ?? "",
                                      audioCallRatePrivate: controller.topListeners[index].ratePrivateAudioCall.toString(),
                                      videoCallRatePrivate: controller.topListeners[index].ratePrivateVideoCall.toString(),
                                      callerId: Database.fetchLoginUserProfileModel?.user?.isListener == false
                                          ? Database.fetchLoginUserProfileModel?.user?.id ?? ''
                                          : Database.fetchLoginUserProfileModel?.user?.listenerId ?? '',
                                      receiverId: controller.topListeners[index].id ?? '',
                                      receiverName: controller.topListeners[index].name ?? '',
                                      receiverImage: controller.topListeners[index].image ?? '',
                                      callerName: Database.fetchLoginUserProfileModel?.user?.fullName ?? '',
                                      callerImage: Database.fetchLoginUserProfileModel?.user?.profilePic ?? '',
                                      callerRole: Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'user' : 'listener',
                                      receiverRole: Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'listener' : 'user',
                                    ),
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                  );
                                  // }
                                },
                              ).paddingOnly(bottom: 12);
                            },
                          ),
                          GetBuilder<TopListenersViewAllController>(
                            id: Constant.idPaginationListener,
                            builder: (controller) => Visibility(
                              visible: controller.isPaginationLoading,
                              child: CircularProgressIndicator(color: AppColors.primary),
                            ),
                          ),
                        ],
                      ).paddingAll(16),
                    ),
        );
      },
    );
  }
}
