import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/bottom_sheet/talk_now_button_bottom_sheet.dart';
import 'package:talk_in/custom/custom_audio_time/custom_format_audio_time.dart';
import 'package:talk_in/custom/custom_chat_time/custom_format_chat_time.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/host_flow/host_personal_chat_screen/controller/host_personal_chat_screen_controller.dart';
import 'package:talk_in/ui/host_flow/host_personal_chat_screen/model/host_personal_chat_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';
import 'package:vibration/vibration.dart';

class HostChatScreenAppBar extends StatelessWidget {
  const HostChatScreenAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HostPersonalChatScreenController>(
      // id: Constant.idChatList,
      builder: (controller) {
        return Container(
          padding: EdgeInsets.only(top: Get.height * 0.033),
          decoration: BoxDecoration(
            color: AppColors.lightPurple1,
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.2),
                spreadRadius: 0.08,
                offset: const Offset(0.0, 0.0),
                blurRadius: 2.0,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  Get.back();
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 22, top: 22, right: 15, left: 22),
                  child: Image.asset(
                    height: 16,
                    AppAsset.backArrowIcon,
                    color: AppColors.black,
                  ),
                ),
              ),
              Expanded(
                  child: GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.userProfileDetailScreen, arguments: controller.receiverId);
                },
                child: Container(
                  color: AppColors.transparent,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.grey.withValues(alpha: 0.5),
                        ),
                        child: Container(
                          // clipBehavior: Clip.hardEdge,
                          height: Get.height * 0.058,
                          width: Get.height * 0.058,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.white, width: 1),
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(child: CustomProfileImage(image: controller.receiverImage ?? '')),
                        ).paddingAll(1),
                      ).paddingOnly(right: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.receiverName ?? '',
                            style: AppFontStyle.fontStyleW700(fontSize: 16, fontColor: AppColors.black),
                          ).paddingOnly(bottom: 5),
                          controller.receiverStatusLabel == "false"
                              ? Container(
                                  padding: EdgeInsets.only(right: 5, bottom: 3, top: 3, left: 5),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: AppColors.lightGrey1),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.onBoardingTxt.withValues(alpha: 0.3),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Container(
                                          height: 7.5,
                                          width: 7.5,
                                          decoration: BoxDecoration(
                                            color: AppColors.onBoardingTxt,
                                            shape: BoxShape.circle,
                                          ),
                                        ).paddingAll(1.8),
                                      ).paddingOnly(right: 4),
                                      Text(
                                        "Offline",
                                        style: AppFontStyle.fontStyleW500(fontSize: 10, fontColor: AppColors.appTextColor),
                                      ).paddingOnly(right: 4),
                                    ],
                                  ),
                                )
                              : Container(
                                  padding: EdgeInsets.only(right: 5, bottom: 3, top: 3, left: 5),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: AppColors.green),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.white.withValues(alpha: 0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Container(
                                          height: 7.5,
                                          width: 7.5,
                                          decoration: BoxDecoration(
                                            color: AppColors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        ).paddingAll(1.8),
                                      ).paddingOnly(right: 4),
                                      Text(
                                        EnumLocale.txtOnline.name.tr,
                                        style: AppFontStyle.fontStyleW500(fontSize: 10, fontColor: AppColors.white),
                                      ).paddingOnly(right: 4),
                                    ],
                                  ),
                                )
                        ],
                      ),
                    ],
                  ),
                ),
              )),
              GestureDetector(
                onTap: () {
                  String role = Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'user' : 'listener';

                  log("################################$role");

                  Utils.showLog(" listenerId >>>>>>>>>>>>>>>>>  ${Database.fetchLoginUserProfileModel?.user?.listenerId}");
                  Utils.showLog("receiverId  >>>>>>>>>>>>>>>>>  ${controller.receiverId}");
                  Utils.showLog(" receiverName >>>>>>>>>>>>>>>>>  ${controller.receiverName}");
                  Utils.showLog(" receiverImage >>>>>>>>>>>>>>>>>  ${controller.receiverImage}");
                  Utils.showLog(" fetchListenerProfileModel?.data?.name >>>>>>>>>>>>>>>>>  ${Database.fetchListenerProfileModel?.data?.name}");
                  Utils.showLog("fetchListenerProfileModel?.data?.image  >>>>>>>>>>>>>>>>>  ${Database.fetchListenerProfileModel?.data?.image}");
                  Utils.showLog(
                      "fetchLoginUserProfileModel?.user?.isListener  >>>>>>>>>>>>>>>>>  ${Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'user' : 'listener'}");
                  Utils.showLog(
                      "fetchLoginUserProfileModel?.user?.isListener >>>>>>>>>>>>>>>>>  ${Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'listener' : 'user'}");

                  Get.bottomSheet(
                    TalkNowButtonBottomSheet(
                      showMessage: false,
                      availableForPrivateAudioCall: true,
                      availableForPrivateVideoCall: true,
                      isFake: false,
                      fakeVideo: [],
                      fakeAudio: "",
                      videoCallRatePrivate: '',
                      audioCallRatePrivate: '',
                      callerId: Database.fetchListenerProfileModel?.data?.id ?? '',
                      receiverId: controller.receiverId ?? '',
                      receiverName: controller.receiverName ?? '',
                      receiverImage: controller.receiverImage ?? '',
                      callerName: Database.fetchListenerProfileModel?.data?.name ?? '',
                      callerImage: Database.fetchListenerProfileModel?.data?.image ?? '',
                      callerRole: 'listener',
                      receiverRole: 'user',
                    ),
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                  );
                },
                child: Center(
                  child: Image.asset(
                    AppAsset.callGradiant,
                    height: 28,
                    width: 28,
                  ),
                ).paddingOnly(right: 18),
              )
            ],
          ).paddingOnly(top: 6, bottom: 6),
        );
      },
    );
  }
}

class HostChatImageWidget extends StatelessWidget {
  final ListenerChat msg;
  final HostPersonalChatScreenController controller;
  final bool isRead;

  const HostChatImageWidget({
    super.key,
    required this.msg,
    required this.controller,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSender = Database.fetchLoginUserProfileModel?.user?.listenerId == msg.senderId;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isSender) ...[
          Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.grey.withValues(alpha: 0.5),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.grey.withValues(alpha: 0.5),
                ),
                child: Container(
                  // clipBehavior: Clip.hardEdge,
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.white, width: 1),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: CustomProfileImage(image: controller.receiverImage.toString()),
                  ),
                ).paddingAll(1),
              )).paddingOnly(bottom: 17),
          const SizedBox(width: 6),
        ],
        Container(
          margin: const EdgeInsets.symmetric(vertical: 7),
          child: Column(
            crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Get.to(() => FullScreenImageView(imageUrl: msg.image.toString()));
                },
                child: Container(
                  width: 150,
                  height: 200,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SendMessageImage(image: msg.image.toString(), fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 150,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Spacer(),
                    Text(
                      controller.formatTimeFromDate(msg.date),
                      style: AppFontStyle.fontStyleW500(fontSize: 8, fontColor: AppColors.darkPurple),
                    ).paddingOnly(right: 2),
                    if (isSender)
                      Image.asset(
                        isRead ? AppAsset.read2Icon : AppAsset.unreadMsgIcon,
                        height: 18,
                        width: 16,
                        color: AppColors.darkPurple,
                      )
                  ],
                ),
              )
            ],
          ),
        ),
        if (isSender) ...[
          const SizedBox(width: 6),
          Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.grey.withValues(alpha: 0.5),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.grey.withValues(alpha: 0.5),
                ),
                child: Container(
                  // clipBehavior: Clip.hardEdge,
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.white, width: 1),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: CustomProfileImage(image: Database.fetchLoginUserProfileModel?.user?.profilePic.toString() ?? ''),
                  ),
                ).paddingAll(1),
              )).paddingOnly(bottom: 11),
        ],
      ],
    );
  }
}

class HostChatTextWidget extends StatelessWidget {
  final ListenerChat msg;
  final HostPersonalChatScreenController controller;
  final bool isRead;

  const HostChatTextWidget({
    super.key,
    required this.msg,
    required this.controller,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSender = Database.fetchLoginUserProfileModel?.user?.listenerId == msg.senderId;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isSender) ...[
          Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.grey.withValues(alpha: 0.5),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.grey.withValues(alpha: 0.5),
                ),
                child: Container(
                  // clipBehavior: Clip.hardEdge,
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.white, width: 1),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: CustomProfileImage(image: controller.receiverImage.toString()),
                  ),
                ).paddingAll(1),
              )).paddingOnly(bottom: 4),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 7),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: isSender ? AppColors.chatPurple : AppColors.chatPink,
              borderRadius: isSender
                  ? const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      topLeft: Radius.circular(12),
                    )
                  : const BorderRadius.only(
                      bottomRight: Radius.circular(12),
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    msg.message.toString(),
                    style: AppFontStyle.fontStyleW600(fontSize: 16, fontColor: AppColors.white),
                  ).paddingOnly(right: 6, top: 7, bottom: 7),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      controller.formatTimeFromDate(msg.date),
                      style: AppFontStyle.fontStyleW500(fontSize: 8, fontColor: AppColors.white),
                    ).paddingOnly(right: 2, bottom: 4),
                    if (isSender)
                      Image.asset(
                        isRead ? AppAsset.read2Icon : AppAsset.unreadMsgIcon,
                        height: 18,
                        width: 16,
                      ),
                  ],
                ).paddingOnly(bottom: 2)
              ],
            ),
          ).paddingOnly(right: isSender ? 0 : 55, left: isSender ? 55 : 0),
        ),
        if (isSender) ...[
          const SizedBox(width: 6),
          Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.grey.withValues(alpha: 0.5),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.grey.withValues(alpha: 0.5),
                ),
                child: Container(
                  // clipBehavior: Clip.hardEdge,
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.white, width: 1),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: CustomProfileImage(image: Database.fetchListenerProfileModel?.data?.image.toString() ?? ''),
                  ),
                ).paddingAll(1),
              )).paddingOnly(bottom: 4),
        ],
      ],
    );
  }
}

class HostChatVideoCallWidget extends StatelessWidget {
  final ListenerChat msg;
  final HostPersonalChatScreenController controller;
  final String callDuration;

  const HostChatVideoCallWidget({
    super.key,
    required this.msg,
    required this.controller,
    required this.callDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7),
      padding: const EdgeInsets.only(bottom: 3, left: 12, right: 12),
      decoration: BoxDecoration(
        color: AppColors.chatCallColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              // AppAsset.videoCallIcon,
              msg.callType == 1 || msg.callType == 2 ? AppAsset.chatVideoCallIcon : AppAsset.missedVideoCall,

              height: 26,
              width: 26,
              // color: msg.callType == 3 ? AppColors.transparent : AppColors.darkPurple,
            ),
          ).paddingOnly(right: 11),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                EnumLocale.txtVideoCall.name.tr,
                style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: AppColors.black),
              ).paddingOnly(bottom: 4),
              if (msg.callType == 1)
                Text(
                  callDuration.toString(),
                  style: AppFontStyle.fontStyleW500(fontSize: 12, fontColor: AppColors.darkPurple),
                ),
            ],
          ).paddingOnly(right: 19),
          // if (msg.callType == 1)
          Text(
            controller.formatTimeFromDate(msg.date),
            style: AppFontStyle.fontStyleW500(fontSize: 9, fontColor: AppColors.darkPurple),
          ).paddingOnly(top: Get.height * 0.06),
        ],
      ),
    );
  }
}

class HostChatAudioCallWidget extends StatelessWidget {
  final ListenerChat msg;
  final String audioCallDuration;

  final HostPersonalChatScreenController controller;

  const HostChatAudioCallWidget({
    super.key,
    required this.msg,
    required this.controller,
    required this.audioCallDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7),
      padding: const EdgeInsets.only(bottom: 3, left: 12, right: 12),
      decoration: BoxDecoration(
        color: AppColors.chatCallColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              msg.callType == 1 || msg.callType == 2 ? AppAsset.callIcon : AppAsset.missedAudioCall,
              height: 26,
              width: 26,
              color: msg.callType == 3 ? AppColors.red : AppColors.darkPurple,
            ),
          ).paddingOnly(right: 11),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                EnumLocale.txtAudioCall.name.tr,
                style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: AppColors.black),
              ).paddingOnly(bottom: 4),
              if (msg.callType == 1)
                Text(
                  audioCallDuration.toString(),
                  style: AppFontStyle.fontStyleW500(fontSize: 12, fontColor: AppColors.darkPurple),
                ),
            ],
          ).paddingOnly(right: 19),
          Text(
            controller.formatTimeFromDate(msg.date),
            style: AppFontStyle.fontStyleW500(fontSize: 9, fontColor: AppColors.darkPurple),
          ).paddingOnly(top: Get.height * 0.06),
        ],
      ),
    );
  }
}

class HostPersonalChatBottomView extends StatelessWidget {
  const HostPersonalChatBottomView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HostPersonalChatScreenController>(
      id: Constant.idChangeAudioRecordingEvent,
      builder: (controller) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10).copyWith(bottom: 18),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                offset: const Offset(0, 0),
                blurRadius: 6,
              ),
            ],
            color: Colors.white,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  cursorColor: AppColors.darkPurple,
                  controller: controller.messageController,
                  maxLength: 1000,
                  buildCounter: (
                    BuildContext context, {
                    required int currentLength,
                    required bool isFocused,
                    required int? maxLength,
                  }) {
                    return null; // This hides the counter
                  },
                  style: AppFontStyle.fontStyleW500(fontSize: 15, fontColor: AppColors.darkPurple),
                  decoration: InputDecoration(
                    suffixIcon: SizedBox(
                      width: Get.width * 0.23,
                      child: Center(
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                // Vibration.vibrate(duration: 50, amplitude: 128);
                                Utils.showToast(Get.context!, EnumLocale.txtLongPressToEnableAudioRecording.name.tr);
                              },
                              onLongPressStart: (details) {
                                if (controller.isSendingAudioFile == false) {
                                  Vibration.vibrate(duration: 50, amplitude: 128);
                                  controller.onLongPressStartMic();
                                }
                              },
                              onLongPressEnd: (details) {
                                if (controller.isSendingAudioFile == false) {
                                  Vibration.vibrate(duration: 50, amplitude: 128);
                                  controller.onLongPressEndMic();
                                }
                              },
                              child: Image.asset(
                                AppAsset.microPhoneIcon,
                                height: 24,
                                width: 24,
                                color: AppColors.darkPurple,
                              ).paddingOnly(right: 12, left: 4),
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.defaultDialog(
                                  backgroundColor: AppColors.white,
                                  title: EnumLocale.changeYourImage.name.tr,
                                  titlePadding: const EdgeInsets.only(top: 30),
                                  titleStyle: AppFontStyle.fontStyleW700(fontSize: 16, fontColor: AppColors.appColor),
                                  content: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Divider(
                                          thickness: 1,
                                          color: Colors.grey.shade100,
                                        ),
                                      ),
                                      GestureDetector(
                                          onTap: () async {
                                            Get.back();
                                            bool didPick = await controller.pickImageFromCamera();
                                            if (didPick) await controller.sendImageMessage();
                                          },
                                          child: Container(
                                            height: 60,
                                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                                  child: Image(
                                                    color: AppColors.appColor,
                                                    image: AssetImage(AppAsset.cameraFlipIcon),
                                                    height: 20,
                                                  ),
                                                ),
                                                Text(
                                                  EnumLocale.txtTakeAphoto.name.tr,
                                                  style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: AppColors.appColor),
                                                )
                                              ],
                                            ),
                                          )),
                                      GestureDetector(
                                          onTap: () async {
                                            Get.back();
                                            bool didPick = await controller.pickImageFromGallery();
                                            if (didPick) await controller.sendImageMessage();
                                          },
                                          child: Container(
                                            height: 60,
                                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                                  child: Image(
                                                    color: AppColors.appColor,
                                                    image: AssetImage(AppAsset.chatImageIcon),
                                                    height: 20,
                                                  ),
                                                ),
                                                Text(
                                                  EnumLocale.txtChooseFromYourFile.name.tr,
                                                  style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: AppColors.appColor),
                                                )
                                              ],
                                            ),
                                          )),
                                    ],
                                  ),
                                );
                              },
                              child: Image.asset(
                                AppAsset.chatImageIcon,
                                height: 24,
                                width: 24,
                                color: AppColors.darkPurple,
                              ).paddingOnly(right: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    hintText: "Type Something...",
                    hintStyle: AppFontStyle.fontStyleW500(fontSize: 15, fontColor: AppColors.darkPurple),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ).paddingOnly(right: 14),
              ),
              GestureDetector(
                  onTap: () {
                    controller.sendMessage();
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.appColor),
                    child: Image.asset(
                      AppAsset.msgSendIcon,
                      height: 26,
                      width: 26,
                    ),
                  ))
            ],
          ),
        );
      },
    );
  }
}

/*
class SenderAudioUi extends StatefulWidget {
  const SenderAudioUi({super.key, required this.id, required this.audio, required this.time});

  final String id;
  final String audio;
  final String time;

  @override
  State<SenderAudioUi> createState() => _SenderAudioUiState();
}

class _SenderAudioUiState extends State<SenderAudioUi> {
  AudioPlayer audioPlayer = AudioPlayer();

  RxBool isPlaying = false.obs;
  RxBool isLoading = false.obs;

  RxInt audioDuration = 0.obs;
  RxInt audioCurrentDuration = 0.obs;

  final controller = Get.find<HostPersonalChatScreenController>();

  @override
  void initState() {
    onInit();
    super.initState();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  void onInit() async {
    Utils.showLog("Audio Initializing...  ${widget.audio}");

    isLoading.value = true;
    audioPlayer.audioCache.clearAll();

    // await audioPlayer.play(UrlSource(testAudioUrl));
    await audioPlayer.play(UrlSource(widget.audio));

    onPauseAudio();

    final Duration? duration = await audioPlayer.getDuration();

    if (duration != null) {
      audioDuration.value = duration.inSeconds;
      Utils.showLog("Audio Duration => ${audioDuration.value}");
      isLoading.value = false;
    }

    audioPlayer.onPositionChanged.listen((event) {
      audioCurrentDuration.value = event.inSeconds;

      if (controller.currentPlayAudioId != widget.id && isPlaying.value) {
        onPauseAudio();
      }
    });

    audioPlayer.onPlayerComplete.listen(
      (event) async {
        audioCurrentDuration.value = 0;
        onPauseAudio();

        // await audioPlayer.play(UrlSource(testAudioUrl));
        await audioPlayer.play(UrlSource(widget.audio));
        onPauseAudio();
      },
    );
  }

  void onPlayAudio() async {
    isPlaying.value = true;
    audioPlayer.resume();
    controller.currentPlayAudioId = widget.id;
  }

  void onPauseAudio() {
    isPlaying.value = false;
    audioPlayer.pause();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          height: 75,
          width: Get.width / 1.6,
          margin: EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            // gradient: AppColors.primaryLinearGradient,
            color: AppColors.chatPurple,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5),
              topRight: Radius.circular(5),
              bottomLeft: Radius.circular(5),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 75,
                width: Get.width / 1.6,
                margin: EdgeInsets.only(left: 6, right: 6, top: 6, bottom: 15),
                padding: EdgeInsets.symmetric(horizontal: 10),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Row(
                  children: [
                    Obx(
                      () => isLoading.value
                          ? Padding(
                              padding: EdgeInsets.only(right: 2.5, top: 5, bottom: 5),
                              // child: LoadingUi(size: 30),
                            )
                          : GestureDetector(
                              onTap: () => isPlaying.value ? onPauseAudio() : onPlayAudio(),
                              child: Icon(
                                isPlaying.value ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                size: 30,
                                color: AppColors.chatPurple,
                              ),
                              // child: Image.asset(isPlaying.value ? AppAsset.icPause : AppAsset.icPlay, width: 30),
                            ),
                    ),
                    5.width,
                    Expanded(
                      child: Obx(
                        () => SliderTheme(
                          data: SliderThemeData(
                            overlayShape: SliderComponentShape.noOverlay,
                            activeTrackColor: AppColors.grey,
                            thumbColor: AppColors.grey,
                            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
                            trackHeight: 5,
                          ),
                          child: Slider(
                            min: 0,
                            max: audioDuration.value.toDouble(),
                            value: audioCurrentDuration.value.toDouble(),
                            onChanged: (value) {
                              audioPlayer.seek(Duration(seconds: value.toInt()));
                            },
                          ),
                        ),
                      ),
                    ),
                    3.width,
                    Container(
                      height: 40,
                      width: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.grey,
                      ),
                      child: Image.asset(
                        AppAsset.microPhoneIcon,
                        width: 20,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 20,
                right: 70,
                child: Obx(
                  () => Text(
                    CustomFormatAudioTime.convert(audioCurrentDuration.value),
                    style: AppFontStyle.fontStyleW500(fontColor: AppColors.primary, fontSize: 9),
                  ),
                ),
              ),
              Positioned(
                bottom: 3,
                right: 8,
                child: Text(
                  widget.time,
                  style: AppFontStyle.fontStyleW500(fontColor: AppColors.white, fontSize: 8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
*/

class SenderAudioMessageWidget extends StatefulWidget {
  final String audioUrl;
  final String time;
  final String id;
  final dynamic chat;
  final bool isLastMessage;

  const SenderAudioMessageWidget({
    super.key,
    required this.audioUrl,
    required this.time,
    required this.id,
    required this.chat,
    required this.isLastMessage,
  });

  @override
  State<SenderAudioMessageWidget> createState() => _SenderAudioMessageWidgetState();
}

class _SenderAudioMessageWidgetState extends State<SenderAudioMessageWidget> {
  final AudioPlayer player = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();

    player.onDurationChanged.listen((newDuration) {
      setState(() => duration = newDuration);
    });

    player.onPositionChanged.listen((newPosition) {
      setState(() => position = newPosition);
      log("position=>$position");
    });

    player.onPlayerComplete.listen((_) {
      setState(() {
        isPlaying = false;
        position = Duration.zero;
      });
    });

    player.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });
  }

  void onPlayAudio() async {
    log("uri audio::::::::::${widget.audioUrl}");

    try {
      final sanitizedUrl = widget.audioUrl.replaceAll('\\', '/');
      final fullUrl = '${Api.baseUrl}$sanitizedUrl';

      log("Attempting to play audio: $fullUrl");

      if (!isPlaying) {
        await player.play(UrlSource(fullUrl));
      } else {
        await player.pause();
      }
    } catch (e) {
      log("Audio playback error: $e");
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: Get.width / 1.6,
            // margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppColors.chatPurple,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  height: 70,
                  width: Get.width / 1.6,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 75,
                        width: Get.width / 1.6,
                        margin: const EdgeInsets.only(bottom: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          children: [
                            GetBuilder<HostPersonalChatScreenController>(
                              id: Constant.idGetOldChat,
                              builder: (logic) {
                                return widget.isLastMessage
                                    ? logic.isLoadingAudio
                                        ? CupertinoActivityIndicator(
                                            color: AppColors.chatPurple,
                                            radius: 12,
                                          )
                                        : GestureDetector(
                                            onTap: () => onPlayAudio(),
                                            child: Icon(
                                              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                              size: 30,
                                              color: AppColors.chatPurple,
                                            )

                                            // Image.asset(isPlaying ? AppAsset.icPause1 : AppAsset.icPlay1, color: AppColors.messageColor, width: 24),
                                            )
                                    : GestureDetector(
                                        onTap: () => onPlayAudio(),
                                        child: Icon(
                                          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                          size: 30,
                                          color: AppColors.chatPurple,
                                        )
                                        // Image.asset(isPlaying ? AppAsset.icPause1 : AppAsset.icPlay1, color: AppColors.messageColor, width: 24),
                                        );
                              },
                            ),
                            5.width,
                            Expanded(
                              child: SliderTheme(
                                data: SliderThemeData(
                                  overlayShape: SliderComponentShape.noOverlay,
                                  activeTrackColor: AppColors.primary,
                                  thumbColor: AppColors.primary,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                                  trackHeight: 5,
                                ),
                                child: Slider(
                                  activeColor: AppColors.chatPurple,
                                  min: 0,
                                  max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1,
                                  value: position.inSeconds.toDouble().clamp(0, duration.inSeconds.toDouble()),
                                  onChanged: (value) {
                                    player.seek(Duration(seconds: value.toInt()));
                                  },
                                ),
                              ),
                            ),
                            3.width,
                            Container(
                              height: 44,
                              width: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.chatPurple),
                              child: Image.asset(
                                AppAsset.microPhoneIcon,
                                width: 20,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        right: 70,
                        child: Text(
                          formatTime(position),
                          style: AppFontStyle.fontStyleW600(fontColor: AppColors.chatPurple, fontSize: 9),
                        ),
                      ),
                    ],
                  ),
                ),
                GetBuilder<HostPersonalChatScreenController>(
                  builder: (logic) {
                    return Text(
                      logic.formatTimeFromDate(widget.chat.date),
                      style: AppFontStyle.fontStyleW600(fontColor: AppColors.white, fontSize: 8),
                    );
                  },
                ),
              ],
            ),
          ),
          // const SizedBox(width: 10),
          // GetBuilder<ChatController>(
          //   builder: (logic) {
          //     return Container(
          //       padding: const EdgeInsets.all(2),
          //       decoration: BoxDecoration(
          //         shape: BoxShape.circle,
          //         border: Border.all(color: AppColors.borderColor),
          //       ),
          //       child: Container(
          //         clipBehavior: Clip.antiAlias,
          //         height: 35,
          //         width: 35,
          //         decoration: const BoxDecoration(
          //           shape: BoxShape.circle,
          //         ),
          //         child: CustomProfileImage(
          //           image: Database.profileImage,
          //           fit: BoxFit.cover,
          //         ),
          //       ),
          //     ).paddingOnly(bottom: 10);
          //   },
          // ),
        ],
      ).paddingOnly(bottom: 15),
    );
  }
}

class UploadAudioUi extends StatelessWidget {
  const UploadAudioUi({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          height: 75,
          width: Get.width / 1.6,
          margin: EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            gradient: AppColors.primaryLinearGradient,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5),
              topRight: Radius.circular(5),
              bottomLeft: Radius.circular(5),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 75,
                width: Get.width / 1.6,
                margin: EdgeInsets.only(left: 6, right: 6, top: 6, bottom: 15),
                padding: EdgeInsets.symmetric(horizontal: 10),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Row(
                  children: [
                    // Lottie.asset(AppAsset.lottieUpload, width: 35),
                    5.width,
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          overlayShape: SliderComponentShape.noOverlay,
                          activeTrackColor: AppColors.appColor,
                          thumbColor: AppColors.appColor,
                          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
                          trackHeight: 5,
                        ),
                        child: Slider(
                          min: 0,
                          max: 10,
                          value: 0,
                          onChanged: (value) {},
                        ),
                      ),
                    ),
                    3.width,
                    Container(
                      height: 40,
                      width: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                      child: Image.asset(
                        AppAsset.microPhoneIcon,
                        width: 20,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 20,
                right: 70,
                child: Text(
                  CustomFormatAudioTime.convert(0),
                  style: AppFontStyle.fontStyleW500(fontColor: AppColors.primary, fontSize: 9),
                ),
              ),
              Positioned(
                bottom: 3,
                right: 8,
                child: Text(
                  CustomFormatChatTime.convert(DateTime.now().toString()),
                  style: AppFontStyle.fontStyleW500(fontColor: AppColors.white, fontSize: 8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/*
class ReceiverAudioUi extends StatefulWidget {
  const ReceiverAudioUi({super.key, required this.id, required this.audio, required this.time});

  final String id;
  final String audio;
  final String time;

  @override
  State<ReceiverAudioUi> createState() => _ReceiverAudioUiState();
}

class _ReceiverAudioUiState extends State<ReceiverAudioUi> {
  AudioPlayer audioPlayer = AudioPlayer();

  RxBool isPlaying = false.obs;
  RxBool isLoading = false.obs;

  RxInt audioDuration = 0.obs;
  RxInt audioCurrentDuration = 0.obs;

  final controller = Get.find<HostPersonalChatScreenController>();

  @override
  void initState() {
    onInit();
    super.initState();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  void onInit() async {
    try {
      isLoading.value = true;

      // await audioPlayer.play(UrlSource(testAudioUrl));
      await audioPlayer.play(UrlSource(widget.audio));
      onPauseAudio();

      final Duration? duration = await audioPlayer.getDuration();

      if (duration != null) {
        audioDuration.value = duration.inSeconds;
        Utils.showLog("Audio Duration => ${audioDuration.value}");
        isLoading.value = false;
      }

      audioPlayer.onPositionChanged.listen((event) {
        audioCurrentDuration.value = event.inSeconds;
        if (controller.currentPlayAudioId != widget.id && isPlaying.value) {
          onPauseAudio();
        }
      });
      audioPlayer.onPlayerComplete.listen(
        (event) async {
          audioCurrentDuration.value = 0;
          onPauseAudio();

          // await audioPlayer.play(UrlSource(testAudioUrl));

          await audioPlayer.play(UrlSource(widget.audio));
          onPauseAudio();
        },
      );
    } catch (e) {
      Utils.showLog("Audio Play Failed !! => $e");
    }
  }

  void onPlayAudio() async {
    isPlaying.value = true;

    audioPlayer.resume();
    controller.currentPlayAudioId = widget.id;
  }

  void onPauseAudio() {
    isPlaying.value = false;
    audioPlayer.pause();

    // audioPlayer.source
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(5),
              topRight: Radius.circular(5),
              bottomRight: Radius.circular(5),
            ),
          ),
          child: Container(
            height: 75,
            width: Get.width / 1.6,
            decoration: BoxDecoration(
              color: AppColors.chatPink,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 75,
                  width: Get.width / 1.6,
                  margin: EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 15),
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                  ),
                  child: Row(
                    children: [
                      Obx(
                        () => isLoading.value
                            ? Padding(
                                padding: EdgeInsets.only(right: 2.5, top: 5, bottom: 5),
                                // child: LoadingUi(size: 30),
                              )
                            : GestureDetector(
                                onTap: () => isPlaying.value ? onPauseAudio() : onPlayAudio(),
                                child: Icon(
                                  isPlaying.value ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  size: 30,
                                  color: AppColors.chatPink,
                                ),

                                // child: Image.asset(isPlaying.value ? AppAsset.icPause : AppAsset.icPlay, width: 30),
                              ),
                      ),
                      5.width,
                      Expanded(
                        child: Obx(
                          () => SliderTheme(
                            data: SliderThemeData(
                              overlayShape: SliderComponentShape.noOverlay,
                              activeTrackColor: AppColors.grey,
                              thumbColor: AppColors.grey,
                              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
                              trackHeight: 5,
                            ),
                            child: Slider(
                              min: 0,
                              max: audioDuration.value.toDouble(),
                              value: audioCurrentDuration.value.toDouble(),
                              onChanged: (value) {
                                audioPlayer.seek(Duration(seconds: value.toInt()));
                              },
                            ),
                          ),
                        ),
                      ),
                      3.width,
                      Container(
                        height: 40,
                        width: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.grey,
                        ),
                        child: Image.asset(
                          AppAsset.microPhoneIcon,
                          width: 20,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 70,
                  child: Obx(
                    () => Text(
                      CustomFormatAudioTime.convert(audioCurrentDuration.value),
                      style: AppFontStyle.fontStyleW500(fontColor: AppColors.primary, fontSize: 9),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 3,
                  right: 8,
                  child: Text(
                    widget.time,
                    style: AppFontStyle.fontStyleW500(fontColor: AppColors.white, fontSize: 8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
*/
class ReceiverAudioMessageWidget extends StatefulWidget {
  final String audioUrl;
  final String time;
  final String id;
  final dynamic chat;
  const ReceiverAudioMessageWidget({
    super.key,
    required this.audioUrl,
    required this.time,
    required this.id,
    required this.chat,
  });

  @override
  State<ReceiverAudioMessageWidget> createState() => _ReceiverAudioMessageWidgetState();
}

class _ReceiverAudioMessageWidgetState extends State<ReceiverAudioMessageWidget> {
  final AudioPlayer player = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();

    player.onDurationChanged.listen((newDuration) {
      setState(() => duration = newDuration);
    });

    player.onPositionChanged.listen((newPosition) {
      setState(() => position = newPosition);
    });

    player.onPlayerComplete.listen((_) {
      setState(() {
        isPlaying = false;
        position = Duration.zero;
      });
    });

    player.onPlayerStateChanged.listen((state) {
      isPlaying = state == PlayerState.playing;
    });
  }

  void onPlayAudio() async {
    try {
      final sanitizedUrl = widget.audioUrl.replaceAll('\\', '/');
      final fullUrl = '${Api.baseUrl}$sanitizedUrl';

      log("Attempting to play audio: $fullUrl");

      if (!isPlaying) {
        await player.play(UrlSource(fullUrl));
      } else {
        await player.pause();
      }
    } catch (e) {
      log("Audio playback error: $e");
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: Get.width / 1.6,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppColors.chatPink,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  height: 70,
                  width: Get.width / 1.6,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 75,
                        width: Get.width / 1.6,
                        margin: const EdgeInsets.only(bottom: 5),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                                onTap: () => onPlayAudio(),
                                child: Icon(
                                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  size: 30,
                                  color: AppColors.chatPink,
                                )

                                // child: Image.asset(isPlaying ? AppAsset.icPause1 : AppAsset.icPlay1, color: AppColors.pinkMessageColor, width: 24),
                                ),
                            5.width,
                            Expanded(
                              child: SliderTheme(
                                data: SliderThemeData(
                                  overlayShape: SliderComponentShape.noOverlay,
                                  activeTrackColor: AppColors.primary,
                                  thumbColor: AppColors.primary,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                                  trackHeight: 5,
                                ),
                                child: Slider(
                                  activeColor: AppColors.chatPink,
                                  min: 0,
                                  max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1,
                                  value: position.inSeconds.toDouble().clamp(0, duration.inSeconds.toDouble()),
                                  onChanged: (value) {
                                    player.seek(Duration(seconds: value.toInt()));
                                  },
                                ),
                              ),
                            ),
                            3.width,
                            Container(
                              height: 44,
                              width: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.chatPink),
                              child: Image.asset(
                                AppAsset.microPhoneIcon,
                                width: 20,
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        right: 70,
                        child: Text(
                          formatTime(position),
                          style: AppFontStyle.fontStyleW600(fontColor: AppColors.chatPink, fontSize: 9),
                        ),
                      ),
                    ],
                  ),
                ),
                GetBuilder<HostPersonalChatScreenController>(
                  builder: (logic) {
                    return Text(
                      logic.formatTimeFromDate(widget.chat.date),
                      style: AppFontStyle.fontStyleW600(fontColor: AppColors.white, fontSize: 8),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ).paddingOnly(bottom: 15),
    );
  }
}

class FullScreenImageView extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageView({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return DismissiblePage(
      direction: DismissiblePageDismissDirection.down, // drag down to dismiss
      onDismissed: () => Get.back(), // go back on dismiss
      isFullScreen: true, // optional, ensures it covers the full screen

      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: CustomProfileImage(
                  image: imageUrl,
                  fit: BoxFit.contain,
                  // loadingBuilder: (context, child, loadingProgress) {
                  //   if (loadingProgress == null) return child;
                  //   return const Center(child: CircularProgressIndicator());
                  // },
                  // errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.white),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: const CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: Icon(Icons.close, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
