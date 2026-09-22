import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/dialog/bebu_dialog.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/avatar_studio/controller/avatar_studio_controller.dart';
import 'package:talk_in/ui/user_flow/edit_profile_screen/controller/edit_profile_screen_controller.dart';
import 'package:talk_in/ui/user_flow/edit_profile_screen/widget/edit_profile_screen_widget.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/utils.dart';

/// Edit profile: photo, basics, personal details, contact. Fields reload on
/// open; nothing is persisted until Save.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final EditProfileController c = Get.isRegistered<EditProfileController>() ? Get.find<EditProfileController>() : Get.put(EditProfileController());

  @override
  void initState() {
    super.initState();
    c.load();
  }

  Future<void> _back() async {
    if (!c.isDirty) {
      Get.back();
      return;
    }
    final save = await Get.dialog<bool>(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: BebuDialog(
          icon: Icons.save_outlined,
          title: 'Save changes?',
          body: 'You edited your profile but have not saved it yet.',
          primaryLabel: 'Save',
          onPrimary: () => Get.back(result: true),
          secondaryLabel: 'Discard',
          onSecondary: () => Get.back(result: false),
        ),
      ),
      barrierColor: Colors.black.withValues(alpha: 0.7),
    );
    if (save == true) {
      await _save();
    } else if (save == false) {
      c.load();
      Get.back();
    }
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    final ok = await c.onSaveProfile();
    if (!mounted) return;
    if (ok) {
      Utils.showToast(context, EnumLocale.txtProfileUpdateSuccessfully.name.tr);
      Get.back(result: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.light);
    final emailLocked = Database.loginType == 1 || Database.loginType == 4;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: BebuTheme.bg,
        resizeToAvoidBottomInset: true,
        body: AuroraBackground(
          intensity: 0.6,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Row(
                    children: [
                      GlassIconButton(icon: Icons.arrow_back_rounded, size: 42, color: BebuTheme.surface, blur: false, onTap: _back, tooltip: 'Back'),
                      const Spacer(),
                      Text(EnumLocale.txtEditProfile.name.tr, style: BebuTheme.title(size: 18)),
                      const Spacer(),
                      const SizedBox(width: 42),
                    ],
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.fromLTRB(20, 14, 20, 120 + bottom),
                      children: [
                        FadeSlideIn(
                          child: EditProfilePhoto(
                            onAvatarStudio: AvatarStudioController.enabledBySettings ? () => Get.toNamed(AppRoutes.avatarStudio) : null,
                          ),
                        ),
                        const SizedBox(height: 24),
                        FadeSlideIn(
                          delayMs: 60,
                          child: EditSection(
                            title: 'Basics',
                            children: [
                              EditField(label: EnumLocale.txtNickName.name.tr, controller: c.nickNameCnt, hint: EnumLocale.txtAddYourNickName.name.tr, icon: Icons.badge_outlined, onChanged: (_) => c.update([EditProfileController.idForm])),
                              EditField(label: EnumLocale.txtFullName.name.tr, controller: c.nameCnt, hint: EnumLocale.txtAddYOurFullName.name.tr, icon: Icons.person_outline_rounded, onChanged: (_) => c.update([EditProfileController.idForm])),
                              EditField(label: 'About you', controller: c.bioCnt, hint: 'A line or two people see on your profile', icon: Icons.short_text_rounded, keyboardType: TextInputType.multiline, maxLines: 3, maxLength: 160, last: true, onChanged: (_) => c.update([EditProfileController.idForm])),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        FadeSlideIn(
                          delayMs: 100,
                          child: EditSection(
                            title: 'Personal',
                            children: [
                              const EditGenderRow(),
                              Divider(height: 1, color: BebuTheme.border),
                              GetBuilder<EditProfileController>(
                                id: EditProfileController.idForm,
                                builder: (_) => EditField(
                                  label: EnumLocale.txtDateOfBirth.name.tr,
                                  controller: c.dateController,
                                  hint: 'DD / MM / YYYY',
                                  icon: Icons.cake_outlined,
                                  readOnly: true,
                                  onTap: () => c.selectDate(context),
                                  last: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        FadeSlideIn(
                          delayMs: 140,
                          child: EditSection(
                            title: 'Contact',
                            children: [
                              EditField(label: EnumLocale.txtEnterMail.name.tr, controller: c.emailCnt, hint: EnumLocale.txtEnterYourMail.name.tr, icon: Icons.alternate_email_rounded, readOnly: emailLocked, keyboardType: TextInputType.emailAddress),
                              const EditCountryRow(),
                              const EditPhoneRow(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text('Your phone and email are never shown to other users.', textAlign: TextAlign.center, style: BebuTheme.body(size: 11.5, color: BebuTheme.textFaint)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomSheet: GetBuilder<EditProfileController>(
          id: EditProfileController.idForm,
          builder: (_) => Container(
            padding: EdgeInsets.fromLTRB(16, 12, 16, bottom + 12),
            decoration: BoxDecoration(color: BebuTheme.bg.withValues(alpha: 0.94), border: Border(top: BorderSide(color: BebuTheme.border))),
            child: GradientButton(
              label: c.saving ? 'Saving…' : EnumLocale.txtSaveProfile.name.tr,
              icon: Icons.check_rounded,
              height: 52,
              loading: c.saving,
              onTap: c.isDirty && !c.saving ? _save : null,
            ),
          ),
        ),
      ),
    );
  }
}
