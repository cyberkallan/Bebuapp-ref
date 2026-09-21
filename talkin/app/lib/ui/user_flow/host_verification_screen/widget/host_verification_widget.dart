import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talk_in/custom/app_bar/custom_app_bar.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/custom/text_field/custom_text_field.dart';
import 'package:talk_in/custom/title/custom_title.dart';
import 'package:talk_in/ui/user_flow/host_verification_screen/controller/host_verification_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class HostVerificationAppBar extends StatelessWidget {
  const HostVerificationAppBar({super.key});

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

class HostVerificationUploadImageView extends StatefulWidget {
  const HostVerificationUploadImageView({super.key});

  @override
  State<HostVerificationUploadImageView> createState() => _HostVerificationUploadImageViewState();
}

class _HostVerificationUploadImageViewState extends State<HostVerificationUploadImageView> {
  XFile? xFiles;

  final ImagePicker imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            EnumLocale.txtUploadImages.name.tr,
            style: AppFontStyle.fontStyleW700(
              fontSize: 17,
              fontColor: AppColors.black,
            ),
          ),
          Text(
            EnumLocale.txtHostVerificationUploadImageTxt.name.tr,
            style: AppFontStyle.fontStyleW500(
              fontSize: 11,
              fontColor: AppColors.profileText,
              height: 1.8,
            ),
          ).paddingOnly(top: 4, bottom: 18),
          GetBuilder<HostVerificationController>(
            id: Constant.idIdentityProof,
            builder: (controller) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.appTextColor.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      onTap: controller.toggleIdentityExpansion,
                      title: Text(
                        controller.selectedIdentityProof?.title ?? EnumLocale.txtSelectIdentityProof.name.tr,
                        style: controller.selectedIdentityProof == null
                            ? AppFontStyle.fontStyleW500(
                                fontSize: 14,
                                fontColor: AppColors.appTextColor.withValues(alpha: 0.5),
                              )
                            : AppFontStyle.fontStyleW600(
                                fontSize: 14,
                                fontColor: AppColors.black,
                              ),
                      ),
                      trailing: Icon(
                        controller.isIdentityExpanded ? Icons.expand_less : Icons.expand_more,
                        color: AppColors.onBoardingTxt,
                      ),
                    ),
                    if (controller.isIdentityExpanded)
                      Column(
                        children: List.generate(controller.identityProofList.length, (index) {
                          final item = controller.identityProofList[index];
                          return ListTile(
                            title: Text(
                              item.title ?? '',
                              style: AppFontStyle.fontStyleW500(
                                fontSize: 14,
                                fontColor: AppColors.appTextColor.withValues(alpha: 0.5),
                              ),
                            ),
                            onTap: () => controller.selectIdentityProof(item),
                          );
                        }),
                      ),
                  ],
                ),
              ).paddingOnly(bottom: 24);
            },
          ),
          GetBuilder<HostVerificationController>(
            id: Constant.idIdentityProof,
            builder: (controller) {
              return Row(
                children: [
                  // Personal Photo Section
                  Expanded(
                    child: DottedBorder(
                      radius: Radius.circular(14),
                      borderType: BorderType.RRect,
                      padding: EdgeInsets.zero,
                      color: AppColors.onBoardingTxt.withValues(alpha: 0.6),
                      dashPattern: [4, 6],
                      strokeWidth: 1,
                      child: controller.personalPhoto == null
                          ? Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: AppColors.white,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    AppAsset.uploadImage,
                                    height: 45,
                                    width: 45,
                                  ).paddingOnly(top: 17),
                                  Text(
                                    EnumLocale.txtUploadImag.name.tr,
                                    style: AppFontStyle.fontStyleW600(
                                      fontSize: 11,
                                      fontColor: AppColors.black,
                                    ),
                                  ).paddingOnly(top: 10),
                                  Text(
                                    EnumLocale.txtPersonalPhotos.name.tr,
                                    style: AppFontStyle.fontStyleW600(
                                      fontSize: 9,
                                      fontColor: AppColors.onBoardingTxt,
                                    ),
                                  ).paddingOnly(top: 6, bottom: 7),
                                  GestureDetector(
                                    onTap: () => controller.pickImage(isPersonalPhoto: true),
                                    child: Container(
                                      width: Get.width,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: AppColors.appColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Center(
                                        child: Text(
                                          EnumLocale.txtCapture.name.tr,
                                          style: AppFontStyle.fontStyleW600(fontSize: 10, fontColor: AppColors.white),
                                        ),
                                      ),
                                    ).paddingOnly(bottom: 10, left: 10, right: 10),
                                  ),
                                ],
                              ),
                            )
                          : Stack(
                              clipBehavior: Clip.none,
                              children: [
                                SizedBox(
                                  height: 150, // Set a fixed height for image
                                  width: double.infinity,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.file(
                                      File(controller.personalPhoto!),
                                      fit: BoxFit.cover, // Ensures image is scaled proportionally
                                    ),
                                  ).paddingAll(8),
                                ),
                                Positioned(
                                  top: -10,
                                  right: -8,
                                  child: GestureDetector(
                                    onTap: () {
                                      controller.personalPhoto = null; // Clear the personal photo
                                      controller.update([Constant.idIdentityProof]);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.appColor,
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        color: AppColors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  SizedBox(width: 10),

                  // ID Proof Photo 1 Section
                  Expanded(
                    child: DottedBorder(
                      radius: Radius.circular(14),
                      borderType: BorderType.RRect,
                      padding: EdgeInsets.zero,
                      color: AppColors.onBoardingTxt.withValues(alpha: 0.6),
                      dashPattern: [4, 5],
                      strokeWidth: 1,
                      child: controller.idProofPhoto1 == null
                          ? Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: AppColors.white,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    AppAsset.uploadIdImage,
                                    height: 45,
                                    width: 45,
                                  ).paddingOnly(top: 17),
                                  Text(
                                    EnumLocale.txtUploadIDPhotos.name.tr,
                                    style: AppFontStyle.fontStyleW600(
                                      fontSize: 11,
                                      fontColor: AppColors.black,
                                    ),
                                  ).paddingOnly(top: 10),
                                  Text(
                                    EnumLocale.txtFrontSide.name.tr,
                                    style: AppFontStyle.fontStyleW600(
                                      fontSize: 9,
                                      fontColor: AppColors.onBoardingTxt,
                                    ),
                                  ).paddingOnly(top: 6, bottom: 7),
                                  GestureDetector(
                                    onTap: () => controller.pickImage(isPersonalPhoto: false),
                                    child: Container(
                                      width: Get.width,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: AppColors.appColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Center(
                                        child: Text(
                                          EnumLocale.txtAttach.name.tr,
                                          style: AppFontStyle.fontStyleW600(fontSize: 10, fontColor: AppColors.white),
                                        ),
                                      ),
                                    ).paddingOnly(bottom: 10, left: 10, right: 10),
                                  ),
                                ],
                              ),
                            )
                          : Stack(
                              clipBehavior: Clip.none,
                              children: [
                                SizedBox(
                                  height: 150, // Set a fixed height for image
                                  width: double.infinity,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.file(
                                      File(controller.idProofPhoto1!),
                                      fit: BoxFit.cover, // Ensures image is scaled proportionally
                                    ),
                                  ).paddingAll(8),
                                ),
                                Positioned(
                                  top: -10,
                                  right: -8,
                                  child: GestureDetector(
                                    onTap: () {
                                      controller.idProofPhoto1 = null; // Clear the ID proof photo 1
                                      controller.update([Constant.idIdentityProof]);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.appColor,
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        color: AppColors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  SizedBox(width: 10),

                  // ID Proof Photo 2 Section
                  Expanded(
                    child: DottedBorder(
                      radius: Radius.circular(14),
                      borderType: BorderType.RRect,
                      padding: EdgeInsets.zero,
                      color: AppColors.onBoardingTxt.withValues(alpha: 0.6),
                      dashPattern: [4, 5],
                      strokeWidth: 1,
                      child: controller.idProofPhoto2 == null
                          ? Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: AppColors.white,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    AppAsset.uploadIdImage,
                                    height: 45,
                                    width: 45,
                                  ).paddingOnly(top: 17),
                                  Text(
                                    EnumLocale.txtUploadIDPhotos.name.tr,
                                    style: AppFontStyle.fontStyleW600(
                                      fontSize: 11,
                                      fontColor: AppColors.black,
                                    ),
                                  ).paddingOnly(top: 10),
                                  Text(
                                    EnumLocale.txtBackSide.name.tr,
                                    style: AppFontStyle.fontStyleW600(
                                      fontSize: 9,
                                      fontColor: AppColors.onBoardingTxt,
                                    ),
                                  ).paddingOnly(top: 6, bottom: 7),
                                  GestureDetector(
                                    onTap: () => controller.pickImage(isPersonalPhoto: false),
                                    child: Container(
                                      width: Get.width,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: AppColors.appColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Center(
                                        child: Text(
                                          EnumLocale.txtAttach.name.tr,
                                          style: AppFontStyle.fontStyleW600(fontSize: 10, fontColor: AppColors.white),
                                        ),
                                      ),
                                    ).paddingOnly(bottom: 10, left: 10, right: 10),
                                  ),
                                ],
                              ),
                            )
                          : Stack(
                              clipBehavior: Clip.none,
                              children: [
                                SizedBox(
                                  height: 150, // Set a fixed height for image
                                  width: double.infinity,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.file(
                                      File(controller.idProofPhoto2!),
                                      fit: BoxFit.cover, // Ensures image is scaled proportionally
                                    ),
                                  ).paddingAll(8),
                                ),
                                Positioned(
                                  top: -10,
                                  right: -8,
                                  child: GestureDetector(
                                    onTap: () {
                                      controller.idProofPhoto2 = null; // Clear the ID proof photo 2
                                      controller.update([Constant.idIdentityProof]);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.appColor,
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        color: AppColors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              );
            },
          )
        ],
      ),
    ).paddingOnly(bottom: 10);
  }
}

class HostVerificationFillFormView extends StatelessWidget {
  const HostVerificationFillFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            EnumLocale.txtFillForm.name.tr,
            style: AppFontStyle.fontStyleW700(
              fontSize: 17,
              fontColor: AppColors.black,
            ),
          ),
          Text(
            EnumLocale.txtHostVerificationFillForm.name.tr,
            style: AppFontStyle.fontStyleW500(
              fontSize: 11,
              fontColor: AppColors.profileText,
              height: 1.8,
            ),
          ).paddingOnly(top: 4, bottom: 24),
          GetBuilder<HostVerificationController>(
            builder: (logic) {
              return Form(
                key: logic.formKey,
                child: Column(
                  children: [
                    // CustomTitle(
                    //   title: EnumLocale.txtRequestID.name.tr,
                    //   textStyle: AppFontStyle.fontStyleW500(
                    //     fontSize: 12,
                    //     fontColor: AppColors.appTextColor,
                    //   ),
                    //   method: CustomTextField(
                    //     filled: true,
                    //     borderColor: AppColors.appTextColor.withValues(alpha: 0.5),
                    //     controller: logic.requestIDController,
                    //     fillColor: AppColors.white,
                    //     cursorColor: AppColors.black,
                    //     fontColor: AppColors.black,
                    //     fontSize: 15,
                    //     textInputAction: TextInputAction.next,
                    //     maxLines: 1,
                    //   ),
                    // ).paddingOnly(bottom: 21),
                    // CustomTitle(
                    //   title: EnumLocale.txtEnterName.name.tr,
                    //   textStyle: AppFontStyle.fontStyleW500(
                    //     fontSize: 12,
                    //     fontColor: AppColors.appTextColor,
                    //   ),
                    //   method: CustomTextField(
                    //     filled: true,
                    //     borderColor: AppColors.appTextColor.withValues(alpha: 0.5),
                    //     controller: logic.nameController,
                    //     fillColor: AppColors.white,
                    //     cursorColor: AppColors.black,
                    //     fontColor: AppColors.black,
                    //     fontSize: 15,
                    //     textInputAction: TextInputAction.next,
                    //     inputFormatters: [UpperCaseTextFormatter()],
                    //     validator: (value) {
                    //       if (value == null || value.isEmpty) {
                    //         return EnumLocale.desEnterFullName.name.tr;
                    //       }
                    //       return null;
                    //     },
                    //   ),
                    // ).paddingOnly(bottom: 21),
                    Database.loginType == 2
                        ? SizedBox()
                        : CustomTitle(
                            title: EnumLocale.txtEnterMail.name.tr,
                            textStyle: AppFontStyle.fontStyleW500(
                              fontSize: 12,
                              fontColor: AppColors.appTextColor,
                            ),
                            method: CustomTextField(
                              filled: true,
                              borderColor: AppColors.appTextColor.withValues(alpha: 0.5),
                              controller: logic.emailController,
                              fillColor: AppColors.white,
                              cursorColor: AppColors.black,
                              fontColor: AppColors.black,
                              fontSize: 15,
                              textInputAction: TextInputAction.next,
                              textInputType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return EnumLocale.desEnterEmail.name.tr;
                                } else if (!logic.isEmailValid(value)) {
                                  return EnumLocale.desEnterValidEmailAddress.name.tr;
                                } else if (!value.toLowerCase().endsWith('@gmail.com')) {
                                  return 'Please enter a Gmail address';
                                }

                                return null;
                              },
                            ),
                          ).paddingOnly(bottom: 21),
                    CustomTitle(
                      title: EnumLocale.txtEnterYourAddress.name.tr,
                      textStyle: AppFontStyle.fontStyleW500(
                        fontSize: 12,
                        fontColor: AppColors.appTextColor,
                      ),
                      method: CustomTextField(
                        filled: true,
                        borderColor: AppColors.appTextColor.withValues(alpha: 0.5),
                        controller: logic.addressController,
                        fillColor: AppColors.white,
                        cursorColor: AppColors.black,
                        fontColor: AppColors.black,
                        fontSize: 15,
                        textInputAction: TextInputAction.next,
                        maxLines: 1,
                      ),
                    ).paddingOnly(bottom: 21),
                    CustomTitle(
                      title: EnumLocale.txtCountry.name.tr,
                      textStyle: AppFontStyle.fontStyleW500(
                        fontSize: 12,
                        fontColor: AppColors.appTextColor,
                      ),
                      method: CustomTextField(
                        filled: true,
                        borderColor: AppColors.appTextColor.withValues(alpha: 0.5),
                        controller: logic.countryCnt,
                        fillColor: AppColors.white,
                        cursorColor: AppColors.black,
                        fontColor: AppColors.black,
                        fontSize: 15,
                        textInputAction: TextInputAction.next,
                        maxLines: 1,
                      ),
                    ).paddingOnly(bottom: 21),
                    CustomTitle(
                      title: EnumLocale.txtEnterYourAge.name.tr,
                      textStyle: AppFontStyle.fontStyleW500(
                        fontSize: 12,
                        fontColor: AppColors.appTextColor,
                      ),
                      method: CustomTextField(
                        filled: true,
                        borderColor: AppColors.appTextColor.withValues(alpha: 0.5),
                        controller: logic.ageController,
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
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

class HostVerificationBottomButton extends StatelessWidget {
  const HostVerificationBottomButton({super.key});

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
        builder: (controller) {
          return PrimaryAppButton(
            onTap: () {
              controller.validateAndNext();
            },
            height: Get.height * 0.06,
            // borderRadius: 30,
            text: EnumLocale.txtNext.name.tr,
            textStyle: AppFontStyle.fontStyleW600(fontSize: 16, fontColor: AppColors.white),
          ).paddingOnly(bottom: 10);
        },
      ),
    );
  }
}
