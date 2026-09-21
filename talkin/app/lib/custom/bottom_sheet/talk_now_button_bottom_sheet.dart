import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/services/permission_handler/permission_handler.dart';
import 'package:talk_in/socket/socket_emit.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class TalkNowButtonBottomSheet extends StatelessWidget {
  final String callerId;
  final String receiverId;
  final String receiverName;
  final String receiverImage;
  final String callerName;
  final String receiverRole;
  final String callerRole;
  final String callerImage;
  final String audioCallRatePrivate;
  final String videoCallRatePrivate;
  final bool? isFake;
  final List fakeVideo;
  final String fakeAudio;
  final bool? availableForPrivateAudioCall;
  final bool? availableForPrivateVideoCall;
  final VoidCallback? chatOnTap;
  final bool showMessage;

  const TalkNowButtonBottomSheet({
    super.key,
    required this.callerId,
    required this.receiverId,
    required this.receiverName,
    required this.receiverImage,
    required this.callerName,
    required this.receiverRole,
    required this.callerRole,
    required this.callerImage,
    required this.audioCallRatePrivate,
    required this.videoCallRatePrivate,
    this.isFake,
    required this.fakeVideo,
    this.availableForPrivateAudioCall,
    this.availableForPrivateVideoCall,
    required this.fakeAudio,
    this.chatOnTap,
    this.showMessage = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 17, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Text(
                EnumLocale.txtSelectCallType.name.tr,
                style: AppFontStyle.fontStyleW700(
                  fontSize: 18,
                  fontColor: AppColors.black,
                ),
              ).paddingOnly(bottom: 26, left: Get.width * 0.03),
              Spacer(),
              InkWell(
                onTap: () {
                  Get.back();
                },
                child: Image.asset(
                  AppAsset.closeFillIcon,
                  height: 26,
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if ((availableForPrivateAudioCall == true && availableForPrivateVideoCall == true) || isFake == true) ...[
                Expanded(child: _buildAudioButton()),
                SizedBox(width: 12),
                Expanded(child: _buildVideoButton()),
              ] else if (availableForPrivateAudioCall == true) ...[
                Expanded(child: _buildAudioButton()), // full width when only audio
              ] else if (availableForPrivateVideoCall == true) ...[
                Expanded(child: _buildVideoButton()), // full width when only video
              ]
            ],
          ).paddingOnly(bottom: 16),
          showMessage == true
              ? PrimaryAppButton(
                  onTap: chatOnTap,
                  height: 54,
                  borderRadius: 50,
                  gradientColor: [Color(0xff27C500), Color(0xff02BB17)],
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(13),
                        decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.black.withAlpha(51)),
                        child: Center(
                          child: Image.asset(AppAsset.chat, height: 29, color: AppColors.white),
                        ),
                      ),
                      Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            EnumLocale.txtMessages.name.tr,
                            style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: AppColors.white),
                          ).paddingOnly(bottom: 6, top: 4),
                          Row(
                            children: [
                              Image.asset(AppAsset.dimondCoin, height: 14).paddingOnly(right: 4),
                              Text(
                                EnumLocale.txtFreeCoin.name.tr,
                                style: AppFontStyle.fontStyleW600(fontSize: 12, fontColor: AppColors.white),
                              ),
                            ],
                          ).paddingOnly(bottom: 4),
                        ],
                      ).paddingOnly(right: 45),
                      Spacer(),
                    ],
                  ),
                ).paddingOnly(bottom: 14)
              : Offstage(),
          Text(
            EnumLocale.txtNote.name.tr,
            style: AppFontStyle.fontStyleW600(
              fontSize: 13,
              fontColor: AppColors.black,
            ),
          ).paddingOnly(bottom: 3),
          Text(
            EnumLocale.txtSelectCallTypeNote.name.tr,
            style: AppFontStyle.fontStyleW400(
              fontSize: 11,
              fontColor: AppColors.darkGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioButton() {
    return PrimaryAppButton(
      onTap: () {
        Utils.showLog("audio call rate $audioCallRatePrivate video call rate $videoCallRatePrivate");

        if (isFake == true) {
          Get.back();
          Utils.showLog("this is fake Listener>>>>>>>>>");
          Get.toNamed(
            AppRoutes.fakeOutgoingCall,
            arguments: [
              receiverName,
              receiverImage,
              fakeVideo,
              fakeAudio,
              "audio"
              // isBackProfile,
            ],
          );
        } else {
          if (callerRole == "user" && (int.parse(Database.userCoin.toString()) < int.parse(audioCallRatePrivate))) {
            log("<<<<<<<<<<<<<<<<<<<<<<  ${Database.userCoin.toString()}");
            Get.back();

            Get.toNamed(AppRoutes.myWalletScreen);
            Utils.showToast(Get.context!, "You have not enough coins.");
          } else {
            PermissionHandler.onGetMicrophonePermission(
              onGranted: () async {
                SocketEmit.emitCallOutgoingRinging(
                  callerId: callerId,
                  receiverId: receiverId,
                  callType: "audio",
                  callerRole: callerRole,
                  receiverRole: receiverRole,
                  callerImage: callerImage,
                  callerName: callerName,
                  receiverImage: receiverImage,
                  receiverName: receiverName,
                );
              },
            );
          }
        }

        // Get.toNamed(AppRoutes.outgoingCallScreen);
      },
      color: AppColors.appColor,
      borderRadius: 30,
      gradientColor: [Color(0xff0F96FD), Color(0xff4456FF)],
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(11),
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.black.withAlpha(51)),
            child: Center(
              child: Image.asset(AppAsset.callIcon, height: 29, color: AppColors.white),
            ),
          ).paddingOnly(right: 5),
          Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                EnumLocale.txtAudioCall.name.tr,
                style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: AppColors.white),
              ).paddingOnly(bottom: 6, top: 4),
              if (Database.fetchLoginUserProfileModel?.user?.isListener == false)
                Row(
                  children: [
                    Image.asset(AppAsset.dimondCoin, height: 14).paddingOnly(right: 4),
                    Text(
                      "$audioCallRatePrivate Coin",
                      style: AppFontStyle.fontStyleW600(fontSize: 12, fontColor: AppColors.white),
                    ),
                  ],
                ).paddingOnly(bottom: 4),
            ],
          ).paddingOnly(right: 20),
          Spacer(),
        ],
      ),
    );
  }

  Widget _buildVideoButton() {
    return PrimaryAppButton(
      onTap: () {
        // SocketEmit.emitCallOutgoingRinging(
        //     callerId: callerId, receiverId: receiverId, callType: callType, callerRole: callerRole, receiverRole: receiverRole);
        Utils.showLog("audio call rate $audioCallRatePrivate video call rate $videoCallRatePrivate");
        if (isFake == true) {
          Get.back();
          Utils.showLog("this is fake Listener>>>>>>>>>");

          PermissionHandler.onGetCameraPermission(
            onGranted: () {
              PermissionHandler.onGetMicrophonePermission(
                onGranted: () async {
                  Get.toNamed(
                    AppRoutes.fakeOutgoingCall,
                    arguments: [
                      receiverName,
                      receiverImage,
                      fakeVideo,
                      fakeAudio,
                      "video"
                      // isBackProfile,
                    ],
                  );
                },
              );
            },
          );
        } else {
          if (callerRole == "user" && (int.parse(Database.userCoin.toString()) < int.parse(videoCallRatePrivate))) {
            log("<<<<<<<<<<<<<<<<<<<<<<  ${Database.userCoin.toString()} >>>>>>>>>>> $videoCallRatePrivate");
            log("<<<<<<<<<<<<<<<<<<<<<<  $callerRole");
            Get.back();

            Get.toNamed(AppRoutes.myWalletScreen);
            Utils.showToast(Get.context!, "You have not enough coins");
          } else {
            PermissionHandler.onGetCameraPermission(
              onGranted: () {
                PermissionHandler.onGetMicrophonePermission(
                  onGranted: () async {
                    SocketEmit.emitCallOutgoingRinging(
                      callerId: callerId,
                      receiverId: receiverId,
                      callType: "video",
                      callerRole: callerRole,
                      receiverRole: receiverRole,
                      callerImage: callerImage,
                      callerName: callerName,
                      receiverImage: receiverImage,
                      receiverName: receiverName,
                    );
                  },
                );
              },
            );
          }
        }
      },
      color: AppColors.appColor,
      borderRadius: 30,
      gradientColor: [Color(0xffC30EFF), Color(0xff8D13FF)],
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(11),
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.black.withAlpha(51)),
            child: Center(
              child: Image.asset(AppAsset.videoCallIcon, height: 29, color: AppColors.white),
            ),
          ).paddingOnly(right: 5),
          Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                EnumLocale.txtVideoCall.name.tr,
                style: AppFontStyle.fontStyleW700(fontSize: 14, fontColor: AppColors.white),
              ).paddingOnly(bottom: 6, top: 4),
              if (Database.fetchLoginUserProfileModel?.user?.isListener == false)
                Row(
                  children: [
                    Image.asset(AppAsset.dimondCoin, height: 14).paddingOnly(right: 4),
                    Text(
                      "$videoCallRatePrivate Coin",
                      style: AppFontStyle.fontStyleW600(fontSize: 12, fontColor: AppColors.white),
                    ),
                  ],
                ).paddingOnly(bottom: 4),
            ],
          ).paddingOnly(right: 20),
          Spacer(),
        ],
      ),
    );
  }
}
