import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/dialog/bebu_dialog.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BebuDialog(
      icon: Icons.logout_rounded,
      tone: BebuDialogTone.danger,
      title: EnumLocale.txtLogout.name.tr,
      body: EnumLocale.txtDesLogout.name.tr,
      primaryLabel: EnumLocale.txtLogout.name.tr,
      onPrimary: () {
        Database.onLogOut();
        Get.offAllNamed(AppRoutes.main);
      },
      secondaryLabel: EnumLocale.txtCancel.name.tr,
      onSecondary: Get.back,
    );
  }
}
