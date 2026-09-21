import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/listeners/listener_photo_card.dart';
import 'package:talk_in/custom/motion/coin_pill.dart';
import 'package:talk_in/custom/theme_picker.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/avatar_studio/widget/avatar_stage.dart';
import 'package:talk_in/ui/user_flow/bottom_bar/controller/bottom_bar_controller.dart';
import 'package:talk_in/ui/user_flow/edit_profile_screen/controller/edit_profile_screen_controller.dart';
import 'package:talk_in/ui/user_flow/my_profile_screen/controller/my_profile_screen_controller.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/appearance.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/utils.dart';

/// Back button, title and settings action.
class ProfileHeaderBar extends StatelessWidget {
  const ProfileHeaderBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          GlassIconButton(icon: Icons.arrow_back_rounded, size: 42, color: BebuTheme.surface, blur: false, onTap: Get.back, tooltip: 'Back'),
          const Spacer(),
          Text(EnumLocale.txtMyProfile.name.tr, style: BebuTheme.title(size: 18)),
          const Spacer(),
          GlassIconButton(
            icon: Icons.settings_rounded,
            size: 42,
            iconSize: 19,
            color: BebuTheme.surface,
            blur: false,
            onTap: () => Get.toNamed(AppRoutes.settingScreen),
            tooltip: EnumLocale.txtSettings.name.tr,
          ),
        ],
      ),
    );
  }
}

/// Opens the studio (or photo picker) and refreshes the profile afterwards.
Future<void> openAvatarStudio() async {
  final changed = await Get.toNamed(AppRoutes.avatarStudio);
  if (Get.isRegistered<MyProfileScreenController>()) {
    final c = Get.find<MyProfileScreenController>();
    if (changed == true) {
      await c.refreshProfile();
    } else {
      await c.refreshLook();
    }
  }
}

/// Opens the edit form and refreshes the profile afterwards.
Future<void> openEditProfile() async {
  await Get.toNamed(AppRoutes.editProfileScreen);
  if (Get.isRegistered<MyProfileScreenController>()) await Get.find<MyProfileScreenController>().refreshProfile();
}

/// Who am I: the 3D stage (studio look) or the photo, name, contact and ID,
/// plus the customise / edit actions.
class ProfileHero extends StatelessWidget {
  const ProfileHero({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyProfileScreenController>(
      id: MyProfileScreenController.idLook,
      builder: (c) => GetBuilder<EditProfileController>(
        id: Constant.idProfile,
        builder: (_) {
          final user = Database.fetchLoginUserProfileModel?.user;
          final contact = Database.loginType == 2 ? Database.loginUserNickName : Database.loginUserEmail;
          final uniqueId = user?.uniqueId?.toString() ?? '';
          final name = Database.loginUserName.isEmpty ? (Database.loginUserNickName.isEmpty ? 'bebu user' : Database.loginUserNickName) : Database.loginUserName;
          return FadeSlideIn(
            child: Column(
              children: [
                if (c.hasStudioLook)
                  _StageHero(c: c)
                else
                  _PhotoHero(loading: c.loadingLook, studioEnabled: c.studioEnabled),
                const SizedBox(height: 18),
                Text(name, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: BebuTheme.display(size: 26)),
                if (contact.isNotEmpty && contact != name) ...[
                  const SizedBox(height: 4),
                  Text(contact, maxLines: 1, overflow: TextOverflow.ellipsis, style: BebuTheme.body(size: 13.5)),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    if (uniqueId.isNotEmpty) BebuChip(label: 'ID  $uniqueId', icon: Icons.tag_rounded, dense: true, background: BebuTheme.surface2),
                    BebuChip(label: EnumLocale.txtEditProfile.name.tr, icon: Icons.edit_rounded, dense: true, background: BebuTheme.surface2, onTap: openEditProfile),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// The saved 3D look inside a rounded stage with a "Customize" CTA.
class _StageHero extends StatelessWidget {
  const _StageHero({required this.c});
  final MyProfileScreenController c;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      scale: 0.985,
      onTap: openAvatarStudio,
      child: Container(
        height: 230,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(BebuTheme.radiusXl),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: BebuTheme.isLight ? 0.16 : 0.5), blurRadius: 30, offset: const Offset(0, 14))],
        ),
        child: Stack(
          children: [
            Positioned.fill(child: AvatarStage(look: c.look, interactive: false, compact: true)),
            Positioned(
              left: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(999)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome_rounded, size: 12, color: Colors.white),
                    const SizedBox(width: 5),
                    Text('${c.studio?.unlocked.length ?? 0} premium unlocked', style: BebuTheme.label(size: 10.5, color: Colors.white)),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: GradientButton(label: 'Customize', icon: Icons.brush_rounded, expanded: false, height: 40, onTap: openAvatarStudio),
            ),
          ],
        ),
      ),
    );
  }
}

/// Round photo with gradient ring and the create-avatar / change-photo CTA.
class _PhotoHero extends StatelessWidget {
  const _PhotoHero({required this.loading, required this.studioEnabled});
  final bool loading;
  final bool studioEnabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 124,
              height: 124,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: BebuTheme.pinkGradient,
                boxShadow: [BoxShadow(color: BebuTheme.pink.withValues(alpha: 0.35), blurRadius: 30, offset: const Offset(0, 12))],
              ),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(shape: BoxShape.circle, color: BebuTheme.bg),
                child: ClipOval(child: ListenerPhoto(image: Database.loginUserProfilePic, scrim: false, cacheWidth: 400)),
              ),
            ),
            Positioned(
              bottom: -8,
              child: PressScale(
                onTap: openAvatarStudio,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                  decoration: BoxDecoration(
                    color: BebuTheme.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: BebuTheme.borderStrong),
                    boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 12, offset: Offset(0, 4))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.photo_camera_rounded, size: 13, color: BebuTheme.text),
                      const SizedBox(width: 5),
                      Text('Change', style: BebuTheme.label(size: 11.5)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (studioEnabled && !loading) ...[
          const SizedBox(height: 22),
          PressScale(
            onTap: openAvatarStudio,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(BebuTheme.radiusLg),
                gradient: BebuTheme.violetGradient,
                boxShadow: [BoxShadow(color: BebuTheme.violet.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 10))],
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 54,
                    height: 54,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset('assets/avatar_studio/f_fairy.webp', width: 46, cacheWidth: 138),
                        Positioned(right: 0, bottom: 0, child: Image.asset('assets/avatar_studio/pet_dog.webp', width: 22, cacheWidth: 66)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Create your 3D avatar', style: BebuTheme.title(size: 15, color: BebuTheme.onPhoto)),
                        const SizedBox(height: 2),
                        Text('Pick a look, a pet, a ride and a home. Free to start.', maxLines: 2, style: BebuTheme.body(size: 11.5, color: BebuTheme.onPhotoMuted)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right_rounded, color: BebuTheme.onPhoto),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// "Complete your profile" checklist; disappears once everything is done.
class ProfileCompleteness extends StatelessWidget {
  const ProfileCompleteness({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyProfileScreenController>(
      id: MyProfileScreenController.idStats,
      builder: (c) => GetBuilder<EditProfileController>(
        id: Constant.idProfile,
        builder: (_) {
          final steps = c.steps;
          final pct = c.completeness;
          if (pct >= 1) return const SizedBox.shrink();
          final next = steps.firstWhere((s) => !s.done);
          return Padding(
            padding: const EdgeInsets.only(bottom: 22),
            child: FadeSlideIn(
              delayMs: 40,
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text('Complete your profile', style: BebuTheme.title(size: 15))),
                        Text('${(pct * 100).round()}%', style: BebuTheme.label(size: 13, color: BebuTheme.pink)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: pct),
                        duration: const Duration(milliseconds: 700),
                        curve: BebuTheme.curve,
                        builder: (_, v, __) => LinearProgressIndicator(value: v, minHeight: 7, backgroundColor: BebuTheme.surface2, valueColor: AlwaysStoppedAnimation(BebuTheme.pink)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final s in steps)
                          BebuChip(
                            label: s.label,
                            icon: s.done ? Icons.check_rounded : Icons.add_rounded,
                            dense: true,
                            selected: !s.done && s == next,
                            foreground: s.done ? BebuTheme.textFaint : null,
                            onTap: s.done ? null : (s.studio ? openAvatarStudio : openEditProfile),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Hosts answer complete profiles more often.', style: BebuTheme.body(size: 11.5, color: BebuTheme.textFaint)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Coin balance with recharge and history shortcuts.
class ProfileWalletCard extends StatelessWidget {
  const ProfileWalletCard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Database.fetchLoginUserProfileModel?.user;
    final coins = int.tryParse(Database.userCoin) ?? (user?.coins ?? 0).toInt();
    final spent = (user?.coinsSpent ?? 0).toInt();
    final recharged = (user?.coinsRecharged ?? 0).toInt();
    return FadeSlideIn(
      delayMs: 60,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(BebuTheme.radiusLg),
          gradient: LinearGradient(
            colors: [BebuTheme.amber.withValues(alpha: BebuTheme.isLight ? 0.18 : 0.22), BebuTheme.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: BebuTheme.amber.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Coin balance', style: BebuTheme.body(size: 12.5, color: BebuTheme.textFaint)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          CoinPill(coins: coins, height: 40, onTap: () => Get.toNamed(AppRoutes.myWalletScreen)),
                        ],
                      ),
                    ],
                  ),
                ),
                GradientButton(
                  label: 'Recharge',
                  icon: Icons.add_rounded,
                  expanded: false,
                  height: 44,
                  gradient: const LinearGradient(colors: [Color(0xFFFFC44D), Color(0xFFF08A00)]),
                  glow: BebuTheme.amber,
                  onTap: () => Get.toNamed(AppRoutes.myWalletScreen),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _MiniStat(label: 'Recharged', value: recharged, icon: Icons.south_west_rounded, color: BebuTheme.green),
                const SizedBox(width: 10),
                _MiniStat(label: 'Spent', value: spent, icon: Icons.north_east_rounded, color: BebuTheme.pink),
                const SizedBox(width: 10),
                Expanded(
                  child: PressScale(
                    onTap: () => Get.toNamed(AppRoutes.coinHistoryScreen),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(color: BebuTheme.surface2, borderRadius: BorderRadius.circular(BebuTheme.radiusSm), border: Border.all(color: BebuTheme.border)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_rounded, size: 16, color: BebuTheme.text),
                          const SizedBox(width: 6),
                          Text('History', style: BebuTheme.label(size: 12.5)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, required this.icon, required this.color});
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(color: BebuTheme.surface2, borderRadius: BorderRadius.circular(BebuTheme.radiusSm), border: Border.all(color: BebuTheme.border)),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_short(value), style: BebuTheme.label(size: 13)),
                  Text(label, style: BebuTheme.body(size: 9.5, color: BebuTheme.textFaint, height: 1.1)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _short(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 10000) return '${(n / 1000).toStringAsFixed(0)}K';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

/// System / Dark / Light picker. Hidden when the admin locked the theme.
class ProfileAppearanceSection extends StatelessWidget {
  const ProfileAppearanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Appearance.canChoose) return const SizedBox.shrink();
    return FadeSlideIn(
      delayMs: 100,
      child: ProfileSection(
        title: 'Appearance',
        trailing: Text(Appearance.mode.label, style: BebuTheme.label(size: 12, color: BebuTheme.pink)),
        child: const ThemePicker(compact: true),
      ),
    );
  }
}

/// Pops back to the tab bar and selects the Calls tab.
void _openCallsTab() {
  Get.until((r) => r.settings.name == AppRoutes.bottomBar || r.isFirst);
  if (Get.isRegistered<BottomBarController>()) Get.find<BottomBarController>().onClick(4);
}

/// Four quick shortcuts in a row.
class ProfileQuickActions extends StatelessWidget {
  const ProfileQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.account_balance_wallet_rounded, EnumLocale.txtMyWallet.name.tr, BebuTheme.amber, () => Get.toNamed(AppRoutes.myWalletScreen)),
      (Icons.call_rounded, 'Calls', BebuTheme.green, _openCallsTab),
      (Icons.support_agent_rounded, EnumLocale.txtHelpCenter.name.tr, BebuTheme.blue, () => Get.toNamed(AppRoutes.helpCenterScreen)),
      (Icons.settings_rounded, EnumLocale.txtSettings.name.tr, BebuTheme.violet, () => Get.toNamed(AppRoutes.settingScreen)),
    ];
    return FadeSlideIn(
      delayMs: 140,
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Expanded(
              child: PressScale(
                onTap: items[i].$4,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: BebuTheme.surface,
                    borderRadius: BorderRadius.circular(BebuTheme.radiusMd),
                    border: Border.all(color: BebuTheme.border),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: items[i].$3.withValues(alpha: BebuTheme.isLight ? 0.16 : 0.2)),
                        child: Icon(items[i].$1, size: 20, color: items[i].$3),
                      ),
                      const SizedBox(height: 8),
                      Text(items[i].$2, maxLines: 1, overflow: TextOverflow.ellipsis, style: BebuTheme.label(size: 11.5)),
                    ],
                  ),
                ),
              ),
            ),
            if (i != items.length - 1) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

/// Become-a-host promo, shown when the admin enables it.
class ProfileHostBanner extends StatelessWidget {
  const ProfileHostBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (Database.settingApiModel?.data?.allowBecomeHostOption != true) return const SizedBox.shrink();
    return FadeSlideIn(
      delayMs: 180,
      child: PressScale(
        onTap: () => Get.toNamed(AppRoutes.becomeHostScreen),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(BebuTheme.radiusLg),
            gradient: BebuTheme.violetGradient,
            boxShadow: [BoxShadow(color: BebuTheme.violet.withValues(alpha: 0.35), blurRadius: 26, offset: const Offset(0, 10))],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x33FFFFFF)),
                child: const Icon(Icons.headset_mic_rounded, color: BebuTheme.onPhoto),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(EnumLocale.txtListenersCenter.name.tr, style: BebuTheme.title(size: 16, color: BebuTheme.onPhoto)),
                    const SizedBox(height: 3),
                    Text(EnumLocale.txtHostCenterDescription.name.tr, maxLines: 2, overflow: TextOverflow.ellipsis, style: BebuTheme.body(size: 12, color: BebuTheme.onPhotoMuted)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: BebuTheme.onPhoto, borderRadius: BorderRadius.circular(999)),
                child: Text(EnumLocale.txtBecomeListener.name.tr, style: BebuTheme.label(size: 11, color: BebuTheme.violetDeep)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grouped rows: privacy, share, about, notifications, language.
class ProfileLinks extends StatelessWidget {
  const ProfileLinks({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyProfileScreenController>(
      builder: (controller) => FadeSlideIn(
        delayMs: 220,
        child: ProfileSection(
          title: 'Account',
          child: Column(
            children: [
              ProfileRow(
                icon: Icons.person_outline_rounded,
                color: BebuTheme.pink,
                title: EnumLocale.txtEditProfile.name.tr,
                subtitle: 'Name, birthday, gender, phone',
                onTap: openEditProfile,
              ),
              ProfileRow(
                icon: Icons.notifications_none_rounded,
                color: BebuTheme.amber,
                title: EnumLocale.txtNotification.name.tr,
                subtitle: 'Alerts from callers and bebu',
                onTap: () => Get.toNamed(AppRoutes.userNotificationView),
              ),
              ProfileRow(
                icon: Icons.translate_rounded,
                color: BebuTheme.blue,
                title: EnumLocale.txtLanguage.name.tr,
                subtitle: 'App language',
                onTap: () => Get.toNamed(AppRoutes.appLanguageScreen),
              ),
              ProfileRow(
                icon: Icons.shield_outlined,
                color: BebuTheme.green,
                title: EnumLocale.txtPrivacyCenter.name.tr,
                subtitle: EnumLocale.txtDataPrivacy.name.tr,
                onTap: controller.onClickPrivacyPolicy,
              ),
              ProfileRow(
                icon: Icons.ios_share_rounded,
                color: BebuTheme.violet,
                title: EnumLocale.txtShareApp.name.tr,
                subtitle: EnumLocale.txtShareAppDes.name.tr,
                onTap: controller.onClickShare,
              ),
              ProfileRow(
                icon: Icons.info_outline_rounded,
                color: BebuTheme.amber,
                title: EnumLocale.txtAboutUs.name.tr,
                subtitle: EnumLocale.txtAboutUsDes.name.tr,
                onTap: controller.onClickAboutUs,
                last: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key, required this.title, required this.child, this.trailing});
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
          child: Row(
            children: [
              Text(title, style: BebuTheme.label(size: 12, color: BebuTheme.textFaint)),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
        ),
        child,
      ],
    );
  }
}

class ProfileRow extends StatelessWidget {
  const ProfileRow({super.key, required this.icon, required this.color, required this.title, required this.onTap, this.subtitle, this.last = false});
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      scale: 0.985,
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: last ? 0 : 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(color: BebuTheme.surface, borderRadius: BorderRadius.circular(BebuTheme.radiusMd), border: Border.all(color: BebuTheme.border)),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(BebuTheme.radiusSm), color: color.withValues(alpha: BebuTheme.isLight ? 0.14 : 0.18)),
              child: Icon(icon, size: 19, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: BebuTheme.label(size: 14)),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis, style: BebuTheme.body(size: 11.5, color: BebuTheme.textFaint)),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: BebuTheme.textFaint),
          ],
        ),
      ),
    );
  }
}

/// Version footer.
class ProfileFooter extends StatelessWidget {
  const ProfileFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          Text('bebu', style: BebuTheme.title(size: 15, color: BebuTheme.textFaint)),
          const SizedBox(height: 2),
          Text('Version ${Utils.appVersion}', style: BebuTheme.body(size: 11.5, color: BebuTheme.textFaint)),
        ],
      ),
    );
  }
}
