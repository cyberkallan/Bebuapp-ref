import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/dialog/bebu_dialog.dart';
import 'package:talk_in/utils/enums.dart';

class NotificationClearDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  const NotificationClearDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return BebuDialog(
      icon: Icons.notifications_off_rounded,
      tone: BebuDialogTone.danger,
      title: 'Clear notifications?',
      body: EnumLocale.txtSureClearNotification.name.tr,
      primaryLabel: EnumLocale.txtSure.name.tr,
      onPrimary: () {
        Get.back();
        onConfirm();
      },
      secondaryLabel: EnumLocale.txtCancel.name.tr,
      onSecondary: Get.back,
    );
  }
}

class HostNotificationClearDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  const HostNotificationClearDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) => NotificationClearDialog(onConfirm: onConfirm);
}
