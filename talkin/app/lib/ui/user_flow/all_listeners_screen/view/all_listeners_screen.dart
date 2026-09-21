import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/bottom_sheet/talk_now_button_bottom_sheet.dart';
import 'package:talk_in/custom/listeners/listeners.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/all_listeners_screen/controller/all_listeners_controller.dart';
import 'package:talk_in/ui/user_flow/all_listeners_screen/widget/all_listeners_widget.dart';
import 'package:talk_in/ui/user_flow/home_screen/shimmer/top_listener_shimmer.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';

class AllListenersScreen extends StatelessWidget {
  const AllListenersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: const AllListenersAppBar(),
      ),
      body: GetBuilder<AllListenersController>(
        id: Constant.idGetListener,
        builder: (controller) {
          return controller.isLoading
              ? TopListenerShimmer().paddingSymmetric(horizontal: 14, vertical: 16)
              : controller.allListener.isEmpty
                  ? Center(child: Image.asset(AppAsset.noListenerFound).paddingAll(60))
                  : Column(
                      children: [
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async => controller.onRefresh(),
                            child: SingleChildScrollView(
                              controller: controller.scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    physics: BouncingScrollPhysics(),
                                    itemCount: controller.allListener.length,
                                    itemBuilder: (context, index) {
                                      final allListener = controller.allListener[index];
                                      return CustomListeners(
                                        fake: controller.allListener[index].isFake ?? false,

                                        availableForPrivateAudioCall: allListener.isAvailableForPrivateAudioCall ?? false,
                                        availableForPrivateVideoCall: allListener.isAvailableForPrivateVideoCall ?? false,
                                        uniqueId: allListener.uniqueId ?? '',
                                        statusTxtColor:
                                            controller.allListener[index].statusLabel == "Offline" ? AppColors.appTextColor : AppColors.white,
                                        statusColor: controller.allListener[index].statusLabel == "Available"
                                            ? AppColors.green
                                            : controller.allListener[index].statusLabel == "On Call"
                                                ? AppColors.red
                                                : AppColors.lightGrey1,
                                        statusImage: controller.allListener[index].statusLabel == "Available"
                                            ? Container(
                                                // height: 12,
                                                // width: 12,
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
                                            : controller.allListener[index].statusLabel == "On Call"
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
                                        image: allListener.image ?? '',
                                        status: allListener.statusLabel ?? '',
                                        language: allListener.language?[0] ?? '',
                                        callCount: allListener.callCount ?? 0,
                                        talkTopicName: allListener.talkTopics ?? [],
                                        // talkTopicName: allListener?.talkTopics?.join(', ') ?? '',
                                        talkTopicLength: allListener.talkTopics?.length ?? 0,
                                        index: index,
                                        name: allListener.name ?? '',
                                        age: allListener.age == null ? "" : ",${allListener.age.toString()}",
                                        viewProfileOnTap: () {
                                          Get.toNamed(
                                            AppRoutes.profileDetailScreenView,
                                            arguments: allListener.id,
                                          );
                                        },
                                        talkNowOnTap: () {
                                          // if (controller.allListener[index].isFake == true) {
                                          //   Utils.showLog("this is fake Listener>>>>>>>>>");
                                          //   Get.toNamed(
                                          //     AppRoutes.fakeOutgoingCall,
                                          //     arguments: [
                                          //       controller.allListener[index].name,
                                          //       controller.allListener[index].image,
                                          //       controller.allListener[index].video,
                                          //       controller.isBackProfile
                                          //     ],
                                          //   );
                                          // } else {
                                          Get.bottomSheet(
                                            TalkNowButtonBottomSheet(
                                              chatOnTap: () {
                                                Get.toNamed(
                                                  AppRoutes.personalChatScreen,
                                                  arguments: [
                                                    allListener.id,
                                                    allListener.name,
                                                    allListener.statusLabel,
                                                    allListener.image,
                                                    allListener.ratePrivateAudioCall,
                                                    allListener.ratePrivateVideoCall,
                                                    allListener.isFake,
                                                    allListener.video,
                                                    allListener.isAvailableForPrivateVideoCall,
                                                    allListener.isAvailableForPrivateAudioCall,
                                                  ],
                                                );
                                              },
                                              availableForPrivateVideoCall: controller.allListener[index].isAvailableForPrivateVideoCall ?? false,
                                              availableForPrivateAudioCall: controller.allListener[index].isAvailableForPrivateAudioCall ?? false,
                                              isFake: controller.allListener[index].isFake ?? false,
                                              fakeVideo: controller.allListener[index].video ?? [],
                                              fakeAudio: controller.allListener[index].audio ?? "",
                                              // ratePrivateVideoCall: controller.allListener[index].ratePrivateVideoCall.toString() ?? '',
                                              // ratePrivateAudioCall: controller.allListener[index].ratePrivateAudioCall.toString() ?? '',
                                              audioCallRatePrivate: controller.allListener[index].ratePrivateAudioCall.toString(),
                                              videoCallRatePrivate: controller.allListener[index].ratePrivateVideoCall.toString(),
                                              callerId: Database.fetchLoginUserProfileModel?.user?.isListener == false
                                                  ? Database.fetchLoginUserProfileModel?.user?.id ?? ''
                                                  : Database.fetchLoginUserProfileModel?.user?.listenerId ?? '',
                                              receiverId: controller.allListener[index].id ?? '',
                                              receiverName: controller.allListener[index].name ?? '',
                                              receiverImage: controller.allListener[index].image ?? '',
                                              callerName: Database.fetchLoginUserProfileModel?.user?.fullName ?? '',
                                              callerImage: Database.fetchLoginUserProfileModel?.user?.profilePic ?? '',
                                              // callType: "video",
                                              callerRole: Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'user' : 'listener',
                                              receiverRole: Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'listener' : 'user',
                                            ),
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                          );
                                          // }
                                        },
                                      ).paddingOnly(bottom: 12, left: 16, right: 16);
                                    },
                                  ),
                                  GetBuilder<AllListenersController>(
                                    id: Constant.idPaginationListener,
                                    builder: (controller) => Visibility(
                                      visible: controller.isPaginationLoading,
                                      child: CircularProgressIndicator(color: AppColors.primary),
                                    ),
                                  ),
                                ],
                              ).paddingSymmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    );
        },
      ),
    );
  }
}
