import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/become_host_screen/controller/become_host_screen_controller.dart';
import 'package:talk_in/ui/user_flow/host_request_sent_successfully_screen/controller/host_request_sent_successfully_controller.dart';
import 'package:talk_in/ui/user_flow/host_request_sent_successfully_screen/widget/host_request_successfully_widget.dart';
import 'package:talk_in/utils/database.dart';

class HostRequestSentSuccessfullyScreen extends GetView<HostRequestSentSuccessfullyController> {
  const HostRequestSentSuccessfullyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: GetBuilder<BecomeHostScreenController>(
        builder: (controller) {
          return BackHomeButton(
            tryAgainOnTap: () {
              Get.toNamed(AppRoutes.hostVerificationScreen);
            },
            onTap: () {
              if (controller.listenersRequestCheckModel?.data?.status == 2) {
                Database.onSetIsListeners(true);
                log("Database.isListeners :: ${Database.isListeners}");
                Get.offAllNamed(AppRoutes.splashScreenPage);
              } else {
                Get.toNamed(AppRoutes.bottomBar);
              }
            },
          );
        },
      ),
      body: GetBuilder<BecomeHostScreenController>(builder: (controller) {
        return RefreshIndicator(
          onRefresh: () => controller.onRefresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                TopView(),
                InfoView(),
              ],
            ),
          ),
        );
      }),
    );
  }
}
