import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/edit_profile_screen/controller/edit_profile_screen_controller.dart';
import 'package:talk_in/ui/user_flow/my_profile_screen/controller/my_profile_screen_controller.dart';
import 'package:talk_in/ui/user_flow/my_profile_screen/widget/my_profile_screen_widget.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/appearance.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/utils.dart';

/// The signed-in user's own profile, top to bottom in the order people use
/// it: who am I (hero + avatar), what is missing (checklist), my coins,
/// shortcuts, look & feel, host promo, account links.
class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.light);
    // Profile edits broadcast on this controller; make sure it exists.
    if (!Get.isRegistered<EditProfileController>()) Get.put(EditProfileController());
    final controller = Get.find<MyProfileScreenController>();

    return Scaffold(
      backgroundColor: BebuTheme.bg,
      body: AuroraBackground(
        intensity: 0.8,
        child: SafeArea(
          child: Column(
            children: [
              const ProfileHeaderBar(),
              Expanded(
                child: RefreshIndicator(
                  color: BebuTheme.pink,
                  backgroundColor: BebuTheme.surface,
                  onRefresh: controller.refreshProfile,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
                    child: Column(
                      children: [
                        const ProfileHero(),
                        const SizedBox(height: 20),
                        const ProfileCompleteness(),
                        const ProfileWalletCard(),
                        const SizedBox(height: 22),
                        const ProfileQuickActions(),
                        const SizedBox(height: 22),
                        if (Appearance.canChoose) ...const [ProfileAppearanceSection(), SizedBox(height: 22)],
                        if (Database.settingApiModel?.data?.allowBecomeHostOption == true) ...const [ProfileHostBanner(), SizedBox(height: 22)],
                        const ProfileLinks(),
                        const ProfileFooter(),
                      ],
                    ),
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
