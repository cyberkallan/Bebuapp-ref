import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/edit_profile_screen/controller/edit_profile_screen_controller.dart';
import 'package:talk_in/ui/user_flow/my_profile_screen/widget/my_profile_screen_widget.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/appearance.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/utils.dart';

/// The signed-in user's own profile: hero, wallet, appearance, shortcuts,
/// host promo and the "more" links. Themed (dark / light) via [BebuTheme].
class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.light);
    // Profile edits broadcast on this controller; make sure it exists.
    Get.put(EditProfileController());

    return Scaffold(
      backgroundColor: BebuTheme.bg,
      body: AuroraBackground(
        intensity: 0.8,
        child: SafeArea(
          child: Column(
            children: [
              const ProfileHeaderBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
                  child: Column(
                    children: [
                      const ProfileHero(),
                      const SizedBox(height: 24),
                      const ProfileWalletCard(),
                      const SizedBox(height: 22),
                      if (Appearance.canChoose) ...const [ProfileAppearanceSection(), SizedBox(height: 22)],
                      const ProfileQuickActions(),
                      const SizedBox(height: 22),
                      if (Database.settingApiModel?.data?.allowBecomeHostOption == true) ...const [ProfileHostBanner(), SizedBox(height: 22)],
                      const ProfileLinks(),
                      const ProfileFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
