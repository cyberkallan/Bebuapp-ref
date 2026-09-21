import 'package:flutter/material.dart';
import 'package:talk_in/custom/app_background/app_background.dart';
import 'package:talk_in/ui/user_flow/registration_screen/widget/registration_screen_widget.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.lightPurple,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: const RegistrationAppBarView(),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
          child: SingleChildScrollView(
            child: Column(
              children: [
                RegistrationAddInfoView(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
