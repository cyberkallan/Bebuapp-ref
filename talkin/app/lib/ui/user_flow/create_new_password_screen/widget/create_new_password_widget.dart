import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_bar/custom_app_bar.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/custom/text_field/custom_text_field.dart';
import 'package:talk_in/custom/title/custom_title.dart';
import 'package:talk_in/ui/user_flow/create_new_password_screen/controller/create_new_passwoed_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class CreateNewPasswordAppBar extends StatelessWidget {
  const CreateNewPasswordAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(120),
      child: CustomAppBar(
        title: EnumLocale.txtCreatePassword.name.tr,
        showLeadingIcon: true,
      ),
    );
  }
}

class CreateNewPasswordDescriptionView extends StatelessWidget {
  const CreateNewPasswordDescriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateNewPasswordController>(
      builder: (logic) {
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
              EnumLocale.txtMobileLoginDescription.name.tr, // textAlign: TextAlign.center,
              style: AppFontStyle.fontStyleW400(
                height: 1.9,
                fontSize: 12,
                fontColor: AppColors.grey,
              ),
            ).paddingOnly(right: 30, bottom: 36),
            CustomTitle(
              title: EnumLocale.txtPassword.name.tr,
              method: CustomTextField(
                filled: true,
                controller: logic.passwordCnt,
                fillColor: AppColors.white,
                cursorColor: AppColors.black,
                fontColor: AppColors.black,
                fontSize: 15,
                textInputAction: TextInputAction.next,
                maxLines: 1,
                obscureText: logic.isObscure,
                suffixIcon: logic.isObscure
                    ? InkWell(
                        onTap: () {
                          logic.onClickObscure();
                        },
                        child: Image.asset(
                          AppAsset.icEyeCancel,
                          height: 10,
                          width: 10,
                        ).paddingAll(12),
                      )
                    : InkWell(
                        onTap: () {
                          logic.onClickObscure();
                        },
                        child: Image.asset(
                          AppAsset.icEye,
                          height: 10,
                          width: 10,
                        ).paddingAll(12),
                      ),
                validator: logic.validatePassword,
              ),
            ).paddingOnly(bottom: 30),
            CustomTitle(
              title: EnumLocale.txtConfirmPassword.name.tr,
              method: CustomTextField(
                filled: true,
                controller: logic.confirmPasswordCnt,
                fillColor: AppColors.white,
                cursorColor: AppColors.black,
                fontColor: AppColors.black,
                fontSize: 15,
                textInputAction: TextInputAction.next,
                maxLines: 1,
                obscureText: logic.isObscure1,
                suffixIcon: logic.isObscure1
                    ? InkWell(
                        onTap: () {
                          logic.onClickObscure1();
                        },
                        child: Image.asset(
                          AppAsset.icEyeCancel,
                          height: 10,
                          width: 10,
                        ).paddingAll(12),
                      )
                    : InkWell(
                        onTap: () {
                          logic.onClickObscure1();
                        },
                        child: Image.asset(
                          AppAsset.icEye,
                          height: 10,
                          width: 10,
                        ).paddingAll(12),
                      ),
                validator: logic.validateConfirmPassword,
              ),
            ).paddingOnly(bottom: 43),
          ],
        );
      },
    );
  }
}

class CreateNewPasswordButtonView extends StatelessWidget {
  const CreateNewPasswordButtonView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateNewPasswordController>(
      builder: (logic) {
        return Form(
          key: logic.formKey,
          child: Center(
            child: PrimaryAppButton(
              height: 50,
              onTap: () {
                logic.handleForgotPassword();
                // logic.sendOtp(context);
              },
              widget: Image.asset(
                AppAsset.arrowUp,
                height: 15,
                width: 15,
              ),
              text: EnumLocale.txtSubmit.name.tr,
              textStyle: AppFontStyle.fontStyleW500(fontSize: 16, fontColor: AppColors.white),
            ).paddingOnly(bottom: 15, left: 20, right: 20),
          ),
        );
      },
    );
  }
}
