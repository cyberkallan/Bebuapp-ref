import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/custom/bottom_sheet/talk_now_button_bottom_sheet.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/ui/host_flow/user_detail_profile_screen/controller/user_profile_deatil_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class UserProfileTopImageView extends StatelessWidget {
  const UserProfileTopImageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GetBuilder<UserProfileDetailController>(
            id: Constant.listenerProfile,
            builder: (controller) {
              return SizedBox(
                height: Get.height * 0.38,
                width: Get.width,
                child: SendMessageImageFullScreen(
                  image: controller.userProfileModel?.user?.profilePic ?? '',
                  fit: BoxFit.cover,
                ),
              );
            })
      ],
    );
  }
}

class UserProfileInfoView extends StatelessWidget {
  const UserProfileInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileDetailController>(
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
                      color: AppColors.black,
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
                          image: controller.userProfileModel?.user?.profilePic ?? '',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ).paddingOnly(right: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${controller.userProfileModel?.user?.fullName} ,${controller.userProfileModel?.user?.age}",
                          style: AppFontStyle.fontStyleW700(fontSize: 16, fontColor: AppColors.black),
                        ).paddingOnly(bottom: 8),
                        Row(
                          children: [
                            controller.userProfileModel?.user?.isOnline == false
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
                                          "offline",
                                          style: AppFontStyle.fontStyleW500(fontSize: 10, fontColor: AppColors.appTextColor),
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
                                          "online",
                                          style: AppFontStyle.fontStyleW500(fontSize: 10, fontColor: AppColors.white),
                                        ).paddingOnly(right: 4),
                                      ],
                                    ),
                                  ),
                            GestureDetector(
                              onTap: () {
                                Utils.copyText(controller.userProfileModel?.user?.uniqueId ?? '');
                                Utils.showToast(context, "ID copied to clipboard");
                              },
                              child: Container(
                                padding: EdgeInsets.only(bottom: 4, left: 6, right: 6, top: 4),
                                decoration: BoxDecoration(color: AppColors.idContainerColor2, borderRadius: BorderRadius.circular(60)),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      // width: Get.width * 0.15,
                                      child: Text("ID: ${controller.userProfileModel?.user?.uniqueId}",
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
                  ],
                ).paddingOnly(left: 12, right: 12, top: 14, bottom: 8),
              ),
              Container(
                width: Get.width,
                padding: EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                color: AppColors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      EnumLocale.txtUserDetails.name.tr,
                      style: AppFontStyle.fontStyleW600(
                          fontSize: 15, fontColor: AppColors.black, decorationColor: AppColors.black, textDecoration: TextDecoration.underline),
                    ).paddingOnly(bottom: 16),
                    Row(
                      children: [
                        Text(
                          EnumLocale.txtUserName.name.tr,
                          style: AppFontStyle.fontStyleW500(
                            fontSize: 14,
                            fontColor: AppColors.profileLanguage,
                          ),
                        ),
                        Text(
                          controller.userProfileModel?.user?.fullName ?? '',
                          style: AppFontStyle.fontStyleW600(
                            fontSize: 14,
                            fontColor: AppColors.black,
                          ),
                        ),
                      ],
                    ).paddingOnly(bottom: 18),
                    Row(
                      children: [
                        Text(
                          EnumLocale.txtUserNickName.name.tr,
                          style: AppFontStyle.fontStyleW500(
                            fontSize: 14,
                            fontColor: AppColors.profileLanguage,
                          ),
                        ),
                        Text(
                          controller.userProfileModel?.user?.nickName ?? '',
                          style: AppFontStyle.fontStyleW600(
                            fontSize: 14,
                            fontColor: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).paddingOnly(top: 10, bottom: 12),
              // Container(
              //   width: Get.width,
              //   padding: EdgeInsets.symmetric(
              //     vertical: 16,
              //     horizontal: 16,
              //   ),
              //   color: AppColors.white,
              //   child: Row(
              //     children: [
              //       Image.asset(AppAsset.languageIcon, height: 20, width: 20).paddingOnly(right: 8),
              //       Text(
              //         "${EnumLocale.txtLanguage.name.tr} : ",
              //         style: AppFontStyle.fontStyleW500(
              //           fontSize: 14,
              //           fontColor: AppColors.profileLanguage,
              //         ),
              //       ),
              //       Text(
              //         '',
              //         style: AppFontStyle.fontStyleW600(
              //           fontSize: 14,
              //           fontColor: AppColors.black,
              //         ),
              //       ),
              //     ],
              //   ),
              // ).paddingOnly(bottom: 12),
              Container(
                width: Get.width,
                padding: EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                color: AppColors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      EnumLocale.txtPersonalDetails.name.tr,
                      style: AppFontStyle.fontStyleW600(
                          fontSize: 15, fontColor: AppColors.black, decorationColor: AppColors.black, textDecoration: TextDecoration.underline),
                    ).paddingOnly(bottom: 16),
                    Row(
                      children: [
                        Image.asset(AppAsset.birthIcon, height: 20, width: 20).paddingOnly(right: 8),
                        Text(
                          "${EnumLocale.txtDateOfBirth.name.tr} : ",
                          style: AppFontStyle.fontStyleW500(
                            fontSize: 14,
                            fontColor: AppColors.profileLanguage,
                          ),
                        ),
                        Text(
                          controller.userProfileModel?.user?.birthDate ?? '',
                          style: AppFontStyle.fontStyleW600(
                            fontSize: 14,
                            fontColor: AppColors.black,
                          ),
                        ),
                      ],
                    ).paddingOnly(bottom: 22),
                    Row(
                      children: [
                        Image.asset(AppAsset.genderIcon, height: 20, width: 20).paddingOnly(right: 8),
                        Text(
                          '${EnumLocale.txtGender.name.tr} : ',
                          style: AppFontStyle.fontStyleW500(
                            fontSize: 14,
                            fontColor: AppColors.profileLanguage,
                          ),
                        ),
                        Text(
                          controller.userProfileModel?.user?.gender ?? '',
                          style: AppFontStyle.fontStyleW600(
                            fontSize: 14,
                            fontColor: AppColors.black,
                          ),
                        ),
                      ],
                    ).paddingOnly(bottom: 22),
                    Row(
                      children: [
                        Image.asset(AppAsset.countryIcon, height: 20, width: 20).paddingOnly(right: 8),
                        Text(
                          '${EnumLocale.txtCountry.name.tr} : ',
                          style: AppFontStyle.fontStyleW500(
                            fontSize: 14,
                            fontColor: AppColors.profileLanguage,
                          ),
                        ),
                        Text(
                          controller.userProfileModel?.user?.country ?? '',
                          style: AppFontStyle.fontStyleW600(
                            fontSize: 14,
                            fontColor: AppColors.black,
                          ),
                        ),
                      ],
                    ).paddingOnly(bottom: 22),
                    Row(
                      children: [
                        Image.asset(AppAsset.emailIcon, height: 20, width: 20).paddingOnly(right: 8),
                        Text(
                          "${EnumLocale.txtMailId.name.tr} : ",
                          style: AppFontStyle.fontStyleW500(
                            fontSize: 14,
                            fontColor: AppColors.profileLanguage,
                          ),
                        ),
                        Text(
                          controller.userProfileModel?.user?.email ?? '',
                          style: AppFontStyle.fontStyleW600(
                            fontSize: 14,
                            fontColor: AppColors.black,
                          ),
                        ),
                      ],
                    ).paddingOnly(bottom: 22),
                  ],
                ),
              ).paddingOnly(bottom: 12),
            ],
          );
        });
  }
}

class UserProfileBottomButtonView extends StatelessWidget {
  const UserProfileBottomButtonView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserProfileDetailController>(builder: (controller) {
      return Container(
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
        child: PrimaryAppButton(
          onTap: () {
            Get.bottomSheet(
              TalkNowButtonBottomSheet(
                availableForPrivateAudioCall: true,
                availableForPrivateVideoCall: true,
                isFake: false,
                fakeVideo: [],
                fakeAudio: "",
                videoCallRatePrivate: '',
                audioCallRatePrivate: '',
                callerId: Database.fetchListenerProfileModel?.data?.id ?? '',
                receiverId: controller.userProfileModel?.user?.id ?? '',
                receiverName: controller.userProfileModel?.user?.fullName ?? '',
                receiverImage: controller.userProfileModel?.user?.profilePic ?? '',
                callerName: Database.fetchListenerProfileModel?.data?.name ?? '',
                callerImage: Database.fetchListenerProfileModel?.data?.image ?? '',
                callerRole: 'listener',
                receiverRole: 'user',
              ),
              isScrollControlled: true,
              backgroundColor: AppColors.transparent,
            );
          },
          height: 47,
          color: AppColors.appColor,
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
      );
    });
  }
}
