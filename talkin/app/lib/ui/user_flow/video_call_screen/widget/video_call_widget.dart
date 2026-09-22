import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:talk_in/socket/socket_emit.dart';
import 'package:talk_in/ui/user_flow/gifts/view/call_gift_button.dart';
import 'package:talk_in/ui/user_flow/video_call_screen/controller/video_call_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/font_style.dart';

/// =================== Video Call View =================== ///
class VideoCallView1 extends StatelessWidget {
  const VideoCallView1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary.withValues(alpha: 0.5),
      body: SizedBox(
        height: Get.height,
        width: Get.width,
        child: GetBuilder<VideoCallController>(
          id: Constant.idVideoCall,
          builder: (logic) {
            return Stack(
              children: [
                Positioned.fill(
                  child: Stack(
                    children: [
                      Container(
                        color: AppColors.black,
                        width: Get.width,
                        height: Get.height,
                        child: Center(
                          child: logic.remoteView ??
                              LoadingAnimationWidget.threeArchedCircle(
                                color: AppColors.white,
                                size: 50,
                              ),
                        ),
                      ),

                      // SHOW OVERLAYS
                      if (logic.remoteVideoOff)
                        Container(
                          color: AppColors.black.withValues(alpha: 0.55),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(AppAsset.videoMute, color: Colors.white, height: 30).paddingOnly(right: 12),
                                if (logic.remoteMicMute) Image.asset(AppAsset.micMute, color: Colors.white, height: 30),
                              ],
                            ),
                          ),
                        )
                      else if (logic.remoteMicMute)
                        Align(
                          alignment: Alignment.center,
                          child: Image.asset(AppAsset.micMute, color: Colors.white, height: 30),
                        ),
                    ],
                  ),
                ),
                Positioned(
                  top: 35,
                  right: 20,
                  child: Container(
                    height: 160,
                    width: 132,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        logic.localView ??
                            Center(
                              child: logic.remoteView ??
                                  LoadingAnimationWidget.threeArchedCircle(
                                    color: AppColors.white,
                                    size: 50,
                                  ),
                            ),
                        if (logic.isCameraOff)
                          Container(
                            height: 160,
                            width: 132,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: AppColors.black.withValues(alpha: 0.55),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(AppAsset.videoMute, color: Colors.white, height: 20).paddingOnly(right: 8),
                                if (logic.micMute) Image.asset(AppAsset.micMute, color: Colors.white, height: 20),
                              ],
                            ),
                          )
                        else if (logic.micMute)
                          Align(
                            alignment: Alignment.center,
                            child: Image.asset(AppAsset.micMute, color: Colors.white, height: 20),
                          ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60),
                      color: AppColors.black.withValues(alpha: 0.40),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ControlButton(
                          icon: logic.micMute == true ? AppAsset.micMute : AppAsset.microPhoneIcon,
                          bgColor: Colors.white,
                          onTap: () {
                            logic.onMicMute();
                          },
                        ),
                        ControlButton(
                          icon: logic.isCameraOff == true ? AppAsset.videoMute : AppAsset.videoCallIcon,
                          bgColor: Colors.white,
                          onTap: () {
                            logic.onCameraOff();
                          },
                        ),
                        ControlButton(
                          icon: AppAsset.cameraFlipIcon,
                          bgColor: Colors.white,
                          onTap: () {
                            logic.onCameraTurn();
                          },
                        ),
                        CallGiftButton(
                          callerId: logic.callerId,
                          receiverId: logic.receiverId,
                          callerRole: logic.callerRole,
                          receiverRole: logic.receiverRole,
                          otherName: logic.receiverName,
                          otherImage: logic.receiverImage,
                          callId: logic.callId,
                        ),
                        ControlButton(
                          icon: AppAsset.callCut,
                          bgColor: Colors.red,
                          onTap: () {
                            SocketEmit.emitCallTerminated(
                              callerId: logic.callerId ?? '',
                              receiverId: logic.receiverId ?? '',
                              callId: logic.callId ?? '',
                              callType: logic.callType ?? '',
                              callMode: logic.callMode ?? '',
                              callerRole: logic.callerRole ?? '',
                              receiverRole: logic.receiverRole ?? '',
                              receiverImage: logic.receiverImage ?? '',
                              receiverName: logic.receiverName ?? '',
                            );
                          },
                        ),
                      ],
                    ).paddingSymmetric(horizontal: 10),
                  ).paddingSymmetric(horizontal: 28),
                ),
                Positioned(
                  top: 50,
                  left: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4).copyWith(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: AppColors.black.withValues(alpha: 0.40),
                        ),
                        child: Row(
                          children: [
                            // const Icon(Icons.monetization_on, color: Colors.yellow),
                            Image.asset(
                              AppAsset.starCoin,
                              height: 26,
                              width: 26,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              Database.fetchLoginUserProfileModel?.user?.isListener == true
                                  ? (logic.listenerCoinModel?.coin ?? 0).toString()
                                  : (logic.userCoinModel?.coin ?? 0).toString(),
                              style: AppFontStyle.fontStyleW700(fontSize: 17, fontColor: AppColors.yellow),
                            ),
                          ],
                        ),
                      ).paddingOnly(bottom: 10),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: AppColors.black.withValues(alpha: 0.40),
                            ),
                            child: Center(
                              child: GetBuilder<VideoCallController>(
                                id: Constant.idVideoCall,
                                builder: (controller) => Text(
                                  overflow: TextOverflow.ellipsis,
                                  controller.formattedTime.toString(),
                                  style: AppFontStyle.fontStyleW400(fontColor: AppColors.white, fontSize: 12),
                                ),
                              ),
                            ),
                          ).paddingOnly(right: 6),
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.black.withValues(alpha: 0.40),
                            ),
                            child: Center(
                              child: Image.asset(
                                AppAsset.flagIcon,
                                height: 12,
                                width: 12,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ControlButton extends StatelessWidget {
  final String icon;
  final Color bgColor;
  final VoidCallback? onTap;

  const ControlButton({
    super.key,
    required this.icon,
    this.bgColor = Colors.white,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(
        radius: 28,
        backgroundColor: bgColor,
        child: Image.asset(
          icon,
          color: bgColor == Colors.white ? AppColors.darkPurple : Colors.white,
          height: 26,
          width: 26,
        ),
      ),
    );
  }
}
