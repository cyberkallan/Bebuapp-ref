import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_bar/custom_app_bar.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/custom/text_field/custom_text_field.dart';
import 'package:talk_in/custom/title/custom_title.dart';
import 'package:talk_in/ui/user_flow/forgot_password_screen/controller/forgot_password_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

/// =================== Complete Registration App Bar =================== ///
class ForgotPasswordAppBar extends StatelessWidget {
  const ForgotPasswordAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(120),
      child: CustomAppBar(
        title: EnumLocale.txtForgotPassword.name.tr,
        showLeadingIcon: true,
      ),
    );
  }
}

/// =================== Description =================== ///
class ForgotPasswordDescriptionView extends StatelessWidget {
  const ForgotPasswordDescriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          EnumLocale.txtForgotYourPassword.name.tr,
          // textAlign: TextAlign.center,
          style: AppFontStyle.fontStyleW800(
            fontSize: 32,
            fontColor: AppColors.appColor,
          ),
        ).paddingOnly(bottom: 6),
        Text(
          EnumLocale.txtForgetPasswordDescription.name.tr, // textAlign: TextAlign.center,
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
class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomTitle(
      title: EnumLocale.txtEnterMailMobileNumber.name.tr,
      method: GetBuilder<ForgotPasswordController>(
        builder: (logic) {
          return Form(
            key: logic.formKey,
            // child: IntlPhoneField(
            //     flagsButtonPadding: const EdgeInsets.all(8),
            //     flagsButtonMargin: const EdgeInsets.only(right: 13),
            //     dropdownIconPosition: IconPosition.trailing,
            //     controller: logic.numberController,
            //     obscureText: false,
            //     validator: (value) {
            //       if (value == null) {
            //         return EnumLocale.desEnterMobile.name.tr;
            //       }
            //       return null;
            //     },
            //     style: AppFontStyle.fontStyleW600(
            //       fontSize: 12,
            //       fontColor: AppColors.appColor,
            //     ),
            //     cursorColor: AppColors.appColor,
            //     dropdownTextStyle: AppFontStyle.fontStyleW700(
            //       fontSize: 16,
            //       fontColor: AppColors.black,
            //     ),
            //     pickerDialogStyle: PickerDialogStyle(
            //       countryCodeStyle: AppFontStyle.fontStyleW700(
            //         fontSize: 13,
            //         fontColor: AppColors.appColor,
            //       ),
            //       countryNameStyle: AppFontStyle.fontStyleW700(
            //         fontSize: 13,
            //         fontColor: AppColors.appColor,
            //       ),
            //       searchFieldCursorColor: AppColors.appColor,
            //       searchFieldInputDecoration: InputDecoration(
            //         hintStyle: AppFontStyle.fontStyleW400(
            //           fontSize: 14,
            //           fontColor: AppColors.grey,
            //         ),
            //         hintText: EnumLocale.txtSearchCountryCode.name.tr,
            //       ),
            //     ),
            //     dropdownIcon: Icon(
            //       Icons.arrow_drop_down_outlined,
            //       color: AppColors.black,
            //     ),
            //     keyboardType: TextInputType.number,
            //     showCountryFlag: false,
            //     decoration: InputDecoration(
            //       counterText: '',
            //       hintStyle: AppFontStyle.fontStyleW600(
            //         fontSize: 12,
            //         fontColor: AppColors.white,
            //       ),
            //       enabledBorder: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(12),
            //         borderSide: BorderSide(color: AppColors.black),
            //       ),
            //       border: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(12),
            //         borderSide: BorderSide(color: AppColors.black),
            //       ),
            //       focusedBorder: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(12),
            //         borderSide: BorderSide(color: AppColors.black),
            //       ),
            //       filled: true,
            //       fillColor: AppColors.white,
            //       errorStyle: AppFontStyle.fontStyleW500(
            //         fontSize: 8,
            //         fontColor: AppColors.red,
            //       ),
            //       errorBorder: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(12),
            //         borderSide: BorderSide(color: AppColors.red),
            //       ),
            //       focusedErrorBorder: OutlineInputBorder(
            //         borderRadius: BorderRadius.circular(12),
            //         borderSide: BorderSide(color: AppColors.red),
            //       ),
            //       counterStyle: AppFontStyle.fontStyleW500(
            //         fontSize: 9,
            //         fontColor: AppColors.grey,
            //       ),
            //     ),
            //     initialCountryCode: Database.selectedCountryCode,
            //     onCountryChanged: (value) {
            //       log("message================= ${value.code}");
            //       Database.onSetSelectedCountryCode(value.code);
            //       Database.getDialCode();
            //
            //       log("Database.selectedCountryCode message================= ${Database.selectedCountryCode}");
            //     },
            //     onChanged: (phone) {
            //       logic.dialCode = phone.countryCode; // example: +91
            //       logic.numberController.text = phone.number; // only number part
            //     }),
            child: CustomTextField(
              filled: true,
              // hintText: EnumLocale.txtAddYourNickName.name.tr,
              controller: logic.emailController,
              fillColor: AppColors.white,
              cursorColor: AppColors.black,
              fontColor: AppColors.black,
              fontSize: 15,
              textInputAction: TextInputAction.next,
              // inputFormatters: [UpperCaseTextFormatter()],
            ),
          );
        },
      ),
    ).paddingOnly(top: 20);
  }
}

/// =================== Complete Registration Button =================== ///
class ForgotPasswordButtonView extends StatelessWidget {
  const ForgotPasswordButtonView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ForgotPasswordController>(
      builder: (logic) {
        return Center(
          child: PrimaryAppButton(
            height: 50,
            onTap: () {
              // Get.toNamed(
              //   AppRoutes.createNewPassScreen,
              //   arguments: logic.emailController.text.trim(),
              // );
              // logic.sendOtp(context);
              logic.onForgotPassword();
            },
            widget: Image.asset(
              AppAsset.arrowUp,
              height: 15,
              width: 15,
            ),
            text: EnumLocale.txtVerify.name.tr,
            textStyle: AppFontStyle.fontStyleW500(fontSize: 16, fontColor: AppColors.white),
          ).paddingOnly(bottom: 15, left: 20, right: 20),
        );
      },
    );
  }
}
