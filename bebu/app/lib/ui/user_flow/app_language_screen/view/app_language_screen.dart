import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/app_language_screen/widget/app_language_screen_widget.dart';
import 'package:talk_in/utils/app_color.dart';

class AppLanguageScreen extends StatelessWidget {
  const AppLanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        // backgroundColor: Colors.red,
        automaticallyImplyLeading: false,
        flexibleSpace: const AppLanguageScreenAppBar(),
      ),
      body: Column(
        children: [
          Expanded(child: AppLanguageScreenView().paddingOnly(top: 20)),
        ],
      ).paddingSymmetric(horizontal: 18),
    );
  }
}
