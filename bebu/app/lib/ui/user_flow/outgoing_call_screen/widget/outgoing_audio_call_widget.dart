import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/socket/socket_emit.dart';
import 'package:talk_in/ui/user_flow/outgoing_call_screen/controller/outgoing_call_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class OutgoingAudioCallView extends StatelessWidget {
  const OutgoingAudioCallView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OutgoingCallController>(
        id: Constant.idVideoCall,
        builder: (logic) {
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
              SizedBox(
                  height: 100,
                  width: 100,
                  child: ClipOval(
                    child: CustomProfileImage(
                      image: logic.receiverImage ?? '',
                      fit: BoxFit.cover,
                    ),
                  )).paddingOnly(bottom: 20),
              Text(
                logic.receiverName ?? '',
                textAlign: TextAlign.center,
                style: AppFontStyle.fontStyleW600(
                  fontSize: 22,
                  fontColor: AppColors.black,
                ),
              ).paddingOnly(bottom: 15),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    EnumLocale.txtCalling.name.tr,
                    textAlign: TextAlign.center,
                    style: AppFontStyle.fontStyleW500(
                      fontSize: 22,
                      fontColor: AppColors.black.withValues(alpha: 0.80),
                    ),
                  ).paddingOnly(bottom: 15),
                  Lottie.asset(
                    AppAsset.callDotLoading,
                    height: 30,
                  ).paddingOnly(bottom: 8),
                ],
              ),
              // GetBuilder<OutgoingCallController>(
              //   builder: (controller) {
              //     return Text("${EnumLocale.txtPleaseWait.name.tr}${controller.remainingSeconds} ${EnumLocale.txtSec.name.tr}",
              //         textAlign: TextAlign.center,
              //         style: AppFontStyle.fontStyleW500(
              //           fontSize: 15,
              //           fontColor: AppColors.black.withValues(alpha: 0.80),
              //         )).paddingOnly(bottom: 10);
              //   },
              // ),
              Spacer(),
              Container(
                padding: EdgeInsets.only(top: 20, bottom: 20, left: 22, right: 22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  color: AppColors.black.withValues(alpha: 0.80),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildControlButton(
                      // text: "Mute \n${logic.micMute ? 'on' : 'off'}",
                      text: "${EnumLocale.txtMute.name.tr} \n${logic.micMute ? EnumLocale.txtOn.name.tr : EnumLocale.txtOff.name.tr}",

                      iconColor: AppColors.appColor,
                      // icon: AppAsset.micMute,
                      icon: logic.micMute == true ? AppAsset.micMute : AppAsset.microPhoneIcon,
                      onTap: () {
                        logic.toggleMicMute();
                      },
                    ),
                    buildControlButton(
                      // text: "Speaker \n${logic.isSpeakerOn ? 'on' : 'off'}",
                      text: '${logic.isSpeakerOn ? EnumLocale.txtSpeaker.name.tr : EnumLocale.txtEarpiece.name.tr}\n${EnumLocale.txtOn.name.tr}',

                      // AppAsset.speakerOn,
                      iconColor: AppColors.appColor,

                      // icon: AppAsset.speakerOff,
                      icon: logic.isSpeakerOn == false ? AppAsset.speakerOff : AppAsset.speakerOn,

                      onTap: () {
                        logic.toggleSpeaker();
                      },
                    ),
                    GetBuilder<OutgoingCallController>(
                        id: Constant.idSpeakerOpen,
                        builder: (context) {
                          return buildControlButton(
                            text: EnumLocale.txtEndCall.name.tr,
                            icon: AppAsset.callCut,
                            iconColor: AppColors.white,
                            bgColor: Colors.red,
                            onTap: () {
                              SocketEmit.emitCallerCallCut(
                                callerId: logic.callerId ?? '',
                                receiverId: logic.receiverId ?? '',
                                callId: logic.callId ?? '',
                                callType: logic.callType ?? '',
                                callMode: logic.callMode ?? '',
                                callerRole: logic.callerRole ?? '',
                                receiverRole: logic.receiverRole ?? '',
                              );
                              Get.back();
                            },
                          );
                        }),
                  ],
                ).paddingSymmetric(horizontal: 13),
              ),
            ],
          );
        });
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
