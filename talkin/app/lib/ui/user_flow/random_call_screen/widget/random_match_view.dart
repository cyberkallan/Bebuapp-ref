import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/socket/socket_emit.dart';
import 'package:talk_in/ui/user_flow/random_call_screen/controller/random_call_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class RandomMatchView extends StatefulWidget {
  const RandomMatchView({super.key});

  @override
  State<RandomMatchView> createState() => _RandomMatchViewState();
}

class _RandomMatchViewState extends State<RandomMatchView> {
  bool _isImagePrecached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isImagePrecached) {
      precacheImage(const AssetImage(AppAsset.randomMatchBg), context);
      _isImagePrecached = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Container(
        height: Get.height,
        width: Get.width,
        decoration: BoxDecoration(image: DecorationImage(image: AssetImage(AppAsset.randomMatchBg), fit: BoxFit.cover)),
        child: GetBuilder<RandomCallController>(builder: (controller) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Image.asset(
                    AppAsset.closeIcon,
                    color: AppColors.black,
                    height: 26,
                    width: 26,
                  ),
                ),
              ).paddingOnly(top: 65, right: 33, bottom: 36),
              Text(
                EnumLocale.txtItsAMatch.name.tr,
                style: AppFontStyle.fontStyleLato700(fontSize: 40, fontColor: AppColors.black),
              ).paddingOnly(bottom: 30),
              Center(
                child: RippleAnimation(
                  color: AppColors.profileText,
                  delay: const Duration(milliseconds: 100),
                  repeat: true,
                  minRadius: 80,
                  maxRadius: 25,
                  ripplesCount: 3,
                  duration: const Duration(seconds: 3),
                  child: SizedBox(
                    height: 100,
                    width: 100,
                    child: ClipOval(
                      child: CustomProfileImage(image: controller.randomAvailableListenerModel?.data?.image ?? ''),
                    ),
                  ),
                ).paddingSymmetric(horizontal: 45),
              ),
              Text(
                "${controller.randomAvailableListenerModel?.data?.name ?? ''}, ${controller.randomAvailableListenerModel?.data?.age ?? ''}",
                style: AppFontStyle.fontStyleW600(fontSize: 20, fontColor: AppColors.black),
              ).paddingOnly(top: 18),
              Text(
                "ID:${controller.randomAvailableListenerModel?.data?.uniqueId ?? ''}",
                style: AppFontStyle.fontStyleW500(fontSize: 14, fontColor: AppColors.black),
              ).paddingOnly(bottom: 21, top: 4),
              SizedBox(
                height: Get.height * 0.032,
                child: ListView.builder(
                  itemCount: controller.randomAvailableListenerModel?.data?.talkTopics?.length ?? 0,
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppColors.pink,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: Text(
                          controller.randomAvailableListenerModel?.data?.talkTopics?[index] ?? '',
                          style: AppFontStyle.fontStyleW500(
                            fontSize: 12,
                            fontColor: AppColors.white,
                          ),
                        ),
                      ),
                    ).paddingOnly(right: 5);
                  },
                ).paddingOnly(right: 6),
              ).paddingOnly(bottom: 37, left: 16),
              SizedBox(
                height: Get.height * 0.15,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Spacer(),
                    Image.asset(
                      AppAsset.languageIcon,
                      height: 20,
                      width: 20,
                    ),
                    Text(
                      '${EnumLocale.txtLanguage.name.tr} : ',
                      style: AppFontStyle.fontStyleW500(
                        fontSize: 14,
                        fontColor: AppColors.profileLanguage,
                      ),
                    ).paddingOnly(left: 8),
                    Expanded(
                      flex: 3,
                      child: Text(
                        controller.randomAvailableListenerModel?.data?.language?.join(', ') ?? '',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                        style: AppFontStyle.fontStyleW600(
                          fontSize: 14,
                          fontColor: AppColors.black,
                        ),
                      ),
                    ),
                    // Spacer(),
                  ],
                ).paddingOnly(top: 8, left: 12, right: 12),
              ),
              Spacer(),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PrimaryAppButton(
                    gradientColor: [
                      AppColors.appColor,
                      AppColors.appColor,
                    ],
                    onTap: () {
                      log("<<<<<<<<<<<<<<<<<<<<<<  ${Database.userCoin.toString()}");

                      final isAudio = controller.selectedIndex == 0;
                      final requiredCoins = isAudio
                          ? controller.randomAvailableListenerModel?.data?.rateRandomAudioCall ?? 0
                          : controller.randomAvailableListenerModel?.data?.rateRandomVideoCall ?? 0;

                      if (controller.randomAvailableListenerModel?.data?.isFake == true) {
                        Utils.showLog("fake call  ${controller.randomAvailableListenerModel?.data?.isFake}");

                        Get.toNamed(
                          AppRoutes.fakeOutgoingCall,
                          arguments: [
                            controller.randomAvailableListenerModel?.data?.name ?? '',
                            controller.randomAvailableListenerModel?.data?.image ?? '',
                            controller.randomAvailableListenerModel?.data?.video ?? '',
                            controller.randomAvailableListenerModel?.data?.audio ?? '',
                            controller.selectedIndex == 0 ? "audio" : "video"
                            // controller.isBackProfile
                          ],
                        );
                      } else {
                        if (int.parse(Database.userCoin.toString()) < requiredCoins) {
                          log('message${int.parse(Database.userCoin.toString()) <= int.parse(controller.randomAvailableListenerModel?.data?.rateRandomVideoCall.toString() ?? '')}');

                          log("userCoin  <<<<<<<<<<<<<<<<<<<<<<  ${Database.userCoin.toString()}");
                          log("rateRandomVideoCall  <<<<<<<<<<<<<<<<<<<<<<  ${controller.randomAvailableListenerModel?.data?.rateRandomVideoCall.toString()}");
                          log("rateRandomAudioCall  <<<<<<<<<<<<<<<<<<<<<<  ${controller.randomAvailableListenerModel?.data?.rateRandomAudioCall.toString()}");

                          Utils.showToast(Get.context!, "You have not enough coins.");
                          Get.toNamed(AppRoutes.myWalletScreen);
                        } else {
                          SocketEmit.randomCallRinging(
                            callerId: Database.fetchLoginUserProfileModel?.user?.id ?? '',
                            receiverId: controller.randomAvailableListenerModel?.data?.id ?? '',
                            callType: controller.selectedIndex == 0 ? "audio" : "video",
                            callerRole: Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'user' : 'listener',
                            receiverRole: Database.fetchLoginUserProfileModel?.user?.isListener == false ? 'listener' : 'user',
                            receiverName: controller.randomAvailableListenerModel?.data?.name ?? '',
                            receiverImage: controller.randomAvailableListenerModel?.data?.image ?? '',
                            callerName: Database.fetchLoginUserProfileModel?.user?.fullName ?? '',
                            callerImage: Database.fetchLoginUserProfileModel?.user?.profilePic ?? '',
                          );
                        }
                      }
                    },
                    height: 50,
                    borderRadius: 30,
                    width: Get.width,
                    color: AppColors.grey.withValues(alpha: 0.6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          controller.selectedIndex == 1 ? AppAsset.videoCallIcon : AppAsset.callIcon,
                          color: AppColors.white,
                          height: 24,
                          width: 24,
                        ),
                        8.width,
                        Text(
                          controller.selectedIndex == 1 ? EnumLocale.txtVideoCall.name.tr : EnumLocale.txtAudioCall.name.tr,
                          style: AppFontStyle.fontStyleW600(fontSize: 16, fontColor: AppColors.white),
                        )
                      ],
                    ),
                  ),
                  20.height,
                  PrimaryAppButton(
                    gradientColor: [
                      Color(0xff19BE00),
                      Color(0xff10B607),
                    ],
                    onTap: () {
                      Get.toNamed(
                        AppRoutes.personalChatScreen,
                        arguments: [
                          controller.randomAvailableListenerModel?.data?.id,
                          controller.randomAvailableListenerModel?.data?.name,
                          controller.randomAvailableListenerModel?.data?.isOnline,
                          controller.randomAvailableListenerModel?.data?.image,
                          controller.randomAvailableListenerModel?.data?.ratePrivateAudioCall,
                          controller.randomAvailableListenerModel?.data?.ratePrivateVideoCall,
                          controller.randomAvailableListenerModel?.data?.isFake,
                          controller.randomAvailableListenerModel?.data?.video,
                          controller.randomAvailableListenerModel?.data?.isAvailableForPrivateVideoCall,
                          controller.randomAvailableListenerModel?.data?.isAvailableForPrivateAudioCall,

                          // controller.listenerProfileModel?.data?.id,
                          // controller.listenerProfileModel?.data?.name,
                          // controller.listenerProfileModel?.data?.statusLabel,
                          // controller.listenerProfileModel?.data?.image,
                          // controller.listenerProfileModel?.data?.ratePrivateAudioCall,
                          // controller.listenerProfileModel?.data?.ratePrivateVideoCall,
                          // controller.listenerProfileModel?.data?.isFake,
                          // controller.listenerProfileModel?.data?.video,
                          // controller.listenerProfileModel?.data?.isAvailableForPrivateVideoCall,
                          // controller.listenerProfileModel?.data?.isAvailableForPrivateAudioCall,
                        ],
                      );
                      // controller.randomAvailableListenerModel?.data?.userId;
                      // controller.chatList[index].name,
                      // controller.chatList[index].isOnline,
                      // controller.chatList[index].image,
                      // controller.chatList[index].ratePrivateAudioCall,
                      // controller.chatList[index].ratePrivateVideoCall,
                    },
                    height: 50,
                    borderRadius: 30,
                    width: Get.width,
                    color: AppColors.grey.withValues(alpha: 0.6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          AppAsset.chat,
                          color: AppColors.white,
                          height: 24,
                          width: 24,
                        ),
                        8.width,
                        Text(
                          EnumLocale.txtsayHello.name.tr,
                          style: AppFontStyle.fontStyleW600(fontSize: 16, fontColor: AppColors.white),
                        )
                      ],
                    ),
                  ),
                ],
              ).paddingOnly(bottom: 32, left: 22, right: 22)
            ],
          );
        }),
      ),
    );
  }
}
