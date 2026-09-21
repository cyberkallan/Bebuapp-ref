import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/host_flow/host_app_language_screen/widget/host_app_language_screen_widget.dart';
import 'package:talk_in/utils/app_color.dart';

class HostAppLanguageScreen extends StatelessWidget {
  const HostAppLanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        // backgroundColor: Colors.red,
        automaticallyImplyLeading: false,
        flexibleSpace: const HostAppLanguageScreenAppBar(),
      ),
      body: Column(
        children: [
          Expanded(child: HostAppLanguageScreenView().paddingOnly(top: 20)),
        ],
      ).paddingSymmetric(horizontal: 18),
    );
  }
}
