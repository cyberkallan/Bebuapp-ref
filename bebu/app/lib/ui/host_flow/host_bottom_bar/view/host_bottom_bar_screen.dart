import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/host_flow/host_bottom_bar/controller/host_bottom_bar_controller.dart';
import 'package:talk_in/ui/host_flow/host_bottom_bar/widget/host_bottom_bar_widget.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';

class HostBottomBarScreen extends StatelessWidget {
  const HostBottomBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HostBottomBarController>(
      id: Constant.idBottomBar,
      builder: (logic) {
        return Scaffold(
          backgroundColor: AppColors.white,
          bottomNavigationBar: const HostBottomBarView(),
          body: logic.pages[logic.selectIndex],
        );
      },
    );
  }
}
