import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/dialog/delete_account_dialog.dart';
import 'package:talk_in/custom/dialog/logout_dialog.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/my_profile_screen/widget/my_profile_screen_widget.dart';
import 'package:talk_in/ui/user_flow/setting_screen/controller/setting_controller.dart';
import 'package:talk_in/custom/motion/sfx.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';

class SettingHeaderBar extends StatelessWidget {
  const SettingHeaderBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          GlassIconButton(icon: Icons.arrow_back_rounded, size: 42, color: BebuTheme.surface, blur: false, onTap: Get.back, tooltip: 'Back'),
          const Spacer(),
          Text(EnumLocale.txtSettings.name.tr, style: BebuTheme.title(size: 18)),
          const Spacer(),
          const SizedBox(width: 42),
        ],
      ),
    );
  }
}

/// Preferences, then the account-level actions kept apart at the bottom.
class SettingView extends StatelessWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingController>(
      builder: (controller) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeSlideIn(
            child: ProfileSection(
              title: 'Preferences',
              child: Column(
                children: [
                  _SwitchRow(
                    icon: Icons.notifications_active_outlined,
                    color: BebuTheme.amber,
                    title: EnumLocale.txtNotification.name.tr,
                    subtitle: 'Calls, messages and offers',
                    value: controller.isShowNotification,
                    onChanged: controller.onSwitchNotification,
                  ),
                  if (BebuTheme.chatSounds)
                    _SwitchRow(
                      icon: Icons.music_note_rounded,
                      color: BebuTheme.green,
                      title: 'Conversation tones',
                      subtitle: 'Sounds for sent and received messages',
                      value: Database.chatTones,
                      onChanged: (v) async {
                        await Database.onSetChatTones(v);
                        controller.update();
                        if (v) Sfx.messageReceived();
                      },
                    ),
                  ProfileRow(
                    icon: Icons.translate_rounded,
                    color: BebuTheme.blue,
                    title: EnumLocale.txtAPPLanguage.name.tr,
                    subtitle: 'Choose the language bebu speaks to you in',
                    onTap: () => Get.toNamed(AppRoutes.appLanguageScreen),
                    last: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          FadeSlideIn(
            delayMs: 80,
            child: ProfileSection(
              title: 'Account',
              child: Column(
                children: [
                  ProfileRow(
                    icon: Icons.logout_rounded,
                    color: BebuTheme.violet,
                    title: EnumLocale.txtLogoutApp.name.tr,
                    subtitle: 'You can sign back in any time',
                    onTap: () => _dialog(const LogoutDialog()),
                  ),
                  ProfileRow(
                    icon: Icons.delete_forever_outlined,
                    color: BebuTheme.red,
                    title: EnumLocale.txtDeleteAccount.name.tr,
                    subtitle: 'Removes your profile, coins and history',
                    onTap: () => _dialog(DeleteAccountDialog(onTap: controller.onDeleteAccount)),
                    last: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _dialog(Widget child) {
    Get.dialog(
      barrierColor: Colors.black.withValues(alpha: 0.7),
      Dialog(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, surfaceTintColor: Colors.transparent, elevation: 0, child: child),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({required this.icon, required this.color, required this.title, required this.subtitle, required this.value, required this.onChanged});
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(color: BebuTheme.surface, borderRadius: BorderRadius.circular(BebuTheme.radiusMd), border: Border.all(color: BebuTheme.border)),
      child: Row(
        children: [
          Container(width: 38, height: 38, decoration: BoxDecoration(borderRadius: BorderRadius.circular(BebuTheme.radiusSm), color: color.withValues(alpha: BebuTheme.isLight ? 0.14 : 0.18)), child: Icon(icon, size: 19, color: color)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: BebuTheme.label(size: 14)),
                const SizedBox(height: 2),
                Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: BebuTheme.body(size: 11.5, color: BebuTheme.textFaint)),
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged, activeTrackColor: BebuTheme.pink, thumbColor: const WidgetStatePropertyAll(Colors.white)),
        ],
      ),
    );
  }
}
