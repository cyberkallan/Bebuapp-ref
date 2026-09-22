import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/user_notification/widget/user_notification_widget.dart';
import 'package:talk_in/utils/app_color.dart';

class UserNotificationScreen extends StatelessWidget {
  const UserNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: const UserNotificationAppBar(),
      ),
      backgroundColor: AppColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserNotificationView(),
        ],
      ).paddingOnly(left: 16, right: 16, top: 20),
    );
  }
}
