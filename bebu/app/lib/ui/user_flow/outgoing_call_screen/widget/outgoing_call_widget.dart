import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/socket/socket_emit.dart';
import 'package:talk_in/ui/user_flow/outgoing_call_screen/controller/outgoing_call_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

/// =================== outgoing2 Call View =================== ///
class OutgoingCallView extends StatelessWidget {
  const OutgoingCallView({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height,
      width: Get.width,
      child: Stack(
        children: [
          GetBuilder<OutgoingCallController>(
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
          GetBuilder<OutgoingCallController>(
            id: Constant.idVideoCall,
            builder: (logic) {
              return Center(
                child: Column(
                  children: [
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
                        ).paddingOnly(top: 10),
                      ],
                    ).paddingOnly(bottom: Get.height * 0.5),
                  ],
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: GetBuilder<OutgoingCallController>(
              id: Constant.idSpeakerOpen,
              builder: (logic) {
                return GestureDetector(
                  onTap: () {
                    // Get.toNamed(AppRoutes.incomingCallScreen);

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
