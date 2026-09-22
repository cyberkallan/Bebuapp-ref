import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:talk_in/custom/app_bar/custom_app_bar.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/ui/user_flow/verify_otp_screen/controller/verify_otp_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

/// =================== Complete Registration App Bar =================== ///
class VerifyOtpAppBarView extends StatelessWidget {
  const VerifyOtpAppBarView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: EnumLocale.txtEnterOtp.name.tr,
      showLeadingIcon: true,
    );
  }
}

/// =================== Description =================== ///
class VerifyOtpDescriptionView extends StatelessWidget {
  const VerifyOtpDescriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          EnumLocale.txtEnterOtpWithRegisterNumber.name.tr,
          // textAlign: TextAlign.center,
          style: AppFontStyle.fontStyleW800(
            fontSize: 30,
            fontColor: AppColors.appColor,
          ),
        ).paddingOnly(bottom: 6),
        Text(
          EnumLocale.txtVerifyOtpDescription.name.tr, // textAlign: TextAlign.center,
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
class VerifyOtpView extends StatelessWidget {
  const VerifyOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VerifyOtpController>(
      id: Constant.idResendOtp,
      builder: (logic) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              EnumLocale.txtEnterOtp.name.tr,
              style: AppFontStyle.fontStyleW500(fontSize: 13, fontColor: AppColors.black),
            ).paddingOnly(top: 36),
            Pinput(
              cursor: Container(
                width: 1,
                height: 15,
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              length: 6,
              defaultPinTheme: PinTheme(
                width: 56,
                height: 56,
                textStyle: AppFontStyle.fontStyleW700(
                  fontSize: 20,
                  fontColor: AppColors.black,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.black),
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              pinAnimationType: PinAnimationType.fade,
              controller: logic.otpController,
              focusedPinTheme: PinTheme(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.black,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ).paddingOnly(top: 17, bottom: 16),
            // if (logic.countdown > 0)
            Text(
              logic.formattedCountdown,
              style: AppFontStyle.fontStyleW500(
                fontSize: 13,
                fontColor: AppColors.otpScreenGrey,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// =================== Complete Registration Resend OTP =================== ///
class VerifyOtpResendOTPView extends StatelessWidget {
  const VerifyOtpResendOTPView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VerifyOtpController>(
        id: Constant.idResendOtp,
        builder: (logic) {
          final isCountdownActive = logic.countdown > 0;

          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    EnumLocale.txtYouHaveNotGetOtp.name.tr,
                    textAlign: TextAlign.center,
                    style: AppFontStyle.fontStyleW500(
                      fontSize: 13,
                      fontColor: AppColors.otpScreenGrey,
                    ),
                  ).paddingOnly(top: 12, right: 3),
                  if (!isCountdownActive)
                    InkWell(
                      onTap: () {
                        logic.onResendOtpClick(context);
                      },
                      overlayColor: WidgetStatePropertyAll(AppColors.transparent),
                      child: Text(
                        EnumLocale.txtResendOtp.name.tr,
                        textAlign: TextAlign.center,
                        style: AppFontStyle.fontStyleW700(
                          fontSize: 13,
                          fontColor: AppColors.black,
                          textDecoration: TextDecoration.underline,
                          decorationColor: AppColors.black,
                        ),
                      ).paddingOnly(top: 12),
                    ),
                  if (isCountdownActive)
                    InkWell(
                      onTap: () {},
                      overlayColor: WidgetStatePropertyAll(AppColors.transparent),
                      child: Text(
                        EnumLocale.txtResendOtp.name.tr,
                        textAlign: TextAlign.center,
                        style: AppFontStyle.fontStyleW700(
                          fontSize: 13,
                          fontColor: AppColors.grey,
                          textDecoration: TextDecoration.underline,
                          decorationColor: AppColors.grey,
                        ),
                      ),
                    ),
                ],
              ).paddingOnly(top: 18),
            ],
          );
        });
  }
}

/// =================== Complete Registration Button =================== ///
class VerifyOtpButtonView extends StatelessWidget {
  const VerifyOtpButtonView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VerifyOtpController>(
      id: Constant.idVerifyOtp,
      builder: (logic) {
        return Center(
          child: PrimaryAppButton(
            height: 50,
            // width: Get.width * 0.75,
            onTap: () => logic.verifyOtp(),

            widget: Image.asset(
              AppAsset.arrowUp,
              height: 15,
              width: 15,
            ),
            text: EnumLocale.txtSubmit.name.tr,
            textStyle: AppFontStyle.fontStyleW500(fontSize: 16, fontColor: AppColors.white),
          ).paddingOnly(bottom: 15, left: 20, right: 20),
        );
      },
    );
  }
}
