import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/custom/bottom_sheet/talk_now_button_bottom_sheet.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/profile_detail_screen/controller/profile_detail_screen_controller.dart';
import 'package:talk_in/ui/user_flow/profile_detail_screen/shimmer/profile_detail_shimmer.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class TopImageView extends StatelessWidget {
  const TopImageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GetBuilder<ProfileDetailScreenController>(
          id: Constant.listenerProfile,
          builder: (controller) {
            return SizedBox(
              height: Get.height * 0.38,
              width: Get.width,
              child: SendMessageImageFullScreen(
                image: controller.listenerProfileModel?.data?.image ?? '',
                fit: BoxFit.cover,
              ),
            );
          },
        ),
      ],
    );
  }
}

class UserProfileInfoView extends StatelessWidget {
  const UserProfileInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileDetailScreenController>(
      id: Constant.listenerProfile,
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xffF3E6FF),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 0),
                    spreadRadius: 0,
                    blurRadius: 4,
                    color: AppColors.black.withValues(alpha: 0.20),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DottedBorder(
                    borderType: BorderType.Circle,
                    color: Colors.black,
                    dashPattern: [3, 2],
                    strokeWidth: 1,
                    child: Container(
                      clipBehavior: Clip.hardEdge,
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        shape: BoxShape.circle,
                      ),
                      child: CustomProfileImage(
                        image: controller.listenerProfileModel?.data?.image ?? '',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ).paddingOnly(right: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${controller.listenerProfileModel?.data?.name ?? ''} ,${controller.listenerProfileModel?.data?.age ?? ''}",
                        style: AppFontStyle.fontStyleW700(fontSize: 16, fontColor: AppColors.black),
                      ).paddingOnly(bottom: 8),
                      Row(
                        children: [
                          controller.listenerProfileModel?.data?.statusLabel == "Offline"
                              ? Container(
                                  padding: EdgeInsets.only(right: 6, bottom: 4, top: 4, left: 6),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: AppColors.lightGrey1),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Image.asset(
                                      //   AppAsset.availableIcon,
                                      //   height: 10,
                                      //   width: 10,
                                      // ).paddingOnly(right: 5),
                                      Container(
                                        // height: 12,
                                        // width: 12,
                                        decoration: BoxDecoration(
                                          color: AppColors.onBoardingTxt.withValues(alpha: 0.3),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Container(
                                          height: 7,
                                          width: 7,
                                          decoration: BoxDecoration(
                                            color: AppColors.onBoardingTxt,
                                            shape: BoxShape.circle,
                                          ),
                                        ).paddingAll(1.8),
                                      ).paddingOnly(right: 4),
                                      Text(
                                        controller.listenerProfileModel?.data?.statusLabel ?? '',
                                        style: AppFontStyle.fontStyleW500(fontSize: 10, fontColor: AppColors.appTextColor),
                                      ).paddingOnly(right: 4),
                                    ],
                                  ),
                                )
                              : controller.listenerProfileModel?.data?.statusLabel == "On Call"
                                  ? Container(
                                      padding: EdgeInsets.only(right: 6, bottom: 4, top: 4, left: 6),
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: AppColors.red),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          // Image.asset(
                                          //   AppAsset.availableIcon,
                                          //   height: 10,
                                          //   width: 10,
                                          // ).paddingOnly(right: 5),
                                          Container(
                                            // height: 12,
                                            // width: 12,
                                            decoration: BoxDecoration(
                                              color: AppColors.white.withValues(alpha: 0.5),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Container(
                                              height: 7,
                                              width: 7,
                                              decoration: BoxDecoration(
                                                color: AppColors.white,
                                                shape: BoxShape.circle,
                                              ),
                                            ).paddingAll(1.8),
                                          ).paddingOnly(right: 4),
                                          Text(
                                            controller.listenerProfileModel?.data?.statusLabel ?? '',
                                            style: AppFontStyle.fontStyleW500(fontSize: 10, fontColor: AppColors.white),
                                          ).paddingOnly(right: 4),
                                        ],
                                      ),
                                    )
                                  : Container(
                                      padding: EdgeInsets.only(right: 6, bottom: 4, top: 4, left: 6),
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: AppColors.green),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          // Image.asset(
                                          //   AppAsset.availableIcon,
                                          //   height: 10,
                                          //   width: 10,
                                          // ).paddingOnly(right: 5),
                                          Container(
                                            // height: 12,
                                            // width: 12,
                                            decoration: BoxDecoration(
                                              color: AppColors.white.withValues(alpha: 0.5),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Container(
                                              height: 7,
                                              width: 7,
                                              decoration: BoxDecoration(
                                                color: AppColors.white,
                                                shape: BoxShape.circle,
                                              ),
                                            ).paddingAll(1.8),
                                          ).paddingOnly(right: 4),
                                          Text(
                                            controller.listenerProfileModel?.data?.statusLabel ?? '',
                                            style: AppFontStyle.fontStyleW500(fontSize: 10, fontColor: AppColors.white),
                                          ).paddingOnly(right: 4),
                                        ],
                                      ),
                                    ),
                          GestureDetector(
                            onTap: () {
                              if (!controller.isToastVisible) {
                                Utils.copyText(Database.fetchLoginUserProfileModel?.user?.uniqueId ?? "");
                                Utils.showToast(context, "copied");

                                controller.isToastVisible = true;

                                Future.delayed(Duration(seconds: 3), () {
                                  controller.isToastVisible = false;
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.only(bottom: 4, left: 6, right: 6, top: 4),
                              decoration: BoxDecoration(color: AppColors.idContainerColor2, borderRadius: BorderRadius.circular(60)),
                              child: Row(
                                children: [
                                  SizedBox(
                                    // width: Get.width * 0.15,
                                    child: Text("ID: ${controller.listenerProfileModel?.data?.uniqueId ?? ''}",
                                            overflow: TextOverflow.ellipsis,
                                            style: AppFontStyle.fontStyleW600(fontSize: 10, fontColor: AppColors.idTxtColor2))
                                        .paddingOnly(right: 3),
                                  ),
                                  Image.asset(
                                    AppAsset.copyIcon,
                                    color: AppColors.idTxtColor2,
                                    height: 12,
                                    width: 12,
                                  )
                                ],
                              ),
                            ).paddingOnly(left: 8),
                          ),
                        ],
                      )
                    ],
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.lightYellow,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          AppAsset.starCoin,
                          height: 18,
                          width: 18,
                        ),
                        Text(
                          "${controller.listenerProfileModel?.data?.totalCoins.toString() ?? ''} Coin",
                          style: AppFontStyle.fontStyleW700(fontSize: 12, fontColor: AppColors.orange),
                        ).paddingOnly(left: 6, right: 6)
                      ],
                    ),
                  ),
                ],
              ).paddingOnly(left: 12, right: 12, top: 14, bottom: 8),
            ),
            Text(
              controller.listenerProfileModel?.data?.selfIntro ?? '',
              style: AppFontStyle.fontStyleW500(
                fontSize: 12,
                height: 1.9,
                fontColor: AppColors.profileText,
              ),
            ).paddingSymmetric(horizontal: 12, vertical: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  child: Text(
                    controller.listenerProfileModel?.data?.language?.join(', ') ?? '',
                    style: AppFontStyle.fontStyleW600(
                      fontSize: 14,
                      fontColor: AppColors.black,
                    ),
                  ),
                )
              ],
            ).paddingOnly(top: 8, left: 12, right: 12),
            SizedBox(
              height: Get.height * 0.035,
              child: ListView.builder(
                itemCount: controller.listenerProfileModel?.data?.talkTopics?.length ?? 0,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final topic = controller.listenerProfileModel?.data?.talkTopics?[index] ?? '';

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.profileOptionColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        topic,
                        style: AppFontStyle.fontStyleW500(
                          fontSize: 12,
                          fontColor: AppColors.profileLanguage,
                        ),
                      ),
                    ),
                  ).paddingOnly(right: 5);
                },
              ),
            ).paddingOnly(left: 12, top: 20, bottom: 20)
          ],
        );
      },
    );
  }
}

class StatusView extends StatelessWidget {
  const StatusView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileDetailScreenController>(
      id: Constant.listenerProfile,
      builder: (controller) {
        return Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            3,
            (index) {
              final item = controller.statsList[index];

              return Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 7, vertical: 22),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    color: AppColors.profileOptionColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        item['image'].toString(),
                        height: 34,
                        width: 34,
                      ).paddingOnly(bottom: 10),
                      Text(
                        item['title'].toString(),
                        style: AppFontStyle.fontStyleW500(fontSize: 11, fontColor: AppColors.profileLanguage),
                      ).paddingOnly(bottom: 5),
                      Text(
                        item['count'].toString(),
                        style: AppFontStyle.fontStyleW600(fontSize: 16, fontColor: AppColors.black),
                      ),
                    ],
                  ),
                ).paddingOnly(right: 8, left: 8),
              );
            },
          ),
        ).paddingOnly(left: 8, right: 8, bottom: 10);
      },
    );
  }
}

class ReviewShow extends StatelessWidget {
  const ReviewShow({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileDetailScreenController>(
        id: Constant.idGetListenerReview,
        builder: (controller) {
          return controller.reviews?.isEmpty == true
              ? SizedBox()
              : Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(EnumLocale.txtReviews.name.tr, style: AppFontStyle.fontStyleW600(fontSize: 18, fontColor: AppColors.black))
                            .paddingOnly(top: 26, bottom: 18),
                        InkWell(
                          onTap: () {
                            Get.toNamed(AppRoutes.allReviewScreen, arguments: controller.listenerId);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 4).copyWith(left: 5),
                            color: AppColors.transparent,
                            child: Text(
                              EnumLocale.txtViewAll.name.tr,
                              style: AppFontStyle.fontStyleW500(
                                  decorationColor: AppColors.appTextColor,
                                  textDecoration: TextDecoration.underline,
                                  fontSize: 13,
                                  fontColor: AppColors.appTextColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ListView.builder(
                      itemCount: controller.reviews?.take(4).length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.reviewBorder),
                            borderRadius: BorderRadius.circular(18),
                            color: AppColors.reviewBackground,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DottedBorder(
                                    borderType: BorderType.Circle,
                                    color: AppColors.black,
                                    dashPattern: [3, 2],
                                    strokeWidth: 1,
                                    child: GestureDetector(
                                      onTap: () {
                                        // Get.toNamed(AppRoutes.hostProfileScreen);
                                      },
                                      child: Container(
                                        clipBehavior: Clip.hardEdge,
                                        height: 48,
                                        width: 48,
                                        decoration: BoxDecoration(
                                          color: AppColors.lightGrey,
                                          shape: BoxShape.circle,
                                        ),
                                        child: CustomListenerProfileImage(
                                          image: controller.reviews?[index].profilePic ?? '',
                                        ),
                                      ),
                                    ),
                                  ).paddingOnly(right: 13),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        controller.reviews?[index].fullName ?? '',
                                        style: AppFontStyle.fontStyleW600(fontSize: 15, fontColor: AppColors.black),
                                      ),
                                      StarRating(
                                        rating: controller.reviews?[index].rating?.toDouble() ?? 0.0,
                                        size: 22,
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: Color(0xffE7EBF7), borderRadius: BorderRadius.circular(34)),
                                    child: Text(
                                      controller.reviews?[index].time ?? '',
                                      style: AppFontStyle.fontStyleW600(fontSize: 10, fontColor: AppColors.profileLanguage),
                                    ),
                                  )
                                ],
                              ).paddingOnly(top: 5, bottom: 6),
                              Text(
                                controller.reviews?[index].review ?? '',
                                textAlign: TextAlign.start,
                                style: AppFontStyle.fontStyleW500(
                                  fontSize: 12,
                                  fontColor: AppColors.profileLanguage,
                                  height: 1.8,
                                ),
                              )
                            ],
                          ),
                        ).paddingOnly(bottom: 14);
                      },
                    ).paddingOnly(bottom: 16),
                  ],
                ).paddingOnly(left: 16, right: 16);
        });
  }
}

class ProfileBottomButtonView extends StatelessWidget {
  const ProfileBottomButtonView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileDetailScreenController>(
      id: Constant.listenerProfile,
      builder: (controller) {
        return controller.isLoading
            ? ProfileDetailButtonShimmer()
            : Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.10),
                      offset: Offset(0, 0),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: PrimaryAppButton(
                        onTap: () {
                          Get.toNamed(
                            AppRoutes.personalChatScreen,
                            arguments: [
                              controller.listenerProfileModel?.data?.id,
                              controller.listenerProfileModel?.data?.name,
                              controller.listenerProfileModel?.data?.statusLabel,
                              controller.listenerProfileModel?.data?.image,
                              controller.listenerProfileModel?.data?.ratePrivateAudioCall,
                              controller.listenerProfileModel?.data?.ratePrivateVideoCall,
                              controller.listenerProfileModel?.data?.isFake,
                              controller.listenerProfileModel?.data?.video,
                              controller.listenerProfileModel?.data?.isAvailableForPrivateVideoCall,
                              controller.listenerProfileModel?.data?.isAvailableForPrivateAudioCall,
                            ],
                          );
                        },
                        height: Get.height * 0.06,
                        // borderRadius: 30,
                        color: AppColors.green,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              EnumLocale.txtChatNow.name.tr,
                              style: AppFontStyle.fontStyleW600(fontSize: 16, fontColor: AppColors.white),
                            )
                          ],
                        ),
                      ).paddingOnly(bottom: 10),
                    ),
                    (controller.listenerProfileModel?.data?.isAvailableForPrivateVideoCall == true ||
                            controller.listenerProfileModel?.data?.isAvailableForPrivateAudioCall == true ||
                            controller.listenerProfileModel?.data?.isFake == true)
                        ? 12.width
                        : Offstage(),
                    (controller.listenerProfileModel?.data?.isAvailableForPrivateVideoCall == true ||
                            controller.listenerProfileModel?.data?.isAvailableForPrivateAudioCall == true ||
                            controller.listenerProfileModel?.data?.isFake == true)
                        ? Expanded(
                            child: PrimaryAppButton(
                              height: Get.height * 0.06,
                              onTap: () {
                                // if (controller.listenerProfileModel?.data?.isFake == true) {
                                //   Utils.showLog("this is fake Listener>>>>>>>>>");
                                //   Get.toNamed(
                                //     AppRoutes.fakeOutgoingCall,
                                //     arguments: [
                                //       controller.listenerProfileModel?.data?.name,
                                //       controller.listenerProfileModel?.data?.image,
                                //       controller.listenerProfileModel?.data?.video,
                                //       controller.isBackProfile
                                //     ],
                                //   );
                                // } else {
                                Get.bottomSheet(
                                  TalkNowButtonBottomSheet(
                                    availableForPrivateAudioCall: controller.listenerProfileModel?.data?.isAvailableForPrivateAudioCall ?? false,
                                    availableForPrivateVideoCall: controller.listenerProfileModel?.data?.isAvailableForPrivateVideoCall ?? false,
                                    isFake: controller.listenerProfileModel?.data?.isFake ?? false,
                                    fakeVideo: controller.listenerProfileModel?.data?.video ?? [],
                                    fakeAudio: controller.listenerProfileModel?.data?.audio ?? "",
                                    videoCallRatePrivate: controller.listenerProfileModel?.data?.ratePrivateVideoCall.toString() ?? '',
                                    audioCallRatePrivate: controller.listenerProfileModel?.data?.ratePrivateAudioCall.toString() ?? '',
                                    callerId: Database.fetchLoginUserProfileModel?.user?.isListener == false
                                        ? Database.fetchLoginUserProfileModel?.user?.id ?? ''
                                        : Database.fetchLoginUserProfileModel?.user?.listenerId ?? '',
                                    receiverId: controller.listenerProfileModel?.data?.id ?? '',
                                    receiverName: controller.listenerProfileModel?.data?.name ?? '',
                                    receiverImage: controller.listenerProfileModel?.data?.image ?? '',
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
                              },
                              // borderRadius: 30,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    AppAsset.callIcon,
                                    height: 22,
                                    width: 22,
                                    color: AppColors.white,
                                  ).paddingOnly(right: 8),
                                  Text(
                                    EnumLocale.txtTalkNow.name.tr,
                                    style: AppFontStyle.fontStyleW600(fontSize: 16, fontColor: AppColors.white),
                                  )
                                ],
                              ),
                            ).paddingOnly(bottom: 10),
                          )
                        : SizedBox(),
                  ],
                ));
      },
    );
  }
}

class StarRating extends StatelessWidget {
  final double rating; // e.g. 3.5
  final double size;
  final int maxStars;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 42,
    this.maxStars = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        return Icon(
          Icons.star_rounded,
          size: size,
          color: index < rating ? AppColors.rateStarColor : Colors.grey.shade300,
        );
      }),
    );
  }
}
