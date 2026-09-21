import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/host_verification_screen/widget/host_verification_widget.dart';
import 'package:talk_in/utils/app_color.dart';

class HostVerificationScreen extends StatelessWidget {
  const HostVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: HostVerificationBottomButton(),
      backgroundColor: AppColors.lightPurple,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: const HostVerificationAppBar(),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
            currentFocus.focusedChild?.unfocus();
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              HostVerificationUploadImageView().paddingOnly(top: 10),
              HostVerificationFillFormView(),
            ],
          ),
        ),
      ),
    );
  }
}
