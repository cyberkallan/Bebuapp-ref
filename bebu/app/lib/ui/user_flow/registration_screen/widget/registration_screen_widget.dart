import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_bar/custom_app_bar.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/custom/text_field/custom_text_field.dart';
import 'package:talk_in/custom/title/custom_title.dart';
import 'package:talk_in/custom/upper_case_formatter/upper_case_formatter_class.dart';
import 'package:talk_in/ui/user_flow/registration_screen/controller/registration_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

/// =================== App Bar =================== ///
class RegistrationAppBarView extends StatelessWidget {
  const RegistrationAppBarView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: EnumLocale.txtRegister.name.tr,
      showLeadingIcon: true,
    );
  }
}

/// =================== Add Information(TextFormField) =================== ///
class RegistrationAddInfoView extends StatelessWidget {
  const RegistrationAddInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RegistrationController>(
      builder: (logic) {
        return Form(
          key: logic.formKey,
          child: Column(
            children: [
              CustomTitle(
                title: EnumLocale.txtEnterName.name.tr,
                method: CustomTextField(
                  filled: true,
                  controller: logic.nameController,
                  fillColor: AppColors.white,
                  cursorColor: AppColors.black,
                  fontColor: AppColors.black,
                  fontSize: 15,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [UpperCaseTextFormatter()],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return EnumLocale.desEnterFullName.name.tr;
                    }
                    return null;
                  },
                ),
              ).paddingOnly(bottom: 30),
              CustomTitle(
                title: EnumLocale.txtEnterMail.name.tr,
                method: CustomTextField(
                  filled: true,
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
                    }

                    return null;
                  },
                ),
              ).paddingOnly(bottom: 30),
              CustomTitle(
                title: EnumLocale.txtPassword.name.tr,
                method: CustomTextField(
                    filled: true,
                    controller: logic.passwordController,
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return EnumLocale.desEnterPassword.name.tr;
                      } else if (value.length < 8) {
                        return 'Password must be at least 8 characters long';
                      } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
                        return 'Include at least one uppercase letter';
                      } else if (!RegExp(r'[a-z]').hasMatch(value)) {
                        return 'Include at least one lowercase letter';
                      } else if (!RegExp(r'\d').hasMatch(value)) {
                        return 'Include at least one number';
                      } else if (!RegExp(r'[!@#\$&*~%^()_+\-=\[\]{};:"\\|,.<>\/?]').hasMatch(value)) {
                        return 'Include at least one special character';
                      }
                      return null;
                    }),
              ).paddingOnly(bottom: 30),
              CustomTitle(
                title: EnumLocale.txtConfirmPassword.name.tr,
                method: CustomTextField(
                  filled: true,
                  controller: logic.confirmPassController,
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return EnumLocale.desReEnterPassword.name.tr;
                    } else if (value != logic.passwordController.text) {
                      return EnumLocale.desPasswordNotMatch.name.tr;
                    }
                    return null;
                  },
                ),
              ).paddingOnly(bottom: 43),
              submitButton(context).paddingOnly(bottom: 33),
            ],
          ),
        );
      },
    );
  }

  /// =================== submit button =================== ///

  GetBuilder<GetxController> submitButton(BuildContext context) {
    return GetBuilder<RegistrationController>(
      builder: (controller) {
        return Center(
          child: PrimaryAppButton(
            // onTap: () {
            //   controller.registerWithEmail();
            //   controller.signUpWithEmailPassword();
            // },
            onTap: () async {
              FocusScope.of(context).unfocus();

              if (controller.validateRegistration()) {
                await controller.signUpWithEmailPassword();
              }
            },
            color: AppColors.appColor,
            height: 50,
            // width: Get.width * 0.75,
            text: EnumLocale.txtSubmit.name.tr,
            widget: Image.asset(
              AppAsset.arrowUp,
              height: 15,
              width: 15,
            ),
            textStyle: AppFontStyle.fontStyleW500(fontSize: 16, fontColor: AppColors.white),
          ).paddingSymmetric(horizontal: 20),
        );
      },
    );
  }
}
