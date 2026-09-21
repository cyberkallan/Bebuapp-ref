import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/ui/user_flow/fake_audio_call_screen/controller/fake_audio_call_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart' show AppFontStyle;

class FakeVoiceCallView extends StatelessWidget {
  const FakeVoiceCallView({super.key});

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
        GetBuilder<FakeAudioCallController>(
            id: Constant.idVideoCall,
            builder: (logic) {
              return SizedBox(
                  height: 100,
                  width: 100,
                  child: ClipOval(
                    child: CustomProfileImage(
                      image: logic.receiverImage ?? '',
                      fit: BoxFit.cover,
                    ),
                  )).paddingOnly(bottom: 20);
            }),
        GetBuilder<FakeAudioCallController>(
            id: Constant.idVideoCall,
            builder: (logic) {
              return Text(
                logic.receiverName ?? '',
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
              "End-to-end encrypted",
              textAlign: TextAlign.center,
              style: AppFontStyle.fontStyleW500(
                fontSize: 13,
                fontColor: AppColors.black.withValues(alpha: 0.80),
              ),
            ),
          ],
        ).paddingOnly(bottom: 15),
        GetBuilder<FakeAudioCallController>(
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
        GetBuilder<FakeAudioCallController>(
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
                  GetBuilder<FakeAudioCallController>(
                      id: Constant.idMicMute,
                      builder: (logic) {
                        return buildControlButton(
                          // text: "Mute \n${logic.isMicMute ? 'on' : 'off'}",
                          text: "${EnumLocale.txtMute.name.tr} \n${logic.isMicMute ? EnumLocale.txtOn.name.tr : EnumLocale.txtOff.name.tr}",

                          iconColor: AppColors.appColor,
                          icon: controller.isMicMute == true ? AppAsset.micMute : AppAsset.microPhoneIcon,
                          onTap: () {
                            controller.toggleMicMute();
                          },
                        );
                      }),
                  GetBuilder<FakeAudioCallController>(
                      id: Constant.idSpeakerOpen,
                      builder: (logic) {
                        return buildControlButton(
                          // text: "Speaker \n${logic.isSpeakerOn ? 'on' : 'off'}",
                          // text: "${EnumLocale.txtEarpiece.name.tr} \n${logic.isSpeakerOn ? EnumLocale.txtOff.name.tr : EnumLocale.txtOn.name.tr}",
                          text: '${logic.isSpeakerOn ? EnumLocale.txtSpeaker.name.tr : EnumLocale.txtEarpiece.name.tr}\n${EnumLocale.txtOn.name.tr}',

                          iconColor: AppColors.appColor,
                          icon: controller.isSpeakerOn == false ? AppAsset.speakerOff : AppAsset.speakerOn,
                          onTap: () {
                            controller.toggleSpeaker();
                          },
                        );
                      }),
                  buildControlButton(
                    text: "End \ncall",
                    icon: AppAsset.callCut,
                    iconColor: AppColors.white,
                    bgColor: Colors.red,
                    onTap: () {
                      Get.back();
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
