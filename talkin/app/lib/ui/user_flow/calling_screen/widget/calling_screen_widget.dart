import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_bar/custom_app_bar.dart';
import 'package:talk_in/custom/bottom_sheet/talk_now_button_bottom_sheet.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/calling_screen/controller/calling_screen_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class CallingScreenAppBar extends StatelessWidget {
  const CallingScreenAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(120),
      child: CustomAppBar(
        title: EnumLocale.txtCallingHistory.name.tr,
        showLeadingIcon: false,
      ),
    );
  }
}

class CallingScreenItem extends StatelessWidget {
  final int index;
  final String image;
  final String name;
  final String time;
  final String callStatusText;
  final num coin;
  final bool audioCall;
  final bool videoCall;
  final CallingScreenController controller;
  final VoidCallback? onTalkNowTap;

  const CallingScreenItem(
      {super.key,
      required this.index,
      required this.image,
      required this.name,
      required this.time,
      required this.callStatusText,
      required this.coin,
      required this.controller,
      required this.audioCall,
      required this.videoCall,
      this.onTalkNowTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            clipBehavior: Clip.hardEdge,
            height: Get.height * 0.078,
            width: Get.height * 0.078,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: CustomListenerProfileImage(image: image.toString(), fit: BoxFit.cover),
          ).paddingAll(5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        overflow: TextOverflow.ellipsis,
                        name,
                        style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: AppColors.black),
                      ).paddingOnly(right: 8),
                    ),
                    coin == 0
                        ? SizedBox.shrink()
                        : Container(
                            decoration: BoxDecoration(
                              color: AppColors.lightYellow100,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  AppAsset.dimondCoin,
                                  height: 13,
                                  width: 13,
                                ).paddingOnly(left: 6, top: 3, bottom: 3),
                                Text(
                                  coin.toString(),
                                  style: AppFontStyle.fontStyleW600(fontSize: 12, fontColor: AppColors.orange),
                                ).paddingOnly(left: 4, right: 9)
                              ],
                            ),
                          ),
                  ],
                ),
                Row(
                  children: [
                    Image.asset(
                      callStatusText == "Missed Call"
                          ? AppAsset.missedCall
                          : callStatusText == "Incoming Call"
                              ? AppAsset.incomingCall
                              : AppAsset.outgoingCall,
                      height: 19,
                      width: 19,
                    ),
                    Text(
                      callStatusText,
                      style: AppFontStyle.fontStyleW600(
                          fontSize: 12,
                          fontColor: callStatusText == "Missed Call"
                              ? Colors.red
                              : callStatusText == "Incoming Call"
                                  ? AppColors.green
                                  : AppColors.blue),
                    ).paddingOnly(left: 4, right: 4)
                  ],
                ).paddingOnly(bottom: 4, top: 2),
                Text(
                  time.toString(),
                  style: AppFontStyle.fontStyleW500(fontSize: 11, fontColor: AppColors.profileText),
                ),
              ],
            ).paddingOnly(left: 3),
          ),
          // Spacer(),
          (audioCall == true || videoCall == true)
              ? GestureDetector(
                  onTap: () {
                    if (onTalkNowTap != null) {
                      // 👉 If custom callback is passed, execute it
                      onTalkNowTap!();
                    } else {
                      // 👉 Else run your existing logic
                      Get.bottomSheet(
                        TalkNowButtonBottomSheet(
                          chatOnTap: () {
                            Get.toNamed(
                              AppRoutes.personalChatScreen,
                              arguments: [
                                controller.callingHistory[index].id,
                                controller.callingHistory[index].name,
                                controller.callingHistory[index].isOnline,
                                controller.callingHistory[index].image,
                                controller.callingHistory[index].ratePrivateAudioCall,
                                controller.callingHistory[index].ratePrivateVideoCall,
                                controller.callingHistory[index].isFake,
                                controller.callingHistory[index].video,
                                controller.callingHistory[index].isAvailableForPrivateVideoCall,
                                controller.callingHistory[index].isAvailableForPrivateAudioCall,
                              ],
                            );
                          },
                          availableForPrivateAudioCall: controller.callingHistory[index].isAvailableForPrivateAudioCall ?? false,
                          availableForPrivateVideoCall: controller.callingHistory[index].isAvailableForPrivateVideoCall ?? false,
                          isFake: controller.callingHistory[index].isFake ?? false,
                          fakeVideo: controller.callingHistory[index].video ?? [],
                          fakeAudio: controller.callingHistory[index].audio ?? "",
                          audioCallRatePrivate: controller.callingHistory[index].ratePrivateAudioCall.toString(),
                          videoCallRatePrivate: controller.callingHistory[index].ratePrivateVideoCall.toString(),
                          callerId: Database.fetchLoginUserProfileModel?.user?.id ?? '',
                          receiverId: controller.callingHistory[index].listenerId ?? '',
                          receiverName: controller.callingHistory[index].name ?? '',
                          receiverImage: controller.callingHistory[index].image ?? '',
                          callerName: Database.fetchLoginUserProfileModel?.user?.fullName ?? '',
                          callerImage: Database.fetchLoginUserProfileModel?.user?.profilePic ?? '',
                          callerRole: Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'user' : 'listener',
                          receiverRole: Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'listener' : 'user',
                        ),
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                      );
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xffFF1261),
                          Color(0xffFF1C20),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      color: AppColors.appColor,
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          AppAsset.callIcon,
                          color: AppColors.white,
                          height: 19,
                          width: 19,
                        ),
                        Text(
                          EnumLocale.txtTalkNow.name.tr,
                          style: AppFontStyle.fontStyleW600(fontSize: 11, fontColor: AppColors.white),
                        ).paddingOnly(left: 6)
                      ],
                    ),
                  ).paddingOnly(right: 6),
                )
              : GestureDetector(
                  onTap: () {
                    Utils.showToast(Get.context!, "Listener is not available", toastLength: Toast.LENGTH_SHORT);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.lightGrey200,
                          AppColors.lightGrey200,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          AppAsset.callIcon,
                          color: AppColors.white,
                          height: 19,
                          width: 19,
                        ),
                        Text(
                          EnumLocale.txtTalkNow.name.tr,
                          style: AppFontStyle.fontStyleW600(fontSize: 11, fontColor: AppColors.white),
                        ).paddingOnly(left: 6)
                      ],
                    ),
                  ).paddingOnly(right: 6),
                ),
        ],
      ),
    ).paddingSymmetric(horizontal: 16);
  }
}
