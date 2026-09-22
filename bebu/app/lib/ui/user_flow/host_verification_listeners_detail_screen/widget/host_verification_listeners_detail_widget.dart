import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_bar/custom_app_bar.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/custom/bottom_sheet/all_language_bottom_sheet.dart';
import 'package:talk_in/custom/text_field/custom_text_field.dart';
import 'package:talk_in/custom/title/custom_title.dart';
import 'package:talk_in/ui/user_flow/host_verification_screen/controller/host_verification_controller.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class HostVerificationListenersDetailAppBar extends StatelessWidget {
  const HostVerificationListenersDetailAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(120),
      child: CustomAppBar(
        appBarColor: AppColors.lightPurple,
        title: EnumLocale.txtListenerVerification.name.tr,
        showLeadingIcon: true,
      ),
    );
  }
}

class HostVerificationListenersDetailView extends StatelessWidget {
  // final List<String> languages = ['English', 'Hindi', 'Gujarati', 'Marathi', 'Punjabi', 'Spanish', 'French', 'Urdu'];
  const HostVerificationListenersDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HostVerificationController>(
      builder: (controller) {
        return Column(
          children: [
            Container(
              width: Get.width,
              color: AppColors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    EnumLocale.txtListenerDetails.name.tr,
                    style: AppFontStyle.fontStyleW700(
                      fontSize: 17,
                      fontColor: Colors.black,
                    ),
                  ).paddingOnly(top: 16, bottom: 16),
                  CustomTitle(
                    title: EnumLocale.txtEnterName.name.tr,
                    textStyle: AppFontStyle.fontStyleW500(
                      fontSize: 12,
                      fontColor: AppColors.listenersDetail,
                    ),
                    method: CustomTextField(
                      filled: true,
                      borderColor: AppColors.appTextColor.withValues(alpha: 0.18),
                      controller: controller.nameController,
                      fillColor: AppColors.white,
                      cursorColor: AppColors.black,
                      fontColor: AppColors.black,
                      fontSize: 15,
                      textInputAction: TextInputAction.next,
                      maxLines: 1,
                    ),
                  ).paddingOnly(bottom: 18),
                  CustomTitle(
                    title: EnumLocale.txtEnterNickName.name.tr,
                    textStyle: AppFontStyle.fontStyleW500(
                      fontSize: 12,
                      fontColor: AppColors.listenersDetail,
                    ),
                    method: CustomTextField(
                      filled: true,
                      borderColor: AppColors.appTextColor.withValues(alpha: 0.18),
                      controller: controller.nickNameController,
                      fillColor: AppColors.white,
                      cursorColor: AppColors.black,
                      fontColor: AppColors.black,
                      fontSize: 15,
                      textInputAction: TextInputAction.next,
                      maxLines: 1,
                    ),
                  ).paddingOnly(bottom: 18),
                  CustomTitle(
                    title: EnumLocale.txtGender.name.tr,
                    textStyle: AppFontStyle.fontStyleW500(
                      fontSize: 12,
                      fontColor: AppColors.listenersDetail,
                    ),
                    method: CustomTextField(
                      filled: true,
                      borderColor: AppColors.appTextColor.withValues(alpha: 0.18),
                      controller: controller.genderCnt,
                      fillColor: AppColors.white,
                      cursorColor: AppColors.black,
                      fontColor: AppColors.black,
                      fontSize: 15,
                      textInputAction: TextInputAction.next,
                      maxLines: 1,
                    ),
                  ).paddingOnly(bottom: 18),
                  CustomTitle(
                    title: EnumLocale.txtEnterIntroduction.name.tr,
                    textStyle: AppFontStyle.fontStyleW500(
                      fontSize: 12,
                      fontColor: AppColors.listenersDetail,
                    ),
                    method: CustomTextField(
                      filled: true,
                      borderColor: AppColors.appTextColor.withValues(alpha: 0.18),
                      controller: controller.introCnt,
                      fillColor: AppColors.white,
                      cursorColor: AppColors.black,
                      fontColor: AppColors.black,
                      fontSize: 12,
                      textInputAction: TextInputAction.next,
                      maxLines: 5,
                    ),
                  ).paddingOnly(bottom: 21),
                  CustomTitle(
                    title: EnumLocale.txtEnterYourExperience.name.tr,
                    textStyle: AppFontStyle.fontStyleW500(
                      fontSize: 12,
                      fontColor: AppColors.listenersDetail,
                    ),
                    method: CustomTextField(
                      filled: true,
                      borderColor: AppColors.appTextColor.withValues(alpha: 0.18),
                      controller: controller.experienceCnt,
                      fillColor: AppColors.white,
                      cursorColor: AppColors.black,
                      fontColor: AppColors.black,
                      fontSize: 15,
                      textInputAction: TextInputAction.next,
                      maxLines: 1,
                      textInputType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                    ),
                  ).paddingOnly(bottom: 21),
                ],
              ).paddingSymmetric(horizontal: 16),
            ).paddingOnly(bottom: 10, top: 10),
            Container(
              width: Get.width,
              color: AppColors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    EnumLocale.txtTalkLanguages.name.tr,
                    style: AppFontStyle.fontStyleW700(
                      fontSize: 17,
                      fontColor: Colors.black,
                    ),
                  ).paddingOnly(top: 16, bottom: 4),
                  Text(
                    EnumLocale.txtSelectLanguages.name.tr,
                    style: AppFontStyle.fontStyleW500(
                      fontSize: 11,
                      fontColor: AppColors.appTextColor,
                    ),
                  ).paddingOnly(top: 4, bottom: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        EnumLocale.txtSelectLanguage.name.tr,
                        style: AppFontStyle.fontStyleW600(
                          fontSize: 16,
                          fontColor: AppColors.onBoardingTxt,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          log("Bottom sheet.....");
                          Get.bottomSheet(
                            AllLanguageBottomSheet(),
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                          );
                          log("Open Bottom sheet.....");
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(6)),
                          child: Text(
                            EnumLocale.txtViewAll.name.tr,
                            style: AppFontStyle.fontStyleW500(fontSize: 12, fontColor: AppColors.onBoardingTxt),
                          ),
                        ),
                      )
                    ],
                  ).paddingOnly(bottom: 12),
                  GetBuilder<HostVerificationController>(
                    builder: (controller) {
                      return Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: controller.selectedLanguages.map((lang) {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              // color: AppColors.lightGrey,
                              border: Border.all(color: AppColors.appColor),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              lang,
                              style: AppFontStyle.fontStyleW500(
                                fontSize: 13,
                                fontColor: AppColors.appColor,
                              ),
                            ),
                          );
                        }).toList(),
                      ).paddingOnly(bottom: 14); // Add spacing from the button
                    },
                  )
                ],
              ).paddingSymmetric(horizontal: 16),
            ).paddingOnly(bottom: 10),
            GetBuilder<HostVerificationController>(
              builder: (controller) {
                return Container(
                  width: Get.width,
                  color: AppColors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${EnumLocale.txtTalkAbout.name.tr} :-",
                        style: AppFontStyle.fontStyleW700(
                          fontSize: 17,
                          fontColor: Colors.black,
                        ),
                      ).paddingOnly(top: 16, bottom: 4),
                      Text(
                        EnumLocale.txtSelectTopic.name.tr,
                        style: AppFontStyle.fontStyleW500(
                          fontSize: 11,
                          fontColor: AppColors.appTextColor,
                        ),
                      ).paddingOnly(top: 4, bottom: 14),
                      ListView.builder(
                        itemCount: controller.talkTopic.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final topic = controller.talkTopic[index];
                          // bool isSelected = controller.selectedTopic == index;
                          bool isSelected = controller.selectedTopics.contains(index);

                          return GestureDetector(
                            onTap: () => controller.selectTopic(index),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                              width: Get.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppColors.appColor : AppColors.grey.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    topic.name.toString(),
                                    style: isSelected
                                        ? AppFontStyle.fontStyleW600(
                                            fontSize: 14,
                                            fontColor: AppColors.appColor,
                                          )
                                        : AppFontStyle.fontStyleW500(
                                            fontSize: 14,
                                            fontColor: AppColors.appTextColor,
                                          ),
                                  ),
                                  Spacer(),
                                  Container(
                                    height: 22,
                                    width: 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: isSelected ? AppColors.transparent : AppColors.grey),
                                      color: isSelected ? Colors.black : AppColors.white,
                                    ),
                                    child: isSelected
                                        ? Container(
                                            decoration: BoxDecoration(
                                              color: AppColors.appColor,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Container(
                                              height: 22,
                                              width: 22,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(color: AppColors.white),
                                                color: AppColors.appColor,
                                              ),
                                            ).paddingAll(0.5),
                                          )
                                        : null,
                                  ),
                                ],
                              ),
                            ).paddingOnly(bottom: 16),
                          );
                        },
                      )
                    ],
                  ).paddingSymmetric(horizontal: 16),
                ).paddingOnly(bottom: 10);
              },
            ),
          ],
        );
      },
    );
  }
}

class HostVerificationListenersDetailBottomButton extends StatelessWidget {
  const HostVerificationListenersDetailBottomButton({super.key});

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
      child: GetBuilder<HostVerificationController>(
        id: Constant.idBecomeHost,
        builder: (controller) {
          return PrimaryAppButton(
            onTap: () {
              controller.validateAndSubmit();
            },
            height: Get.height * 0.06,
            // borderRadius: 30,
            text: EnumLocale.txtSUBMIT.name.tr,
            textStyle: AppFontStyle.fontStyleW600(fontSize: 16, fontColor: AppColors.white),
          ).paddingOnly(bottom: 10);
        },
      ),
    );
  }
}
