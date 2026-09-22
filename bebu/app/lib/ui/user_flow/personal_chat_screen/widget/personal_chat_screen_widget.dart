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
import 'package:talk_in/ui/user_flow/personal_chat_screen/controller/personal_chat_screen_controller.dart';
import 'package:talk_in/ui/user_flow/personal_chat_screen/model/personal_chat_model.dart';
import 'package:talk_in/utils/api.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';
import 'package:vibration/vibration.dart';

class ChatScreenAppBar extends StatelessWidget {
  const ChatScreenAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PersonalChatScreenController>(
      builder: (controller) {
        return Container(
          padding: EdgeInsets.only(top: Get.height * 0.035),
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
                  Get.toNamed(
                    AppRoutes.profileDetailScreenView,
                    arguments: controller.receiverId,
                  );
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
                          child: ClipOval(
                            child: CustomProfileImage(image: controller.receiverImage.toString()),
                          ),
                        ).paddingAll(1),
                      ).paddingOnly(right: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.receiverName.toString(),
                            style: AppFontStyle.fontStyleW700(fontSize: 16, fontColor: AppColors.black),
                          ).paddingOnly(bottom: 2),
                          controller.receiverStatusLabel == "true" || controller.receiverStatusLabel == "Available"
                              ? Container(
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
                              : Container(
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
                        ],
                      ),
                    ],
                  ),
                ),
              )),
              // Spacer(),
              if (controller.availableForPrivateAudioCall == true || controller.availableForPrivateVideoCall == true)
                GestureDetector(
                  onTap: () {
                    // controller.onClickVideoCall();
                    // if (controller.isFake == true) {
                    //   Utils.showLog("this is fake Listener>>>>>>>>>");
                    //   Get.toNamed(
                    //     AppRoutes.fakeOutgoingCall,
                    //     arguments: [
                    //       controller.receiverName,
                    //       controller.receiverImage,
                    //       controller.fakeVideoUrl,
                    //       controller.isBackProfile,
                    //     ],
                    //   );
                    // } else {
                    Get.bottomSheet(
                      TalkNowButtonBottomSheet(
                        showMessage: false,
                        availableForPrivateAudioCall: controller.availableForPrivateAudioCall ?? false,
                        availableForPrivateVideoCall: controller.availableForPrivateVideoCall ?? false,
                        isFake: controller.isFake ?? false,
                        fakeVideo: controller.fakeVideoUrl ?? [],
                        fakeAudio: controller.fakeAudioUrl ?? "",
                        videoCallRatePrivate: controller.ratePrivateVideoCall.toString(),
                        audioCallRatePrivate: controller.ratePrivateAudioCall.toString(),
                        callerId: Database.fetchLoginUserProfileModel?.user?.isListener == false
                            ? Database.fetchLoginUserProfileModel?.user?.id ?? ''
                            : Database.fetchLoginUserProfileModel?.user?.listenerId ?? '',
                        receiverId: controller.receiverId ?? '',
                        receiverName: controller.receiverName ?? '',
                        receiverImage: controller.receiverImage ?? '',
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
                    // Get.toNamed(AppRoutes.searchScreen);
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
          ).paddingOnly(top: 6, bottom: 4),
        );
      },
    );
  }
}

class PersonalChatBottomView extends StatelessWidget {
  const PersonalChatBottomView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PersonalChatScreenController>(
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
                              onTap: () async {
                                controller.showImagePickerDialog();
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
              GetBuilder<PersonalChatScreenController>(
                id: Constant.idSendMsg,
                builder: (controller) {
                  return GestureDetector(
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
                      ));
                },
              )
            ],
          ),
        );
      },
    );
  }
}

class ChatImageWidget extends StatelessWidget {
  final PersonalChat msg;
  final PersonalChatScreenController controller;
  final bool isRead;

  const ChatImageWidget({
    super.key,
    required this.msg,
    required this.controller,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSender = msg.senderId == Database.fetchLoginUserProfileModel?.user?.id;

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
            crossAxisAlignment: msg.senderId == Database.loginUserId ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
                    if (Database.loginUserId == msg.senderId)
                      Image.asset(
                        isRead ? AppAsset.read2Icon : AppAsset.unreadMsgIcon,
                        height: 18,
                        width: 16,
                        color: AppColors.darkPurple,
                      ),
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

class ChatTextWidget extends StatelessWidget {
  final PersonalChat msg;
  final PersonalChatScreenController controller;
  final bool isRead;

  const ChatTextWidget({
    super.key,
    required this.msg,
    required this.controller,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSender = msg.senderId == Database.loginUserId;

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
                    child: CustomProfileImage(image: Database.fetchLoginUserProfileModel?.user?.profilePic.toString() ?? ''),
                  ),
                ).paddingAll(1),
              )).paddingOnly(bottom: 4),
        ],
      ],
    );
  }
}

class ChatVideoCallWidget extends StatelessWidget {
  final PersonalChat msg;
  final String callDuration;
  final PersonalChatScreenController controller;

  const ChatVideoCallWidget({
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
              msg.callType == 1 || msg.callType == 2 ? AppAsset.chatVideoCallIcon : AppAsset.missedVideoCall,
              height: 26,
              width: 26,
              // color: AppColors.darkPurple,
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
          Text(
            controller.formatTimeFromDate(msg.date),
            style: AppFontStyle.fontStyleW500(fontSize: 9, fontColor: AppColors.darkPurple),
          ).paddingOnly(top: Get.height * 0.06),
        ],
      ),
    );
  }
}

class ChatAudioCallWidget extends StatelessWidget {
  final PersonalChat msg;
  final String audioCallDuration;
  final PersonalChatScreenController controller;

  const ChatAudioCallWidget({
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
      // padding: const EdgeInsets.only(bottom: 3, left: 12, right: 12),
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
                            GetBuilder<PersonalChatScreenController>(
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
                          isPlaying ? formatTime(position) : formatTime(duration),
                          style: AppFontStyle.fontStyleW600(fontColor: AppColors.chatPurple, fontSize: 9),
                        ),
                      ),
                    ],
                  ),
                ),
                GetBuilder<PersonalChatScreenController>(
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
            color: AppColors.grey,
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
                          activeTrackColor: AppColors.grey,
                          thumbColor: AppColors.grey,
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
                GetBuilder<PersonalChatScreenController>(
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
                child: SendMessageImageFullScreen(
                  image: imageUrl,
                  fit: BoxFit.contain,
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
            ),
          ],
        ),
      ),
    );
  }
}
