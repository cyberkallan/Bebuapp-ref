import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/dialog/bebu_dialog.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/utils/enums.dart';

class AppRestartDialog extends StatelessWidget {
  const AppRestartDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BebuDialog(
      icon: Icons.restart_alt_rounded,
      title: EnumLocale.txtAppRestart.name.tr,
      body: 'Restart to apply your changes. It only takes a second.',
      primaryLabel: EnumLocale.txtAppRestart.name.tr,
      onPrimary: () => Get.offAllNamed(AppRoutes.splashScreenPage),
    );
  }
}
