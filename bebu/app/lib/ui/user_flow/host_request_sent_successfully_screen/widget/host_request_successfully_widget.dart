import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/ui/user_flow/become_host_screen/controller/become_host_screen_controller.dart';
import 'package:talk_in/ui/user_flow/host_request_sent_successfully_screen/controller/host_request_sent_successfully_controller.dart';
import 'package:talk_in/ui/user_flow/host_request_sent_successfully_screen/shimmer/host_request_successfully_shimmer.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class InfoTile extends StatelessWidget {
  final String title;
  final String data;
  const InfoTile({
    super.key,
    required this.title,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppFontStyle.fontStyleW500(fontSize: 14, fontColor: AppColors.onBoardingTxt),
        ),
        SizedBox(
          width: Get.width * 0.5,
          child: Text(
            textAlign: TextAlign.end,
            data,
            style: AppFontStyle.fontStyleW600(fontSize: 14, fontColor: AppColors.black),
          ),
        ),
      ],
    ).paddingOnly(bottom: 28);
  }
}

class BackHomeButton extends StatelessWidget {
  final void Function()? onTap;
  final void Function()? tryAgainOnTap;

  const BackHomeButton({super.key, this.onTap, this.tryAgainOnTap});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HostRequestSentSuccessfullyController>(builder: (controller) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.10),
              blurRadius: 18,
              offset: Offset(0, 0),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                controller.listenersRequestCheckModel?.data?.status == 3
                    ? Expanded(
                        child: PrimaryAppButton(
                          onTap: tryAgainOnTap,
                          color: AppColors.appColor,
                          height: Get.height * 0.056,
                          width: Get.width,
                          text: EnumLocale.txtTryAgain.name.tr,
                          textStyle: AppFontStyle.fontStyleW500(fontSize: 16, fontColor: AppColors.white),
                        ),
                      )
                    : Container(),
                if (controller.listenersRequestCheckModel?.data?.status == 3) 8.width,
                Expanded(
                  child: PrimaryAppButton(
                    onTap: onTap,
                    color: AppColors.appColor,
                    height: Get.height * 0.056,
                    width: Get.width,
                    text: EnumLocale.txtBackToHome.name.tr,
                    textStyle: AppFontStyle.fontStyleW500(fontSize: 16, fontColor: AppColors.white),
                  ),
                ),
              ],
            ).paddingSymmetric(horizontal: 16),
          ],
        ).paddingOnly(top: 10, bottom: 10),
      );
    });
  }
}

class TopView extends StatelessWidget {
  const TopView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            AppAsset.callCutBg,
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              EnumLocale.txtListenerReqSentSuccessfully.name.tr,
              style: AppFontStyle.fontStyleW700(
                fontSize: 23,
                fontColor: Colors.white,
              ),
            ).paddingOnly(left: 16, top: 75),
          ),
          Image.asset(
            AppAsset.requestSentImage,
            height: 120,
          ).paddingOnly(right: 16, top: 60, bottom: 6),
        ],
      ),
    );
  }
}

class InfoView extends StatelessWidget {
  const InfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BecomeHostScreenController>(
      builder: (controller) {
        final data = controller.listenersRequestCheckModel?.data;
        // String? formattedDateTime = controller.getFormattedDate(data?.date);
        final dateTimeParts = controller.getFormattedDateParts(data?.date);

        return controller.isLoading
            ? HostRequestSuccessfullyShimmer()
            : Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), color: AppColors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.grey.withValues(alpha: 0.5),
                          ),
                          child: Container(
                            // clipBehavior: Clip.hardEdge,
                            height: 76,
                            width: 76,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.white, width: 1),
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: CustomProfileImage(
                                image: Database.loginUserProfilePic,
                              ),
                            ),
                          ).paddingAll(1),
                        ).paddingOnly(right: 12),
                        SizedBox(
                          width: Get.width * 0.3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Database.loginUserName,
                                overflow: TextOverflow.ellipsis,
                                style: AppFontStyle.fontStyleW700(fontSize: 19, fontColor: AppColors.black),
                              ),
                              Database.loginType == 2
                                  ? Text(
                                      Database.loginUserNickName,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppFontStyle.fontStyleW500(fontSize: 15, fontColor: AppColors.profileMail),
                                    )
                                  : Text(
                                      Database.loginUserEmail,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppFontStyle.fontStyleW500(fontSize: 15, fontColor: AppColors.profileMail),
                                    )
                            ],
                          ),
                        ),
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: AppColors.lightGrey),
                          child: Text(
                            controller.listenersRequestCheckModel?.data?.status == 1
                                ? "Pending"
                                : controller.listenersRequestCheckModel?.data?.status == 2
                                    ? "Accepted"
                                    : "Declined",
                            style: AppFontStyle.fontStyleW600(fontSize: 14, fontColor: AppColors.profileText),
                          ),
                        )
                      ],
                    ),
                    DottedLine(
                      direction: Axis.horizontal,
                      alignment: WrapAlignment.center,
                      lineLength: double.infinity,
                      lineThickness: 1,
                      dashLength: 4.0,
                      dashColor: AppColors.grey.withValues(alpha: 0.3),
                      dashRadius: 0.0,
                      dashGapLength: 4.0,
                      dashGapColor: Colors.transparent,
                      dashGapRadius: 0.0,
                    ).paddingOnly(bottom: 15, top: 15),
                    InfoTile(
                      title: EnumLocale.txtRequestID.name.tr,
                      data: data?.uniqueId ?? '',
                    ),
                    InfoTile(
                      title: EnumLocale.txtListenersName.name.tr,
                      data: data?.name ?? '',
                    ),
                    InfoTile(
                      title: EnumLocale.txtMailId.name.tr,
                      data: data?.email ?? '',
                    ),
                    InfoTile(
                      title: EnumLocale.txtAddress.name.tr,
                      data: data?.location ?? '',
                    ),
                    InfoTile(
                      title: EnumLocale.txtRequestDate.name.tr,
                      data: dateTimeParts["date"] ?? '',
                    ),
                    InfoTile(
                      title: EnumLocale.txtRequestTime.name.tr,
                      data: dateTimeParts["time"] ?? '',
                    ),
                    Text(
                      "${EnumLocale.txtIntroduction.name.tr} :",
                      style: AppFontStyle.fontStyleW500(fontSize: 14, fontColor: AppColors.onBoardingTxt),
                    ).paddingOnly(bottom: 15),
                    Container(
                      width: Get.width,
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.grey.withValues(alpha: 0.4),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        data?.selfIntro ?? '',
                        style: AppFontStyle.fontStyleW500(fontSize: 11, fontColor: AppColors.black),
                      ),
                    )
                  ],
                ),
              ).paddingAll(16);
      },
    );
  }
}
