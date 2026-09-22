import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/custom_profile/custom_profile_image.dart';
import 'package:talk_in/custom/motion/coin_3d.dart';
import 'package:talk_in/ui/user_flow/fill_profile_screen/controller/fill_profile_screen_controller.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/utils.dart';

/// First-run profile. Three things we actually need (name, gender, birthday),
/// everything else is optional and one tap away. Pre-filled where we can so the
/// happy path is "glance, confirm, tap".
class FillProfileScreen extends GetView<FillProfileScreenController> {
  const FillProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: BebuTheme.statusBarIcons);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Utils.showToast(Get.context!, EnumLocale.txtPleaseFillProfile.name.tr);
      },
      child: Scaffold(
        backgroundColor: BebuTheme.bg,
        resizeToAvoidBottomInset: true,
        body: AuroraBackground(
          intensity: 0.8,
          child: SafeArea(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(22, 12, 22, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _Progress(),
                          const SizedBox(height: 18),
                          FadeSlideIn(child: Text('Set up your profile', style: BebuTheme.display(size: 28))),
                          const SizedBox(height: 6),
                          FadeSlideIn(
                            child: Text('Takes about 20 seconds. Hosts see your name and photo, nothing else.', style: BebuTheme.body(size: 14.5, color: BebuTheme.textMuted, height: 1.4)),
                          ),
                          const SizedBox(height: 22),
                          const Center(child: _PhotoPicker()),
                          const SizedBox(height: 24),
                          _Field(label: 'Display name', child: const _NameField()),
                          const SizedBox(height: 18),
                          _Field(label: 'I am', child: const _GenderCards()),
                          const SizedBox(height: 18),
                          _Field(label: 'Birthday', hint: 'You must be 18+', child: const _BirthdayTile()),
                          const SizedBox(height: 14),
                          const _CountryRow(),
                        ],
                      ),
                    ),
                  ),
                  const _Footer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Progress extends GetView<FillProfileScreenController> {
  const _Progress();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FillProfileScreenController>(
      id: FillProfileScreenController.idForm,
      builder: (c) {
        final done = c.completedSteps;
        return Row(
          children: [
            Expanded(
              child: Row(
                children: List.generate(3, (i) {
                  final on = i < done;
                  return Expanded(
                    child: AnimatedContainer(
                      duration: BebuTheme.normal,
                      curve: BebuTheme.curve,
                      height: 5,
                      margin: EdgeInsets.only(right: i == 2 ? 0 : 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        gradient: on ? BebuTheme.pinkGradient : null,
                        color: on ? null : BebuTheme.surface3,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(width: 14),
            Text('$done of 3', style: BebuTheme.label(size: 12.5, color: BebuTheme.textMuted)),
          ],
        );
      },
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child, this.hint});
  final String label;
  final String? hint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label.toUpperCase(), style: BebuTheme.label(size: 11.5, color: BebuTheme.textMuted, weight: FontWeight.w700).copyWith(letterSpacing: 1.1)),
            if (hint != null) ...[
              const Spacer(),
              Text(hint!, style: BebuTheme.label(size: 11.5, color: BebuTheme.textFaint)),
            ],
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Photo
// ---------------------------------------------------------------------------

class _PhotoPicker extends GetView<FillProfileScreenController> {
  const _PhotoPicker();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FillProfileScreenController>(
      builder: (c) {
        final photo = c.displayPhoto;
        final isFile = c.pickImage != null && c.pickImage!.isNotEmpty;
        return PressScale(
          onTap: () => c.choosePhoto(context),
          child: SizedBox(
            width: 128,
            height: 128,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 128,
                  height: 128,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: BebuTheme.pinkGradient,
                    boxShadow: [BoxShadow(color: BebuTheme.pink.withValues(alpha: 0.35), blurRadius: 30, offset: const Offset(0, 12))],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: BebuTheme.bg),
                    child: ClipOval(
                      child: photo.isEmpty
                          ? Container(
                              color: BebuTheme.surface2,
                              child: Icon(Icons.person_rounded, size: 64, color: BebuTheme.textFaint),
                            )
                          : isFile
                              ? Image.file(File(photo), fit: BoxFit.cover)
                              : CustomProfileImage(image: photo, fit: BoxFit.cover),
                    ),
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: 2,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: BebuTheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: BebuTheme.bg, width: 3),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Icon(photo.isEmpty ? Icons.add_a_photo_rounded : Icons.edit_rounded, size: 18, color: BebuTheme.text),
                  ),
                ),
                if (photo.isEmpty)
                  Positioned(
                    left: -40,
                    right: -40,
                    bottom: -30,
                    child: Center(child: Text('Add a photo · optional', style: BebuTheme.label(size: 12, color: BebuTheme.textFaint))),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Name
// ---------------------------------------------------------------------------

class _NameField extends GetView<FillProfileScreenController> {
  const _NameField();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FillProfileScreenController>(
      id: FillProfileScreenController.idForm,
      builder: (c) {
        final ok = c.nickNameController.text.trim().length >= 2;
        return Container(
          height: 60,
          decoration: BoxDecoration(
            color: BebuTheme.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(BebuTheme.radiusMd),
            border: Border.all(color: BebuTheme.borderStrong, width: 1.2),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(ok ? Icons.check_circle_rounded : Icons.badge_outlined, size: 20, color: ok ? BebuTheme.green : BebuTheme.textFaint),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: c.nickNameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [LengthLimitingTextInputFormatter(24)],
                  style: BebuTheme.title(size: 18, weight: FontWeight.w700),
                  cursorColor: BebuTheme.pink,
                  decoration: InputDecoration(
                    hintText: 'What should we call you?',
                    hintStyle: BebuTheme.title(size: 16, weight: FontWeight.w500, color: BebuTheme.textFaint),
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                ),
              ),
              Tooltip(
                message: 'Suggest a name',
                child: PressScale(
                  onTap: c.shuffleName,
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(color: BebuTheme.surface2, shape: BoxShape.circle),
                    child: Icon(Icons.casino_rounded, size: 20, color: BebuTheme.pink),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Gender
// ---------------------------------------------------------------------------

class _GenderCards extends GetView<FillProfileScreenController> {
  const _GenderCards();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FillProfileScreenController>(
      id: Constant.idGenderSelect,
      builder: (c) {
        return Row(
          children: [
            Expanded(child: _GenderCard(label: EnumLocale.txtMale.name.tr, asset: AppAsset.maleImage, icon: Icons.male_rounded, selected: c.selectedIndex == 0, onTap: () => c.selectGender(0))),
            const SizedBox(width: 12),
            Expanded(child: _GenderCard(label: EnumLocale.txtFemale.name.tr, asset: AppAsset.femaleImage, icon: Icons.female_rounded, selected: c.selectedIndex == 1, onTap: () => c.selectGender(1))),
          ],
        );
      },
    );
  }
}

class _GenderCard extends StatelessWidget {
  const _GenderCard({required this.label, required this.asset, required this.icon, required this.selected, required this.onTap});
  final String label;
  final String asset;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: BebuTheme.normal,
        curve: BebuTheme.curve,
        height: 84,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? BebuTheme.pink.withValues(alpha: BebuTheme.isLight ? 0.08 : 0.16) : BebuTheme.surface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(BebuTheme.radiusMd),
          border: Border.all(color: selected ? BebuTheme.pink : BebuTheme.borderStrong, width: selected ? 1.6 : 1.2),
          boxShadow: selected ? [BoxShadow(color: BebuTheme.pink.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 8))] : null,
        ),
        child: Row(
          children: [
            AnimatedScale(
              duration: BebuTheme.normal,
              curve: Curves.easeOutBack,
              scale: selected ? 1.08 : 1,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(shape: BoxShape.circle, color: BebuTheme.surface2),
                child: ClipOval(child: Image.asset(asset, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(icon, color: BebuTheme.pink))),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(label, maxLines: 1, style: BebuTheme.label(size: 15.5, weight: FontWeight.w700)))),
            const SizedBox(width: 6),
            AnimatedSwitcher(
              duration: BebuTheme.fast,
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: selected
                  ? Icon(Icons.check_circle_rounded, key: const ValueKey('on'), size: 22, color: BebuTheme.pink)
                  : Icon(Icons.circle_outlined, key: const ValueKey('off'), size: 22, color: BebuTheme.borderStrong),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Birthday
// ---------------------------------------------------------------------------

class _BirthdayTile extends GetView<FillProfileScreenController> {
  const _BirthdayTile();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FillProfileScreenController>(
      builder: (c) {
        final has = c.birthDate != null;
        return PressScale(
          onTap: () => c.selectDate(context),
          child: AnimatedContainer(
            duration: BebuTheme.normal,
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: BebuTheme.surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(BebuTheme.radiusMd),
              border: Border.all(color: has ? BebuTheme.green.withValues(alpha: 0.7) : BebuTheme.borderStrong, width: 1.2),
            ),
            child: Row(
              children: [
                Icon(has ? Icons.check_circle_rounded : Icons.cake_outlined, size: 20, color: has ? BebuTheme.green : BebuTheme.textFaint),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    has ? c.dateController.text : 'Pick your birthday',
                    style: has ? BebuTheme.title(size: 17, weight: FontWeight.w700) : BebuTheme.title(size: 16, weight: FontWeight.w500, color: BebuTheme.textFaint),
                  ),
                ),
                if (has && c.age != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: BebuTheme.green.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(999)),
                    child: Text('${c.age} yrs', style: BebuTheme.label(size: 12, color: BebuTheme.green, weight: FontWeight.w700)),
                  )
                else
                  Icon(Icons.chevron_right_rounded, color: BebuTheme.textFaint),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Country (auto-detected, quiet row)
// ---------------------------------------------------------------------------

class _CountryRow extends GetView<FillProfileScreenController> {
  const _CountryRow();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FillProfileScreenController>(
      id: Constant.idChangeCountry,
      builder: (c) {
        final name = c.countryController.text;
        return PressScale(
          onTap: () => c.onChangeCountry(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Row(
              children: [
                Text(c.flagController.text.isEmpty ? '🌐' : c.flagController.text, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: BebuTheme.label(size: 13, color: BebuTheme.textMuted, weight: FontWeight.w500),
                      children: [
                        const TextSpan(text: 'Country  '),
                        TextSpan(text: name.isEmpty ? 'Not set' : name, style: BebuTheme.label(size: 13, weight: FontWeight.w700)),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text('Change', style: BebuTheme.label(size: 13, color: BebuTheme.pink, weight: FontWeight.w700)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Footer: CTA + welcome bonus reminder
// ---------------------------------------------------------------------------

class _Footer extends GetView<FillProfileScreenController> {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FillProfileScreenController>(
      id: FillProfileScreenController.idForm,
      builder: (c) {
        final coins = c.welcomeCoins;
        final ready = c.canSubmit;
        return Container(
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [BebuTheme.bg.withValues(alpha: 0), BebuTheme.bg]),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (coins > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SpinningCoin(size: 20),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text.rich(
                          TextSpan(
                            style: BebuTheme.label(size: 13, color: BebuTheme.textMuted, weight: FontWeight.w500),
                            children: [
                              TextSpan(text: '$coins free coins', style: BebuTheme.label(size: 13, color: BebuTheme.amber, weight: FontWeight.w800)),
                              TextSpan(text: ready ? ' unlock when you continue' : ' waiting for you'),
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              GradientButton(
                label: ready ? 'Start exploring' : 'Finish the 3 steps above',
                icon: ready ? Icons.arrow_forward_rounded : null,
                gradient: BebuTheme.pinkGradient,
                glow: BebuTheme.pink,
                height: 58,
                onTap: ready ? c.onSaveProfile : null,
              ),
            ],
          ),
        );
      },
    );
  }
}
