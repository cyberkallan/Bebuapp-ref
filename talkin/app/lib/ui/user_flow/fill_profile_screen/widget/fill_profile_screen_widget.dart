import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:talk_in/custom/app_bar/custom_app_bar.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/custom/custom_select_gender_bottom_sheet/custom_select_gender_bottom_sheet.dart';
import 'package:talk_in/custom/text_field/custom_text_field.dart';
import 'package:talk_in/custom/title/custom_title.dart';
import 'package:talk_in/ui/user_flow/fill_profile_screen/controller/fill_profile_screen_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class FillProfileScreenAppBar extends StatelessWidget {
  const FillProfileScreenAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(120),
      child: CustomAppBar(
        appBarColor: AppColors.lightPurple,
        title: EnumLocale.txtMyProfile.name.tr,
        showLeadingIcon: false,
        // appBarColor: AppColors.purple200.withValues(alpha: 0.1),
      ),
    );
  }
}

class FillProfileImageView extends StatelessWidget {
  const FillProfileImageView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FillProfileScreenController>(
      builder: (controller) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.appColor),
                shape: BoxShape.circle,
              ),
              child: Container(
                // clipBehavior: Clip.hardEdge,
                height: Get.height * 0.1,
                width: Get.height * 0.1,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.white),
                  color: AppColors.lightGrey,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: controller.pickImage != null && controller.pickImage!.isNotEmpty
                      ? Image.file(
                          File("${controller.pickImage}"),
                          height: 210,
                          width: Get.width,
                          fit: BoxFit.cover,
                        )
                      : controller.photo != null && controller.photo!.isNotEmpty
                          ? CustomProfileImage(
                              image: "${controller.photo}",
                            )
                          : Image.asset(AppAsset.profilePlaceHolder),
                ),
              ).paddingAll(1),
            ).paddingOnly(top: 34, bottom: 16),
            GestureDetector(
              onTap: () {
                Get.defaultDialog(
                    backgroundColor: AppColors.white,
                    title: EnumLocale.changeYourImage.name.tr,
                    titlePadding: const EdgeInsets.only(top: 30),
                    titleStyle: AppFontStyle.fontStyleW700(fontSize: 16, fontColor: AppColors.appColor),
                    content: GetBuilder<FillProfileScreenController>(
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
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.appColor,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      AppAsset.uploadImageIcon,
                      height: 22,
                      width: 22,
                    ),
                    Text(
                      EnumLocale.txtChangeImage.name.tr,
                      style: AppFontStyle.fontStyleW700(fontSize: 12, fontColor: AppColors.appColor),
                    ).paddingOnly(left: 6, right: 6)
                  ],
                ),
              ).paddingOnly(right: 14),
            ),
          ],
        );
      },
    );
  }
}

class FillProfileEditInfoView extends StatelessWidget {
  const FillProfileEditInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FillProfileScreenController>(
      builder: (logic) {
        return Form(
          // key: logic.formKey,
          child: Column(
            children: [
              CustomTitle(
                title: EnumLocale.txtFullName.name.tr,
                method: CustomTextField(
                  filled: true,
                  hintText: EnumLocale.txtAddYOurFullName.name.tr,
                  controller: logic.nameController,
                  fillColor: AppColors.white,
                  cursorColor: AppColors.black,
                  fontColor: AppColors.black,
                  fontSize: 15,
                  textInputAction: TextInputAction.next,
                ),
              ).paddingOnly(bottom: 30, top: 30),
              CustomTitle(
                title: EnumLocale.txtNickName.name.tr,
                method: CustomTextField(
                  filled: true,
                  hintText: EnumLocale.txtAddYourNickName.name.tr,
                  controller: logic.nickNameController,
                  fillColor: AppColors.white,
                  cursorColor: AppColors.black,
                  fontColor: AppColors.black,
                  fontSize: 15,
                  textInputAction: TextInputAction.next,
                ),
              ).paddingOnly(bottom: 30),
              if (Database.loginType != 2)
                GestureDetector(
                  onTap: () {
                    log("Database.loginType  :::: ${Database.loginType}");
                  },
                  child: CustomTitle(
                    title: EnumLocale.txtEnterMail.name.tr,
                    method: CustomTextField(
                      filled: true,
                      hintText: EnumLocale.txtEnterYourMail.name.tr,
                      controller: logic.emailController,
                      fillColor: AppColors.white,
                      cursorColor: AppColors.black,
                      fontColor: AppColors.black,
                      fontSize: 15,
                      textInputAction: TextInputAction.next,
                      readOnly: Database.loginType == 1 || Database.loginType == 4,
                    ),
                  ).paddingOnly(bottom: 30),
                ),
              GetBuilder<FillProfileScreenController>(
                // init: DatePickerController(),
                builder: (controller) {
                  return CustomTitle(
                    title: EnumLocale.txtDateOfBirth.name.tr,
                    method: CustomTextField(
                      filled: true,
                      hintText: "DD / MM / YYYY",
                      controller: controller.dateController,
                      fillColor: AppColors.white,
                      cursorColor: AppColors.black,
                      fontColor: AppColors.black,
                      fontSize: 15,
                      textInputAction: TextInputAction.next,
                      maxLines: 1,
                      readOnly: true,
                      onTap: () => controller.selectDate(context),
                    ),
                  ).paddingOnly(bottom: 30);
                },
              ),
              CustomTitle(
                title: EnumLocale.txtGenderIdentity.name.tr,
                method: GetBuilder<FillProfileScreenController>(
                  init: FillProfileScreenController(), // <<=== ADD THIS

                  builder: (controller) {
                    return CustomTextField(
                      onTap: () {
                        debugPrint("GestureDetector TAPPED");

                        // Get.toNamed(AppRoutes.selectGenderScreen);
                        Get.bottomSheet(
                          const CustomEditeProfileSelectGenderBottomSheet(),
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                        );
                      },
                      filled: true,
                      controller: controller.genderController,
                      fillColor: AppColors.white,
                      cursorColor: AppColors.black,
                      fontColor: AppColors.black,
                      fontSize: 15,
                      textInputAction: TextInputAction.next,
                      maxLines: 1,
                      readOnly: true,
                      suffixIcon: SizedBox(
                        height: 20,
                        width: 20,
                        child: RotatedBox(
                          quarterTurns: 2,
                          child: Image.asset(
                            AppAsset.backArrowIcon,
                            height: 8,
                            width: 8,
                          ).paddingAll(17),
                        ),
                      ),
                    );
                  },
                ),
              ).paddingOnly(bottom: 30),
              CustomTitle(
                title: EnumLocale.txtSelectCountry.name.tr,
                method: GetBuilder<FillProfileScreenController>(
                  id: Constant.idChangeCountry,
                  builder: (logic) {
                    return GestureDetector(
                      onTap: () {
                        debugPrint("GestureDetector TAPPED");
                        logic.onChangeCountry(context);
                      },
                      child: Container(
                        height: 55,
                        width: Get.width,
                        // padding: const EdgeInsets.only(left: 20),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          border: Border.all(color: AppColors.black),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: logic.countryController.text.isEmpty
                            ? Row(
                                children: [
                                  Text(
                                    EnumLocale.txtSelectCountry.name.tr,
                                    style: AppFontStyle.fontStyleW500(
                                      fontSize: 13,
                                      fontColor: AppColors.black.withValues(alpha: 0.2),
                                    ),
                                  ).paddingOnly(left: 10),
                                ],
                              )
                            : Row(
                                children: [
                                  Text(
                                    logic.flagController.text,
                                    style: AppFontStyle.fontStyleW500(fontColor: AppColors.black, fontSize: 20),
                                  ),
                                  10.width,
                                  Text(
                                    logic.countryController.text,
                                    style: AppFontStyle.fontStyleW600(fontColor: AppColors.black, fontSize: 15),
                                  ),
                                  const Spacer(),
                                  Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Icon(
                                        Icons.keyboard_arrow_down_sharp,
                                        color: AppColors.black,
                                        size: 18,
                                      )),
                                  10.width,
                                ],
                              ).paddingOnly(left: 10),
                      ),
                    );
                  },
                ).paddingOnly(bottom: 30),
              ),
              CustomTitle(
                title: EnumLocale.txtEnterMobileNumber.name.tr,
                method: GetBuilder<FillProfileScreenController>(
                  builder: (logic) {
                    return Form(
                      key: logic.formKey,
                      child: IntlPhoneField(
                        flagsButtonPadding: const EdgeInsets.all(8),
                        flagsButtonMargin: const EdgeInsets.only(right: 13),
                        dropdownIconPosition: IconPosition.trailing,
                        controller: logic.numberController,
                        obscureText: false,
                        validator: (value) {
                          if (value == null) {
                            return EnumLocale.desEnterMobile.name.tr;
                          }
                          return null;
                        },
                        style: AppFontStyle.fontStyleW600(
                          fontSize: 12,
                          fontColor: AppColors.appColor,
                        ),
                        cursorColor: AppColors.appColor,
                        dropdownTextStyle: AppFontStyle.fontStyleW700(
                          fontSize: 16,
                          fontColor: AppColors.black,
                        ),
                        pickerDialogStyle: PickerDialogStyle(
                          countryCodeStyle: AppFontStyle.fontStyleW700(
                            fontSize: 13,
                            fontColor: AppColors.appColor,
                          ),
                          countryNameStyle: AppFontStyle.fontStyleW700(
                            fontSize: 13,
                            fontColor: AppColors.appColor,
                          ),
                          searchFieldCursorColor: AppColors.appColor,
                          searchFieldInputDecoration: InputDecoration(
                            hintStyle: AppFontStyle.fontStyleW400(
                              fontSize: 14,
                              fontColor: AppColors.grey,
                            ),
                            hintText: EnumLocale.txtSearchCountryCode.name.tr,
                          ),
                        ),
                        dropdownIcon: Icon(
                          Icons.arrow_drop_down_outlined,
                          color: AppColors.black,
                        ),
                        keyboardType: TextInputType.number,
                        showCountryFlag: false,
                        decoration: InputDecoration(
                          counterText: '',
                          hintStyle: AppFontStyle.fontStyleW600(
                            fontSize: 12,
                            fontColor: AppColors.white,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.black),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.black),
                          ),
                          filled: true,
                          fillColor: AppColors.white,
                          errorStyle: AppFontStyle.fontStyleW500(
                            fontSize: 8,
                            fontColor: AppColors.red,
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.red),
                          ),
                          counterStyle: AppFontStyle.fontStyleW500(
                            fontSize: 9,
                            fontColor: AppColors.grey,
                          ),
                        ),
                        onCountryChanged: (value) {
                          log("message================= ${value.code}");
                          Database.onSetSelectedCountryCode(value.code);
                          Database.getDialCode();
                          log("Database.selectedCountryCode message================= ${Database.selectedCountryCode}");
                        },
                        initialCountryCode: Database.selectedCountryCode,
                        onChanged: (phone) {
                          logic.dialCode = phone.countryCode; // example: +91
                          logic.numberController.text = phone.number; // only number part
                        },
                      ),
                    );
                  },
                ),
              ).paddingOnly(bottom: 30)
            ],
          ),
        );
      },
    );
  }
}

GetBuilder<GetxController> saveProfileButton() {
  return GetBuilder<FillProfileScreenController>(
    builder: (controller) {
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
            PrimaryAppButton(
              onTap: () {
                controller.onSaveProfile();
              },
              color: AppColors.appColor,
              height: Get.height * 0.056,
              text: EnumLocale.txtSaveProfile.name.tr,
              textStyle: AppFontStyle.fontStyleW500(fontSize: 16, fontColor: AppColors.white),
            ).paddingSymmetric(horizontal: 24),
          ],
        ).paddingOnly(top: 10, bottom: 10),
      );
    },
  );
}
