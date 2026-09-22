import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:talk_in/ui/user_flow/fake_video_call_screen/controller/fake_video_call_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/font_style.dart';

class FakeVideoCallView extends StatelessWidget {
  const FakeVideoCallView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FakeVideoCallController>(builder: (logic) {
      return Stack(
        children: [
          // Video Player
          GetBuilder<FakeVideoCallController>(
            id: Constant.initializeVideoPlayer,
            builder: (controller) {
              return Container(
                color: AppColors.black,
                width: Get.width,
                height: Get.height,
                child: controller.chewieController != null &&
                        controller.videoPlayerController != null &&
                        controller.videoPlayerController!.value.isInitialized
                    ? SizedBox.expand(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                              width: controller.videoPlayerController?.value.size.width ?? 0,
                              height: controller.videoPlayerController?.value.size.height ?? 0,
                              child: (controller.chewieController != null &&
                                      controller.videoPlayerController != null &&
                                      controller.videoPlayerController!.value.isInitialized)
                                  ? Chewie(controller: controller.chewieController!)
                                  : Container() // <-- fallback if controller is disposed,
                              ),
                        ),
                      )
                    : Center(
                        child: LoadingAnimationWidget.threeArchedCircle(
                          color: AppColors.white,
                          size: 50,
                        ),
                      ),
              );
            },
          ),

          // Camera Preview
          GetBuilder<FakeVideoCallController>(
            id: Constant.onInitializeCamera,
            builder: (controller) {
              if (controller.cameraController != null && (controller.cameraController?.value.isInitialized ?? false) && controller.isVideoOn) {
                final mediaSize = MediaQuery.of(context).size;
                final scale = 1 / (controller.cameraController!.value.aspectRatio * mediaSize.aspectRatio);

                return Positioned(
                  top: 50,
                  right: 20,
                  width: 135,
                  height: 170,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: ClipRect(
                      clipper: _MediaSizeClipper(mediaSize),
                      child: Transform.scale(
                        scale: scale,
                        alignment: Alignment.topCenter,
                        child: CameraPreview(controller.cameraController!),
                      ),
                    ),
                  ),
                );
              } else {
                return Positioned(
                  top: 50,
                  right: 20,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      width: 135,
                      height: 170,
                      color: AppColors.black,
                      child: controller.isVideoOn
                          ? Center(
                              child: LoadingAnimationWidget.threeArchedCircle(
                                color: AppColors.white,
                                size: 50,
                              ),
                            )
                          : Icon(
                              Icons.videocam_off,
                              size: 25,
                              color: AppColors.white,
                            ),
                    ),
                  ),
                );
              }
            },
          ),

          // Control buttons
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
                  GetBuilder<FakeVideoCallController>(
                      id: Constant.idMuteMic,
                      builder: (logic) {
                        return ControlButton(
                          icon: logic.isMute == true ? AppAsset.micMute : AppAsset.microPhoneIcon,
                          bgColor: Colors.white,
                          onTap: () {
                            logic.muteMic();
                          },
                        );
                      }),
                  GetBuilder<FakeVideoCallController>(
                      id: Constant.idToggleVideo,
                      builder: (logic) {
                        return ControlButton(
                          icon: logic.isVideoOn ? AppAsset.videoCallIcon : AppAsset.videoMute,
                          bgColor: Colors.white,
                          onTap: () {
                            logic.toggleVideo();
                          },
                        );
                      }),
                  GetBuilder<FakeVideoCallController>(
                      id: Constant.idToggleCamera,
                      builder: (logic) {
                        return ControlButton(
                          icon: AppAsset.cameraFlipIcon,
                          bgColor: Colors.white,
                          onTap: () {
                            logic.toggleCamera();
                          },
                        );
                      }),
                  ControlButton(
                    icon: AppAsset.callCut,
                    bgColor: Colors.red,
                    onTap: () {
                      if (logic.isBackProfile == true) {
                        log("Is Back Profile ${logic.isBackProfile}");
                        Get.back();
                      } else {
                        log("Is Back Profile ${logic.isBackProfile}");
                        Get.back();
                        // Get.back();
                      }
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
                      GetBuilder<FakeVideoCallController>(
                        builder: (controller) {
                          return Text(
                            "${controller.randomNumber.value}",
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.yellow),
                          );
                        },
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
                        child: GetBuilder<FakeVideoCallController>(
                          id: Constant.idOnVideoCall,
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
    });
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

class _MediaSizeClipper extends CustomClipper<Rect> {
  final Size mediaSize;
  const _MediaSizeClipper(this.mediaSize);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, mediaSize.width, mediaSize.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}
