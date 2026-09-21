import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/bottom_sheet/talk_now_button_bottom_sheet.dart';
import 'package:talk_in/custom/dialog/exit_app_dialog.dart';
import 'package:talk_in/custom/listeners/listeners.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/home_screen/shimmer/top_listener_shimmer.dart';
import 'package:talk_in/ui/user_flow/listener_screen/controller/listeners_screen_controller.dart';
import 'package:talk_in/ui/user_flow/listener_screen/widget/listeners_screen_widget.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';

class ListenersScreen extends StatelessWidget {
  const ListenersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        Get.dialog(
          barrierColor: AppColors.black.withValues(alpha: 0.8),
          Dialog(
            backgroundColor: AppColors.transparent,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            child: const ExitAppDialog(),
          ),
        );
        if (didPop) {
          return;
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.lightPurple1,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: const ListenersAppBarView(),
        ),
        body: GetBuilder<ListenersScreenController>(
          id: Constant.idAllListener,
          builder: (controller) {
            return Column(
              children: [
                ListenersTopButtonView(),
                Expanded(
                  child: Container(
                    width: Get.width,
                    height: Get.height,
                    // padding: EdgeInsets.only(top: 14),
                    color: AppColors.white,
                    child: controller.isLoading
                        ? TopListenerShimmer().paddingSymmetric(horizontal: 14, vertical: 12)
                        : controller.allListener.isEmpty
                            ? Image.asset(
                                AppAsset.noListenerFound,
                              ).paddingSymmetric(horizontal: 62)
                            : RefreshIndicator(
                                onRefresh: () async => controller.onRefresh(),
                                child: SingleChildScrollView(
                                  controller: controller.scrollController,
                                  physics: AlwaysScrollableScrollPhysics(),
                                  child: Column(
                                    children: [
                                      ListView.builder(
                                        shrinkWrap: true,
                                        padding: EdgeInsets.zero,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: controller.allListener.length,
                                        itemBuilder: (context, index) {
                                          final allListener = controller.allListener[index];
                                          return CustomListeners(
                                            fake: controller.allListener[index].isFake ?? false,
                                            availableForPrivateAudioCall: allListener.isAvailableForPrivateAudioCall ?? false,
                                            availableForPrivateVideoCall: allListener.isAvailableForPrivateVideoCall ?? false,
                                            uniqueId: controller.allListener[index].uniqueId ?? '',
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
                                            language: allListener.language?[0].toString() ?? '',
                                            callCount: allListener.callCount ?? 0,
                                            talkTopicName: allListener.talkTopics ?? [],
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
                                              // if (allListener.isFake == true) {
                                              //   Utils.showLog("this is fake Listener>>>>>>>>>");
                                              //   Get.toNamed(
                                              //     AppRoutes.fakeOutgoingCall,
                                              //     arguments: [
                                              //       allListener.name,
                                              //       allListener.image,
                                              //       allListener.video,
                                              //       controller.isBackProfile,
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
                                                  availableForPrivateAudioCall: allListener.isAvailableForPrivateAudioCall ?? false,
                                                  availableForPrivateVideoCall: allListener.isAvailableForPrivateVideoCall ?? false,
                                                  isFake: allListener.isFake ?? false,
                                                  fakeVideo: allListener.video ?? [],
                                                  fakeAudio: allListener.audio ?? "",
                                                  audioCallRatePrivate: allListener.ratePrivateAudioCall.toString(),
                                                  videoCallRatePrivate: allListener.ratePrivateVideoCall.toString(),
                                                  callerId: Database.fetchLoginUserProfileModel?.user?.isListener == false
                                                      ? Database.fetchLoginUserProfileModel?.user?.id ?? ''
                                                      : Database.fetchLoginUserProfileModel?.user?.listenerId ?? '',
                                                  receiverId: allListener.id ?? '',
                                                  receiverName: allListener.name ?? '',
                                                  receiverImage: allListener.image ?? '',
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
                                          ).paddingOnly(bottom: 12, left: 14, right: 14, top: index == 0 ? 12 : 0);
                                        },
                                      ),
                                      GetBuilder<ListenersScreenController>(
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
                  ),
                ),
              ],
            ).paddingOnly(top: 8);
          },
        ),
      ),
    );
  }
}
