import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/host_flow/host_notification/widget/host_notification_widget.dart';
import 'package:talk_in/utils/app_color.dart';

class HostNotificationScreen extends StatelessWidget {
  const HostNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: const HostNotificationAppBar(),
      ),
      backgroundColor: AppColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HostNotificationView(),
        ],
      ).paddingOnly(left: 16, right: 16, top: 20),
    );
  }
}
