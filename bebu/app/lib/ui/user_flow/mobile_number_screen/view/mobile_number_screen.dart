import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_background/app_background.dart';
import 'package:talk_in/ui/user_flow/mobile_number_screen/widget/mobile_number_widget.dart';

class MobileNumberScreen extends StatelessWidget {
  const MobileNumberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.lightPurple,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: const MobileNumberAppBarView(),
      ),
      body: AppBackground(
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MobileNumberDescriptionView(),
            MobileNumberOTPView(),
            Spacer(),
            MobileNumberButtonView(),
            Spacer(),
          ],
        ).paddingOnly(left: 18, right: 18, top: 18),
      ),
    );
  }
}
