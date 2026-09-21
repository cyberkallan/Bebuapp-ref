import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/dialog/bebu_dialog.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/enums.dart';

class ExitAppDialog extends StatelessWidget {
  const ExitAppDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BebuDialog(
      icon: Icons.waving_hand_rounded,
      title: EnumLocale.txtExitApp.name.tr,
      body: EnumLocale.desWantExitApp.name.tr,
      primaryLabel: EnumLocale.txtExitApp.name.tr,
      onPrimary: () => exit(0),
      secondaryLabel: EnumLocale.txtCancel.name.tr,
      onSecondary: Get.back,
    );
  }
}

/// Shown from the splash screen when the admin has taken the app offline.
class AppNotLiveDialog extends StatelessWidget {
  const AppNotLiveDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BebuDialog(
      icon: Icons.construction_rounded,
      illustration: Image.asset(AppAsset.underMaintenanceImage, height: 150),
      title: 'Back soon',
      body: 'Your app is under maintenance.',
      primaryLabel: EnumLocale.txtExitApp.name.tr,
      onPrimary: () => exit(0),
    );
  }
}
