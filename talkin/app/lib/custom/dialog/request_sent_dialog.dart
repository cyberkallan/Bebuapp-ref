import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/dialog/bebu_dialog.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/utils/enums.dart';

class RequestSentDialog extends StatelessWidget {
  const RequestSentDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BebuDialog(
      icon: Icons.check_rounded,
      tone: BebuDialogTone.success,
      title: EnumLocale.txtYourHostRequestSentSuccessfully.name.tr,
      body: EnumLocale.txtYourHostRequestSentSuccessfullyDescription.name.tr,
      primaryLabel: EnumLocale.txtViewRequest.name.tr,
      onPrimary: () => Get.offAllNamed(AppRoutes.hostRequestSentSuccessfullyScreen),
    );
  }
}
