import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/dialog/bebu_dialog.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/avatar_studio/controller/avatar_studio_controller.dart';
import 'package:talk_in/ui/user_flow/avatar_studio/model/avatar_studio_model.dart';
import 'package:talk_in/ui/user_flow/avatar_studio/widget/avatar_studio_widget.dart';
import 'package:talk_in/ui/user_flow/avatar_studio/widget/photo_avatar_picker.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/utils.dart';

/// Avatar Studio: compose a 3D look (avatar, scene, style, pet, ride, home,
/// sky), try premium items on the stage and unlock them with coins. When the
/// admin has the studio off this screen becomes the photo / preset picker.
class AvatarStudioScreen extends StatefulWidget {
  const AvatarStudioScreen({super.key});

  @override
  State<AvatarStudioScreen> createState() => _AvatarStudioScreenState();
}

class _AvatarStudioScreenState extends State<AvatarStudioScreen> {
  AvatarItem? _celebrating;

  Future<void> _back(AvatarStudioController c) async {
    if (!c.isDirty || c.data == null || !c.data!.settings.enabled) {
      Get.back();
      return;
    }
    final leave = await Get.dialog<bool>(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: BebuDialog(
          icon: Icons.brush_rounded,
          title: 'Save your look?',
          body: 'You changed your avatar but have not saved it yet.',
          primaryLabel: 'Save look',
          onPrimary: () => Get.back(result: false),
          secondaryLabel: 'Discard',
          onSecondary: () => Get.back(result: true),
        ),
      ),
      barrierColor: Colors.black.withValues(alpha: 0.7),
    );
    if (leave == true) {
      Get.back();
    } else if (leave == false) {
      await _save(c);
    }
  }

  Future<void> _unlock(AvatarStudioController c) async {
    final t = c.tryOn;
    if (t == null) return;
    if ((c.data?.coins ?? 0) < t.coins) {
      Get.toNamed(AppRoutes.myWalletScreen);
      return;
    }
    final r = await c.unlockTryOn();
    if (!mounted) return;
    if (r.ok) {
      setState(() => _celebrating = t);
    } else if (r.code == 'INSUFFICIENT_COINS') {
      Utils.showToast(context, 'Not enough coins');
      Get.toNamed(AppRoutes.myWalletScreen);
    } else {
      Utils.showToast(context, r.message.isEmpty ? 'Could not unlock' : r.message);
    }
  }

  Future<void> _save(AvatarStudioController c) async {
    final r = await c.saveLook();
    if (!mounted) return;
    if (r.ok) {
      Utils.showToast(context, 'Your look is live');
      Get.back(result: true);
    } else if (r.code == 'LOCKED') {
      Utils.showToast(context, r.message);
    } else {
      Utils.showToast(context, r.message.isEmpty ? 'Could not save' : r.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.light);
    return GetBuilder<AvatarStudioController>(
      builder: (c) {
        final enabled = c.data?.settings.enabled ?? AvatarStudioController.enabledBySettings;
        return PopScope(
          canPop: !(c.isDirty && enabled && c.data != null),
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _back(c);
          },
          child: Scaffold(
            backgroundColor: BebuTheme.bg,
            body: Stack(
              children: [
                AuroraBackground(
                  intensity: 0.6,
                  child: SafeArea(
                    bottom: false,
                    child: c.loading
                        ? Column(children: [StudioHeader(onBack: Get.back), const Expanded(child: StudioShimmer())])
                        : c.failed || c.data == null
                            ? _Failed(onRetry: c.load)
                            : !enabled
                                ? _PhotoOnly(c: c)
                                : Column(
                                    children: [
                                      StudioHeader(onBack: () => _back(c)),
                                      Expanded(
                                        child: ListView(
                                          physics: const BouncingScrollPhysics(),
                                          padding: const EdgeInsets.only(bottom: 110),
                                          children: [
                                            const SizedBox(height: 4),
                                            StudioStage(height: (MediaQuery.sizeOf(context).height * 0.36).clamp(240.0, 340.0)),
                                            const SizedBox(height: 14),
                                            const StudioTabs(),
                                            const StudioGrid(),
                                            if (AvatarStudioController.photoUploadAllowed)
                                              Center(
                                                child: GhostButton(
                                                  label: 'Use a real photo instead',
                                                  icon: Icons.photo_camera_back_rounded,
                                                  expanded: false,
                                                  height: 44,
                                                  onTap: () => _openPhotoSheet(c),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                  ),
                ),
                if (!c.loading && enabled && c.data != null)
                  Positioned(left: 0, right: 0, bottom: 0, child: StudioActionBar(onUnlock: () => _unlock(c), onSave: () => _save(c))),
                if (_celebrating != null)
                  Positioned.fill(
                    child: UnlockCelebration(item: _celebrating!, bonus: c.lastBonus, onDone: () => setState(() => _celebrating = null)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openPhotoSheet(AvatarStudioController c) {
    final d = c.data!;
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(color: BebuTheme.bg, borderRadius: BorderRadius.vertical(top: Radius.circular(BebuTheme.radiusXl)), border: Border(top: BorderSide(color: BebuTheme.borderStrong))),
        padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.paddingOf(context).bottom + 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: BebuTheme.borderStrong, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 14),
              Text('Profile photo', style: BebuTheme.title(size: 18)),
              const SizedBox(height: 4),
              Text('A real photo replaces your 3D avatar as the picture others see.', textAlign: TextAlign.center, style: BebuTheme.body(size: 12.5, color: BebuTheme.textMuted)),
              const SizedBox(height: 18),
              PhotoAvatarPicker(
                presetsMale: d.presetsMale,
                presetsFemale: d.presetsFemale,
                allowUpload: d.settings.allowPhotoUpload,
                onChanged: () {
                  d.active = false;
                  Get.back();
                  Get.back(result: true);
                },
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

/// Studio disabled by admin: photo upload + the six premade avatars.
class _PhotoOnly extends StatelessWidget {
  const _PhotoOnly({required this.c});
  final AvatarStudioController c;

  @override
  Widget build(BuildContext context) {
    final d = c.data!;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
          child: Row(
            children: [
              GlassIconButton(icon: Icons.arrow_back_rounded, size: 42, color: BebuTheme.surface, blur: false, onTap: Get.back, tooltip: 'Back'),
              const SizedBox(width: 12),
              Text('Profile photo', style: BebuTheme.title(size: 18)),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            children: [
              PhotoAvatarPicker(presetsMale: d.presetsMale, presetsFemale: d.presetsFemale, allowUpload: d.settings.allowPhotoUpload),
              const SizedBox(height: 20),
              Text('Your picture is shown to hosts on calls and chats. Keep it friendly and clear.', textAlign: TextAlign.center, style: BebuTheme.body(size: 12, color: BebuTheme.textFaint)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Failed extends StatelessWidget {
  const _Failed({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StudioHeader(onBack: Get.back),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 84, height: 84, decoration: BoxDecoration(shape: BoxShape.circle, color: BebuTheme.violet.withValues(alpha: 0.16)), child: Icon(Icons.cloud_off_rounded, size: 36, color: BebuTheme.violet)),
                  const SizedBox(height: 18),
                  Text('Studio is offline', style: BebuTheme.title(size: 18)),
                  const SizedBox(height: 6),
                  Text('Check your connection and try again.', textAlign: TextAlign.center, style: BebuTheme.body(size: 13.5)),
                  const SizedBox(height: 20),
                  GradientButton(label: 'Retry', icon: Icons.refresh_rounded, expanded: false, height: 48, onTap: onRetry),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
