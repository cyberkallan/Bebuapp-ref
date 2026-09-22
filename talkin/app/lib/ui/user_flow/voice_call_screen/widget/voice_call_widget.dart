import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/socket/socket_emit.dart';
import 'package:talk_in/ui/user_flow/gifts/view/call_gift_button.dart';
import 'package:talk_in/ui/user_flow/voice_call_screen/controller/voice_call_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

/// =================== Video Call View =================== ///
class VoiceCallView extends StatelessWidget {
  const VoiceCallView({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height,
      width: Get.width,
      child: Stack(
        children: [
          GetBuilder<VoiceCallController>(
            id: Constant.idVideoCall,
            builder: (logic) {
              return SizedBox(
                height: Get.height,
                width: Get.width,
                child: CustomProfileImage(
                  image: logic.callerId != Database.loginUserId ? logic.callerImage ?? '' : logic.receiverImage ?? '',
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
          BlurryContainer(
            blur: 20,
            elevation: 0,
            color: AppColors.white.withValues(alpha: 0.2),
            height: Get.height,
            width: Get.width,
            child: const SizedBox(), // Empty child just to apply blur
          ),
          GetBuilder<VoiceCallController>(
            id: Constant.idVideoCall,
            builder: (logic) {
              return Center(
                child: Column(
                  children: [
                    const Spacer(),
                    Container(
                      height: 160,
                      width: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.white.withValues(alpha: 0.2),
                            AppColors.white.withValues(alpha: 0.2),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4), // White border thickness
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.white, // White border color
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(3), // Inner padding
                            child: ClipOval(
                              child: CustomProfileImage(
                                image: logic.callerId != Database.loginUserId ? logic.callerImage ?? '' : logic.receiverImage ?? '',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      logic.callerId != Database.loginUserId ? logic.callerName ?? "" : logic.receiverName ?? "",
                      style: AppFontStyle.fontStyleW900(
                        fontSize: 22,
                        fontColor: AppColors.white,
                      ),
                    ),
                    Text(
                      logic.formattedTime ?? "",
                      style: AppFontStyle.fontStyleW700(
                        fontSize: 14,
                        fontColor: AppColors.white,
                      ),
                    ).paddingOnly(bottom: Get.height * 0.56),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: GetBuilder<VoiceCallController>(
              id: Constant.idVideoCall,
              builder: (controller) {
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(60),
                    color: AppColors.black.withValues(alpha: 0.40),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GetBuilder<VoiceCallController>(
                          id: Constant.idMicMute,
                          builder: (context) {
                            return buildControlButton(
                              controller.isMicMute == true ? AppAsset.micMute : AppAsset.microPhoneIcon,
                              onTap: () {
                                controller.onMicMute();
                              },
                            );
                          }),
                      GetBuilder<VoiceCallController>(
                          id: Constant.idSpeakerOpen,
                          builder: (context) {
                            return buildControlButton(
                              // AppAsset.speakerOn,
                              controller.isSpeakerOn == false ? AppAsset.speakerOff : AppAsset.speakerOn,

                              onTap: () {
                                controller.onSpeakerOn();
                              },
                            );
                          }),
                      buildControlButton(
                        AppAsset.callCut,
                        bgColor: Colors.red,
                        onTap: () {
                          SocketEmit.emitCallTerminated(
                            callerId: controller.callerId ?? '',
                            receiverId: controller.receiverId ?? '',
                            callId: controller.callId ?? '',
                            callType: controller.callType ?? '',
                            callMode: controller.callMode ?? '',
                            callerRole: controller.callerRole ?? '',
                            receiverRole: controller.receiverRole ?? '',
                            receiverImage: controller.receiverImage ?? '',
                            receiverName: controller.receiverName ?? '',
                          );
                          // Get.toNamed(AppRoutes.callCutScreen);
                        },
                      ),
                    ],
                  ).paddingSymmetric(horizontal: 13),
                ).paddingSymmetric(horizontal: 32);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildControlButton(String icon, {Color bgColor = Colors.white, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(
        radius: 28,
        backgroundColor: bgColor,
        child: Image.asset(
          icon,
          color: bgColor == AppColors.white ? AppColors.darkPurple : Colors.white,
          height: 26,
          width: 26,
        ),
      ),
    );
  }
}

class VoiceCallView1 extends StatelessWidget {
  const VoiceCallView1({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
            child: Text(
          "bebu",
          style: AppFontStyle.fontStyleKaushanW400(
            font: FontWeight.w600,
            fontSize: 32,
            fontColor: AppColors.black,
          ),
        )).paddingOnly(bottom: Get.height * 0.02, top: Get.height * 0.06),
        GetBuilder<VoiceCallController>(
            id: Constant.idVideoCall,
            builder: (logic) {
              return SizedBox(
                  height: 100,
                  width: 100,
                  child: ClipOval(
                    child: CustomProfileImage(
                      image: logic.callerId != Database.loginUserId ? logic.callerImage ?? '' : logic.receiverImage ?? '',
                      fit: BoxFit.cover,
                    ),
                  )).paddingOnly(bottom: 20);
            }),
        GetBuilder<VoiceCallController>(
            id: Constant.idVideoCall,
            builder: (logic) {
              return Text(
                logic.callerId != Database.loginUserId ? logic.callerName ?? "" : logic.receiverName ?? "",
                textAlign: TextAlign.center,
                style: AppFontStyle.fontStyleW600(
                  fontSize: 22,
                  fontColor: AppColors.black,
                ),
              ).paddingOnly(bottom: 15);
            }),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.lock, color: AppColors.appColor, size: 15),
            Text(
              EnumLocale.txtEndToEndEncrypted.name.tr,
              textAlign: TextAlign.center,
              style: AppFontStyle.fontStyleW500(
                fontSize: 13,
                fontColor: AppColors.black.withValues(alpha: 0.80),
              ),
            ),
          ],
        ).paddingOnly(bottom: 15),
        GetBuilder<VoiceCallController>(
            id: Constant.idVideoCall,
            builder: (logic) {
              return Text(
                logic.formattedTime ?? "",
                style: AppFontStyle.fontStyleW500(
                  fontSize: 21,
                  fontColor: AppColors.black,
                ),
              );
            }),
        Spacer(),
        GetBuilder<VoiceCallController>(
          id: Constant.idVideoCall,
          builder: (controller) {
            return Container(
              padding: EdgeInsets.only(top: 20, bottom: 20, left: 22, right: 22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                color: AppColors.black.withValues(alpha: 0.80),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GetBuilder<VoiceCallController>(
                      id: Constant.idMicMute,
                      builder: (logic) {
                        return buildControlButton(
                          text: "${EnumLocale.txtMute.name.tr} \n${logic.isMicMute ? EnumLocale.txtOn.name.tr : EnumLocale.txtOff.name.tr}",
                          iconColor: AppColors.appColor,
                          icon: controller.isMicMute == true ? AppAsset.micMute : AppAsset.microPhoneIcon,
                          onTap: () {
                            controller.onMicMute();
                          },
                        );
                      }),
                  GetBuilder<VoiceCallController>(
                      id: Constant.idSpeakerOpen,
                      builder: (logic) {
                        return buildControlButton(
                          text: '${logic.isSpeakerOn ? EnumLocale.txtSpeaker.name.tr : EnumLocale.txtEarpiece.name.tr}\n${EnumLocale.txtOn.name.tr}',
                          iconColor: AppColors.appColor,
                          icon: controller.isSpeakerOn == false ? AppAsset.speakerOff : AppAsset.speakerOn,
                          onTap: () {
                            controller.onSpeakerOn();
                          },
                        );
                      }),
                  CallGiftButton(
                    callerId: controller.callerId,
                    receiverId: controller.receiverId,
                    callerRole: controller.callerRole,
                    receiverRole: controller.receiverRole,
                    otherName: controller.receiverName,
                    otherImage: controller.receiverImage,
                    callId: controller.callId,
                    label: 'Gift',
                  ),
                  buildControlButton(
                    text: EnumLocale.txtEndCall.name.tr,
                    icon: AppAsset.callCut,
                    iconColor: AppColors.white,
                    bgColor: Colors.red,
                    onTap: () {
                      SocketEmit.emitCallTerminated(
                        callerId: controller.callerId ?? '',
                        receiverId: controller.receiverId ?? '',
                        callId: controller.callId ?? '',
                        callType: controller.callType ?? '',
                        callMode: controller.callMode ?? '',
                        callerRole: controller.callerRole ?? '',
                        receiverRole: controller.receiverRole ?? '',
                        receiverImage: controller.receiverImage ?? '',
                        receiverName: controller.receiverName ?? '',
                      );
                      // Get.toNamed(AppRoutes.callCutScreen);
                    },
                  ),
                ],
              ).paddingSymmetric(horizontal: 13),
            );
          },
        ),
      ],
    );
  }

  Widget buildControlButton({String? icon, Color bgColor = Colors.white, Color iconColor = Colors.white, VoidCallback? onTap, String text = ''}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: bgColor),
            child: Image.asset(
              icon ?? '',
              color: iconColor,
              height: 26,
              width: 26,
            ),
          ).paddingOnly(bottom: 6),
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppFontStyle.fontStyleW500(fontSize: 13, fontColor: AppColors.white),
          )
        ],
      ),
    );
  }
}
