import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_background/app_background.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/custom/text_field/custom_text_field.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/main_screen/controller/main_screen_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:talk_in/utils/utils.dart';

class MainScreenView extends StatelessWidget {
  const MainScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainScreenController>(
      builder: (controller) {
        return AppBackground(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text("bebu", style: AppFontStyle.fontStyleKaushanW400(fontSize: 62, fontColor: AppColors.black)),
                ).paddingOnly(bottom: Get.height * 0.035, top: Get.height * 0.06),
                Text(
                  EnumLocale.txtEnterYourMail.name.tr,
                  style: AppFontStyle.fontStyleW600(fontSize: 13, fontColor: AppColors.black),
                ).paddingOnly(bottom: 5),
                CustomTextField(
                  controller: controller.emailController,
                  filled: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return EnumLocale.desEnterEmail.name.tr;
                    } else if (!controller.isEmailValid(value)) {
                      return EnumLocale.desEnterValidEmailAddress.name.tr;
                    }

                    return null;
                  },
                  hintText: 'Email address',
                ).paddingOnly(bottom: Get.height * 0.025),
                Text(
                  EnumLocale.txtEnterPassword.name.tr,
                  style: AppFontStyle.fontStyleW600(fontSize: 13, fontColor: AppColors.black),
                ).paddingOnly(bottom: 5),
                CustomTextField(
                  controller: controller.passwordController,
                  maxLines: 1,
                  obscureText: controller.isObscure,
                  suffixIcon: controller.isObscure
                      ? InkWell(
                          onTap: () {
                            controller.onClickObscure();
                          },
                          child: Image.asset(AppAsset.icEyeCancel, height: 10, width: 10).paddingAll(12),
                        )
                      : InkWell(
                          onTap: () {
                            controller.onClickObscure();
                          },
                          child: Image.asset(AppAsset.icEye, height: 10, width: 10).paddingAll(12),
                        ),
                  filled: true,
                  hintText: 'Password',
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
                    } else if (!RegExp(r'[!@#\$&*~%^()-_+=<>?]').hasMatch(value)) {
                      return 'Include at least one special character';
                    }
                    return null;
                  },
                ),
                InkWell(
                  onTap: () {
                    Get.toNamed(AppRoutes.forgotPasswordScreen, arguments: {'email': controller.emailController.text.trim()});
                  },
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      EnumLocale.forgotPassword.name.tr,
                      style: AppFontStyle.fontStyleW500(
                        textDecoration: TextDecoration.underline,
                        decorationColor: AppColors.black,
                        fontSize: 13,
                        fontColor: AppColors.black,
                      ),
                    ).paddingOnly(top: 8, bottom: 24),
                  ),
                ),
                Center(
                  child: PrimaryAppButton(
                    onTap: () {
                      if (controller.validateLogin()) {
                        controller.onClickSignIn();
                        // Get.offAllNamed(AppRoutes.bottomBar);
                      }
                    },
                    color: AppColors.purple,
                    height: Get.height * 0.056,
                    width: Get.width * 0.75,
                    text: EnumLocale.txtContinue.name.tr,
                    widget: Image.asset(AppAsset.arrowUp, height: 15, width: 15),
                    textStyle: AppFontStyle.fontStyleW500(fontSize: 16, fontColor: AppColors.white),
                  ),
                ).paddingOnly(bottom: Get.height * 0.031),
                Row(
                  children: [
                    Text(
                      EnumLocale.txtYouHaveNewUser.name.tr,
                      style: AppFontStyle.fontStyleW500(fontSize: 13, fontColor: AppColors.onBoardingTxt),
                    ).paddingOnly(right: 2),
                    InkWell(
                      onTap: () {
                        Get.toNamed(AppRoutes.register);
                      },
                      child: Text(
                        EnumLocale.txtGetRegister.name.tr,
                        style: AppFontStyle.fontStyleW700(
                          textDecoration: TextDecoration.underline,
                          decorationColor: AppColors.black,
                          fontSize: 13,
                          fontColor: AppColors.black,
                        ),
                      ),
                    ),
                  ],
                ).paddingOnly(bottom: Get.height * 0.017),
                Divider(
                  // height: 45,
                  color: AppColors.grey,
                  thickness: 0.7,
                ).paddingOnly(bottom: Get.height * 0.014),
                PrimaryAppButton(
                  onTap: () {
                    controller.onQuickLogin();
                    // Get.offAllNamed(AppRoutes.bottomBar);
                  },
                  borderRadius: 60,
                  color: AppColors.purple,
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(9),
                        decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.white),
                        child: Center(child: Image.asset(AppAsset.quickLoginIcon, color: AppColors.purple, height: 22)),
                      ).paddingAll(4),
                      Spacer(),
                      Text(
                        EnumLocale.txtQuickLogin.name.tr,
                        style: AppFontStyle.fontStyleW600(decorationColor: AppColors.black, fontSize: 16, fontColor: AppColors.white),
                      ).paddingOnly(right: 50),
                      Spacer(),
                    ],
                  ),
                ).paddingOnly(bottom: 10),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (controller.selectedValue != 1) {
                            Utils.showToast(Get.context!, "Please agree to the Privacy Policy to proceed.");
                            return;
                          }
                          Get.toNamed(AppRoutes.mobileLogIn);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(60),
                            border: Border.all(color: AppColors.black),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(7),
                                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.lightGrey),
                                child: Center(child: Image.asset(AppAsset.mobile, height: 25)),
                              ).paddingAll(4),
                              Text(
                                EnumLocale.txtMobileLogin.name.tr,
                                style: AppFontStyle.fontStyleW600(decorationColor: AppColors.black, fontSize: 15, fontColor: AppColors.black),
                              ).paddingOnly(left: 2),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: GetBuilder<MainScreenController>(
                        builder: (controller) {
                          return GestureDetector(
                            onTap: () async {
                              await controller.onGoogleLogin();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(60),
                                color: AppColors.white,
                                border: Border.all(color: AppColors.black),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(7),
                                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.lightGrey),
                                    child: Center(child: Image.asset(AppAsset.googleIcon, height: 25)),
                                  ).paddingAll(4),
                                  Text(
                                    EnumLocale.txtGoogleLogin.name.tr,
                                    style: AppFontStyle.fontStyleW600(decorationColor: AppColors.black, fontSize: 15, fontColor: AppColors.black),
                                  ).paddingOnly(left: 2),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ).paddingOnly(top: Get.height * 0.025),
                GetBuilder<MainScreenController>(
                  id: Constant.radioButton,
                  builder: (controller) {
                    final isSelected = controller.selectedValue == 1;
                    return Container(
                      color: AppColors.transparent,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              controller.toggleValue(1);
                            },
                            child: Container(
                              color: AppColors.transparent,
                              child: Row(
                                children: [
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: isSelected ? AppColors.appColor : AppColors.darkGrey, width: 1),
                                      color: isSelected ? AppColors.appColor : Colors.transparent,
                                    ),
                                    child: isSelected
                                        ? Container(
                                            decoration: BoxDecoration(color: AppColors.appColor, shape: BoxShape.circle),
                                            child: Container(
                                              height: 18,
                                              width: 18,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(color: AppColors.white),
                                                color: AppColors.appColor,
                                              ),
                                            ).paddingAll(0.5),
                                          )
                                        : null,
                                  ).paddingOnly(right: 10, left: 5),
                                  Text(
                                    EnumLocale.txtAgreePrivacyPolicy.name.tr,
                                    style: AppFontStyle.fontStyleW500(decorationColor: AppColors.darkGrey, fontSize: 13, fontColor: AppColors.black),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              controller.onClickPrivacyPolicy();
                            },
                            child: Container(
                              color: AppColors.transparent,
                              child: Text(
                                EnumLocale.txtPrivacyPolicy.name.tr,
                                style: AppFontStyle.fontStyleW500(
                                  decorationColor: AppColors.appColor,
                                  fontSize: 13,
                                  textDecoration: TextDecoration.underline,
                                  fontColor: AppColors.black,
                                ),
                              ).paddingOnly(top: 4, bottom: 4),
                            ),
                          ),
                        ],
                      ).paddingOnly(top: 10, bottom: 6),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
