import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/custom/text_field/custom_text_field.dart';
import 'package:talk_in/custom/title/custom_title.dart';
import 'package:talk_in/ui/host_flow/host_listeners_detail_screen/controller/host_listeners_detail_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class HostListenersDetailTopView extends StatelessWidget {
  const HostListenersDetailTopView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GetBuilder<HostListenersDetailController>(
          builder: (controller) {
            final String? localImagePath = controller.pickImage;

            return SizedBox(
              height: Get.height * 0.38,
              width: Get.width,
              child: localImagePath != null
                  ? Image.file(
                      File(localImagePath),
                      fit: BoxFit.cover,
                    )
                  : CustomProfileImage(
                      image: Database.fetchListenerProfileModel?.data?.image ?? '',
                    ),
            ).paddingOnly(bottom: 10);
          },
        ),
        Positioned(
          bottom: 22,
          left: 115,
          right: 115,
          child: GestureDetector(
            onTap: () {
              Get.defaultDialog(
                  backgroundColor: AppColors.white,
                  title: EnumLocale.changeYourImage.name.tr,
                  titlePadding: const EdgeInsets.only(top: 30),
                  titleStyle: AppFontStyle.fontStyleW700(fontSize: 16, fontColor: AppColors.appColor),
                  content: GetBuilder<HostListenersDetailController>(
                    builder: (controller) {
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Divider(
                              thickness: 1,
                              color: Colors.grey.shade100,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.back();
                              controller.takePhoto();
                            },
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Image(
                                      color: AppColors.appColor,
                                      image: const AssetImage(AppAsset.cameraFlipIcon),
                                      height: 20,
                                    ),
                                  ),
                                  Text(
                                    EnumLocale.txtTakeAphoto.name.tr,
                                    style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: AppColors.appColor),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: GestureDetector(
                              onTap: () {
                                Get.back();
                                controller.getImageFromGallery();
                              },
                              child: Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: Image(
                                        color: AppColors.appColor,
                                        image: const AssetImage(AppAsset.chatImageIcon),
                                        height: 20,
                                      ),
                                    ),
                                    Text(
                                      EnumLocale.txtChooseFromYourFile.name.tr,
                                      style: AppFontStyle.fontStyleW700(fontSize: 15, fontColor: AppColors.appColor),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ));
            },
            child: Container(
              padding: EdgeInsets.only(top: 6, bottom: 6, left: 10, right: 9),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.white.withValues(alpha: 0.30),
                    offset: Offset(0, 0),
                    spreadRadius: 0,
                    blurRadius: 12.7,
                  ),
                ],
                color: AppColors.black.withValues(alpha: 0.40),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    AppAsset.uploadImageIcon,
                    color: AppColors.white,
                    height: 14,
                    width: 22,
                  ).paddingOnly(right: 3),
                  Text(
                    EnumLocale.txtChangeImage.name.tr,
                    style: AppFontStyle.fontStyleW800(
                      fontSize: 12,
                      fontColor: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}

class HostListenersDetailView extends StatelessWidget {
  const HostListenersDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HostListenersDetailController>(
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
                      controller: controller.nameCnt,
                      fillColor: AppColors.white,
                      cursorColor: AppColors.black,
                      fontColor: AppColors.black,
                      fontSize: 15,
                      textInputAction: TextInputAction.next,
                      maxLines: 1,
                    ),
                  ).paddingOnly(bottom: 18),
                  CustomTitle(
                    title: EnumLocale.txtNickName.name.tr,
                    textStyle: AppFontStyle.fontStyleW500(
                      fontSize: 12,
                      fontColor: AppColors.listenersDetail,
                    ),
                    method: CustomTextField(
                      filled: true,
                      borderColor: AppColors.appTextColor.withValues(alpha: 0.18),
                      controller: controller.nickNameCnt,
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
                ],
              ).paddingSymmetric(horizontal: 16),
            ).paddingOnly(bottom: 10),
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
                          Get.bottomSheet(
                            AllLanguageBottomSheet(),
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                          );
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
                  GetBuilder<HostListenersDetailController>(
                    id: Constant.idLanguageSection, // ⬅ ID used to trigger rebuild
                    builder: (controller) {
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: controller.selectedLanguages.map((lang) {
                          final isSelected = controller.isSelected(lang);
                          return GestureDetector(
                            onTap: () => controller.toggleLanguage(lang),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected ? AppColors.appColor : AppColors.grey.withValues(alpha: 0.2),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                lang,
                                style: AppFontStyle.fontStyleW500(
                                  fontSize: 13,
                                  fontColor: isSelected ? AppColors.appColor : AppColors.appTextColor,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ).paddingOnly(bottom: 16);
                    },
                  ),
                ],
              ).paddingSymmetric(horizontal: 16),
            ).paddingOnly(bottom: 10),
            Container(
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
                  GetBuilder<HostListenersDetailController>(
                    id: Constant.talkAboutTopic,
                    builder: (controller) {
                      return ListView.builder(
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
                      );
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTitle(
                          title: EnumLocale.txtPrivateVideoCallRate.name.tr,
                          textStyle: AppFontStyle.fontStyleW500(
                            fontSize: 12,
                            fontColor: AppColors.listenersDetail,
                          ),
                          method: CustomTextField(
                            filled: true,
                            borderColor: AppColors.appTextColor.withValues(alpha: 0.18),
                            controller: controller.ratePrivateVideoCallCnt,
                            fillColor: AppColors.white,
                            cursorColor: AppColors.black,
                            fontColor: AppColors.black,
                            fontSize: 15,
                            textInputAction: TextInputAction.next,
                            maxLines: 1,
                            textInputType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ).paddingOnly(bottom: 18),
                      ),
                      8.width,
                      Expanded(
                        child: CustomTitle(
                          title: EnumLocale.txtPrivateAudioCallRate.name.tr,
                          textStyle: AppFontStyle.fontStyleW500(
                            fontSize: 12,
                            fontColor: AppColors.listenersDetail,
                          ),
                          method: CustomTextField(
                            filled: true,
                            borderColor: AppColors.appTextColor.withValues(alpha: 0.18),
                            controller: controller.ratePrivateAudioCallCnt,
                            fillColor: AppColors.white,
                            cursorColor: AppColors.black,
                            fontColor: AppColors.black,
                            fontSize: 15,
                            textInputAction: TextInputAction.next,
                            textInputType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            maxLines: 1,
                          ),
                        ).paddingOnly(bottom: 18),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTitle(
                          title: EnumLocale.txtRandomVideoCallRate.name.tr,
                          textStyle: AppFontStyle.fontStyleW500(
                            fontSize: 12,
                            fontColor: AppColors.listenersDetail,
                          ),
                          method: CustomTextField(
                            filled: true,
                            borderColor: AppColors.appTextColor.withValues(alpha: 0.18),
                            controller: controller.rateRandomVideoCallCnt,
                            fillColor: AppColors.white,
                            cursorColor: AppColors.black,
                            fontColor: AppColors.black,
                            fontSize: 15,
                            textInputAction: TextInputAction.next,
                            maxLines: 1,
                            textInputType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ).paddingOnly(bottom: 18),
                      ),
                      8.width,
                      Expanded(
                        child: CustomTitle(
                          title: EnumLocale.txtRandomAudioCallRate.name.tr,
                          textStyle: AppFontStyle.fontStyleW500(
                            fontSize: 12,
                            fontColor: AppColors.listenersDetail,
                          ),
                          method: CustomTextField(
                            filled: true,
                            borderColor: AppColors.appTextColor.withValues(alpha: 0.18),
                            controller: controller.rateRandomAudioCallCnt,
                            fillColor: AppColors.white,
                            cursorColor: AppColors.black,
                            fontColor: AppColors.black,
                            fontSize: 15,
                            textInputAction: TextInputAction.next,
                            maxLines: 1,
                            textInputType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ).paddingOnly(bottom: 18),
                      ),
                    ],
                  )
                ],
              ).paddingSymmetric(horizontal: 16),
            ).paddingOnly(bottom: 10),
          ],
        );
      },
    );
  }
}

class HostListenersDetailBottomButton extends StatelessWidget {
  const HostListenersDetailBottomButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HostListenersDetailController>(
      builder: (controller) {
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
            onTap: () {
              controller.onSaveProfile();
            },
            child: Center(
              child: Text(
                EnumLocale.txtSAVED.name.tr,
                style: AppFontStyle.fontStyleW600(fontSize: 16, fontColor: AppColors.white),
              ),
            ),
          ).paddingOnly(bottom: 10),
        );
      },
    );
  }
}

class AllLanguageBottomSheet extends StatelessWidget {
  AllLanguageBottomSheet({super.key});

  final controller = Get.find<HostListenersDetailController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.6,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: GetBuilder<HostListenersDetailController>(
        id: Constant.idLanguageSection,
        builder: (_) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    EnumLocale.txtSelectLanguage.name.tr,
                    style: AppFontStyle.fontStyleW600(
                      fontSize: 16,
                      fontColor: AppColors.onBoardingTxt,
                    ),
                  ).paddingOnly(bottom: 20, top: 20),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "Done",
                        style: AppFontStyle.fontStyleW500(fontSize: 14, fontColor: AppColors.onBoardingTxt),
                      ),
                    ),
                  )
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: controller.allLanguages.map((lang) {
                      final isSelected = controller.isSelected(lang);
                      return GestureDetector(
                        onTap: () => controller.toggleLanguage(lang),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected ? AppColors.appColor : AppColors.grey.withAlpha(50),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            lang,
                            style: AppFontStyle.fontStyleW500(
                              fontSize: 13,
                              fontColor: isSelected ? AppColors.appColor : AppColors.appTextColor,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ).paddingOnly(bottom: 16),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
