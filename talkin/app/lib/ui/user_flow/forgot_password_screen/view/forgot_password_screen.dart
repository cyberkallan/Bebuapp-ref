import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_background/app_background.dart';
import 'package:talk_in/ui/user_flow/forgot_password_screen/widget/forgot_password_widget.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: const ForgotPasswordAppBar(),
      ),
      body: AppBackground(
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ForgotPasswordDescriptionView(),
            ForgotPasswordView(),
            Spacer(),
            ForgotPasswordButtonView(),
            Spacer(),
          ],
        ).paddingOnly(left: 18, right: 18, top: 18),
      ),
    );
  }
}
