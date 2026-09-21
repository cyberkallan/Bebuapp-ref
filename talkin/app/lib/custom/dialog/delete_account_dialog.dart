import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/dialog/bebu_dialog.dart';
import 'package:talk_in/utils/enums.dart';

class DeleteAccountDialog extends StatelessWidget {
  final VoidCallback? onTap;
  const DeleteAccountDialog({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return BebuDialog(
      icon: Icons.delete_forever_rounded,
      tone: BebuDialogTone.danger,
      title: EnumLocale.txtDeleteAccount.name.tr,
      body: EnumLocale.desWantDeleteAccount.name.tr,
      primaryLabel: EnumLocale.txtDeleteAccount.name.tr,
      onPrimary: () => onTap?.call(),
      secondaryLabel: EnumLocale.txtCancel.name.tr,
      onSecondary: Get.back,
    );
  }
}
