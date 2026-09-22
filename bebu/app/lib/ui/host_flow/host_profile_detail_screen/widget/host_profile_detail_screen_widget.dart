import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/ui/host_flow/host_profile_detail_screen/controller/host_profile_detail_screen_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class HostTopImageView extends StatelessWidget {
  const HostTopImageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GetBuilder<HostProfileDetailScreenController>(
          id: Constant.listenerProfile,
          builder: (controller) {
            return SizedBox(
              height: Get.height * 0.38,
              width: Get.width,
              child: CustomProfileImage(
                image: controller.fetchListenerProfileModel?.data?.image ?? '',
                fit: BoxFit.cover,
              ),
            );
          },
        ),
      ],
    );
  }
}

class HostUserProfileInfoView extends StatelessWidget {
  const HostUserProfileInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HostProfileDetailScreenController>(
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
                        image: controller.fetchListenerProfileModel?.data?.image ?? '',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ).paddingOnly(right: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            controller.fetchListenerProfileModel?.data?.name ?? '',
                            style: AppFontStyle.fontStyleW700(fontSize: 16, fontColor: AppColors.black),
                          ).paddingOnly(bottom: 8),
                          // controller.fetchListenerProfileModel?.data?.id == null
                          //     ? SizedBox()
                          //     : Text(
                          //         ",${controller.fetchListenerProfileModel?.data?.id ?? ''}",
                          //         style: AppFontStyle.fontStyleW700(fontSize: 16, fontColor: AppColors.black),
                          //       ).paddingOnly(bottom: 8),
                        ],
                      ),
                      controller.fetchListenerProfileModel?.data?.id == "Offline"
                          ? Container(
                              padding: EdgeInsets.only(right: 6, bottom: 5, top: 5, left: 6),
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
                                    EnumLocale.txtOnCall.name.tr,
                                    style: AppFontStyle.fontStyleW500(fontSize: 10, fontColor: AppColors.white),
                                  ).paddingOnly(right: 4),
                                ],
                              ),
                            )
                          : Container(
                              padding: EdgeInsets.only(right: 6, bottom: 5, top: 5, left: 6),
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
                                    EnumLocale.txtOnline.name.tr,
                                    style: AppFontStyle.fontStyleW500(fontSize: 10, fontColor: AppColors.white),
                                  ).paddingOnly(right: 4),
                                ],
                              ),
                            )
                    ],
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.purple100.withValues(alpha: 0.6),
                      border: Border.all(color: AppColors.purpleBorder),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '10₹ per min',
                      style: AppFontStyle.fontStyleW700(fontSize: 12, fontColor: AppColors.purple400),
                    ),
                  ),
                ],
              ).paddingSymmetric(vertical: 14, horizontal: 12),
            ),
            Text(
              controller.fetchListenerProfileModel?.data?.selfIntro ?? '',
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
                    controller.fetchListenerProfileModel?.data?.language?.join(', ') ?? '',
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
                itemCount: controller.fetchListenerProfileModel?.data?.talkTopics?.length,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.profileOptionColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        controller.fetchListenerProfileModel?.data?.talkTopics?.join(', ') ?? '',
                        style: AppFontStyle.fontStyleW500(fontSize: 12, fontColor: AppColors.profileLanguage),
                      ),
                    ),
                  ).paddingOnly(right: 5);
                },
              ),
            ).paddingOnly(left: 12, top: 20, bottom: 20),
          ],
        );
      },
    );
  }
}

class HostStatusView extends StatelessWidget {
  const HostStatusView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HostProfileDetailScreenController>(
      id: Constant.listenerProfile,
      builder: (controller) {
        return Row(
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

class HostProfileBottomButtonView extends StatelessWidget {
  const HostProfileBottomButtonView({super.key});

  @override
  Widget build(BuildContext context) {
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
        height: 47,
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
  }
}
