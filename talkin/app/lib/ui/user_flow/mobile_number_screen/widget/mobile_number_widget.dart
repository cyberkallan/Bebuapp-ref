import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:talk_in/custom/app_bar/custom_app_bar.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/custom/title/custom_title.dart';
import 'package:talk_in/ui/user_flow/mobile_number_screen/controller/mobile_number_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

/// =================== Complete Registration App Bar =================== ///
class MobileNumberAppBarView extends StatelessWidget {
  const MobileNumberAppBarView({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(120),
      child: CustomAppBar(
        title: EnumLocale.txtLogIn.name.tr,
        showLeadingIcon: true,
      ),
    );
  }
}

/// =================== Description =================== ///
class MobileNumberDescriptionView extends StatelessWidget {
  const MobileNumberDescriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          EnumLocale.txtLogInWithMobile.name.tr,
          // textAlign: TextAlign.center,
          style: AppFontStyle.fontStyleW800(
            fontSize: 32,
            fontColor: AppColors.appColor,
          ),
        ).paddingOnly(bottom: 6),
        Text(
          EnumLocale.txtMobileLoginDescription.name.tr, // textAlign: TextAlign.center,
          style: AppFontStyle.fontStyleW400(
            height: 1.9,
            fontSize: 12,
            fontColor: AppColors.grey,
          ),
        ).paddingOnly(right: 30),
      ],
    );
  }
}

/// =================== Complete Registration OTP =================== ///
class MobileNumberOTPView extends StatelessWidget {
  const MobileNumberOTPView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomTitle(
      title: EnumLocale.txtEnterMobileNumber.name.tr,
      method: GetBuilder<MobileNumberController>(
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
                  fontSize: 14,
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
                initialCountryCode: Database.selectedCountryCode,
                onCountryChanged: (value) {
                  log("message================= ${value.code}");
                  Database.onSetSelectedCountryCode(value.code);
                  Database.getDialCode();

                  log("Database.selectedCountryCode message================= ${Database.selectedCountryCode}");
                },
                onChanged: (phone) {
                  logic.dialCode = phone.countryCode; // example: +91
                  logic.numberController.text = phone.number; // only number part
                }),
          );
        },
      ),
    ).paddingOnly(top: 20);
  }
}

/// =================== Complete Registration Button =================== ///
class MobileNumberButtonView extends StatelessWidget {
  const MobileNumberButtonView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MobileNumberController>(
      builder: (logic) {
        return Center(
          child: PrimaryAppButton(
            height: 50,
            // width: Get.width * 0.75,
            onTap: () {
              logic.sendOtp(context);
            },
            widget: Image.asset(
              AppAsset.arrowUp,
              height: 15,
              width: 15,
            ),
            text: EnumLocale.txtGetOtp.name.tr,
            textStyle: AppFontStyle.fontStyleW500(fontSize: 16, fontColor: AppColors.white),
          ).paddingOnly(bottom: 15, left: 20, right: 20),
        );
      },
    );
  }
}
