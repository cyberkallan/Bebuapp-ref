import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/ui/user_flow/fake_outgoing_call_screen/controller/fake_outgoing_call_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

/// =================== outgoing2 Call View =================== ///
class FakeOutgoingCallView extends StatelessWidget {
  const FakeOutgoingCallView({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height,
      width: Get.width,
      child: Stack(
        children: [
          GetBuilder<FakeOutgoingCallController>(
            id: Constant.idVideoCall,
            builder: (logic) {
              return SizedBox(
                  height: Get.height,
                  width: Get.width,
                  child: CustomProfileImage(
                    image: logic.receiverImage ?? '',
                    fit: BoxFit.cover,
                  ));
            },
          ),
          BlurryContainer(
            blur: 10,
            elevation: 0,
            color: AppColors.white.withValues(alpha: 0.2),
            height: Get.height,
            width: Get.width,
            child: const SizedBox(), // Empty child just to apply blur
          ),
          GetBuilder<FakeOutgoingCallController>(
            id: Constant.idVideoCall,
            builder: (logic) {
              return Center(
                child: Column(
                  children: [
                    // const Spacer(),
                    RippleAnimation(
                      color: AppColors.white,
                      delay: const Duration(milliseconds: 100),
                      repeat: true,
                      minRadius: 50,
                      maxRadius: 75,
                      ripplesCount: 8,
                      duration: const Duration(seconds: 3),
                      child: Container(
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
                                  image: logic.receiverImage ?? '',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ).paddingOnly(bottom: 10),
                    ).paddingOnly(top: Get.height * 0.1),
                    Text(
                      logic.receiverName ?? '',
                      style: AppFontStyle.fontStyleW700(
                        fontSize: 22,
                        fontColor: AppColors.white,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(logic.callType == "audio" ? EnumLocale.txtAudioCalling.name.tr : EnumLocale.txtVideoCalling.name.tr,
                            style: AppFontStyle.fontStyleW600(fontSize: 20, fontColor: AppColors.white)),
                        Lottie.asset(
                          AppAsset.callDotLoadingWhite,
                          height: 30,
                        ).paddingOnly(top: 10)
                      ],
                    ).paddingOnly(bottom: Get.height * 0.5),
                  ],
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: GetBuilder<FakeOutgoingCallController>(
              id: Constant.idSpeakerOpen,
              builder: (logic) {
                return GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                      height: 65,
                      width: 65,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.red),
                      child: Image.asset(AppAsset.callCut).paddingAll(15)),
                );
              },
            ).paddingOnly(left: 40, right: 40, bottom: 100),
          ),
        ],
      ),
    );
  }
}

class FakeAudioOutgoingCallView extends StatelessWidget {
  const FakeAudioOutgoingCallView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FakeOutgoingCallController>(
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
              // GetBuilder<FakeOutgoingCallController>(
              //   builder: (controller) {
              //     final seconds = controller.remainingSeconds.toString().padLeft(2, '0');
              //
              //     return Text("${EnumLocale.txtPleaseWait.name.tr}$seconds ${EnumLocale.txtSec.name.tr}",
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
                      text: "${EnumLocale.txtMute.name.tr} \n${logic.micMute ? EnumLocale.txtOn.name.tr : EnumLocale.txtOff.name.tr}",
                      iconColor: AppColors.appColor,
                      // icon: AppAsset.micMute,
                      icon: logic.micMute == true ? AppAsset.micMute : AppAsset.microPhoneIcon,
                      onTap: () {
                        logic.toggleMicMute();
                      },
                    ),
                    buildControlButton(
                      text: '${logic.isSpeakerOn ? EnumLocale.txtSpeaker.name.tr : EnumLocale.txtEarpiece.name.tr}\n${EnumLocale.txtOn.name.tr}',
                      // AppAsset.speakerOn,
                      iconColor: AppColors.appColor,

                      // icon: AppAsset.speakerOff,
                      icon: logic.isSpeakerOn == false ? AppAsset.speakerOff : AppAsset.speakerOn,

                      onTap: () {
                        logic.toggleSpeaker();
                      },
                    ),
                    GetBuilder<FakeOutgoingCallController>(
                        id: Constant.idSpeakerOpen,
                        builder: (context) {
                          return buildControlButton(
                            text: EnumLocale.txtEndCall.name.tr,
                            icon: AppAsset.callCut,
                            iconColor: AppColors.white,
                            bgColor: Colors.red,
                            onTap: () {
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
