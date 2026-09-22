import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_background/app_background.dart';
import 'package:talk_in/custom/progress_indicator/progress_dialog.dart';
import 'package:talk_in/ui/user_flow/verify_otp_screen/controller/verify_otp_controller.dart';
import 'package:talk_in/ui/user_flow/verify_otp_screen/widget/verify_otp_widget.dart';
import 'package:talk_in/utils/constant.dart';

class VerifyOtpScreen extends StatelessWidget {
  const VerifyOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VerifyOtpController>(
      id: Constant.idLoginOrSignUp,
      builder: (logic) {
        return ProgressDialog(
          inAsyncCall: logic.isLoading,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            // backgroundColor: AppColors.lightPurple,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: const VerifyOtpAppBarView(),
            ),
            body: AppBackground(
              // decoration: BoxDecoration(
              //   gradient: LinearGradient(
              //     // stops: [0.2, 0.4, 0.5, 0],
              //     end: Alignment.bottomCenter,
              //     begin: Alignment.topCenter,
              //     colors: [
              //       // AppColors.red,
              //       // AppColors.green,
              //       // AppColors.chatPink,
              //       // AppColors.chatPink,
              //       // AppColors.blue,
              //       // AppColors.blue,
              //
              //       // Color(0xffF1EDFF).withValues(alpha: 0.4),
              //       Color(0xffF4F6FF).withValues(alpha: 0.5),
              //       Color(0xffF7FAFF),
              //       Color(0xffFFFFFF),
              //       Color(0xffFFFFFF),
              //       Color(0xffFFFFFF),
              //     ],
              //   ),
              // ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VerifyOtpDescriptionView(),
                  VerifyOtpView(),
                  VerifyOtpResendOTPView(),
                  Spacer(),
                  VerifyOtpButtonView(),
                  Spacer(),
                ],
              ).paddingOnly(left: 16, right: 16, top: 18),
            ),
          ),
        );
      },
    );
  }
}
