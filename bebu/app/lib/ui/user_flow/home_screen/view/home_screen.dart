import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/dialog/exit_app_dialog.dart';
import 'package:talk_in/custom/listeners/listener_photo_card.dart';
import 'package:talk_in/custom/motion/coin_pill.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/daily_reward/controller/daily_reward_controller.dart';
import 'package:talk_in/ui/user_flow/daily_reward/view/gift_badge.dart';
import 'package:talk_in/ui/user_flow/edit_profile_screen/controller/edit_profile_screen_controller.dart';
import 'package:talk_in/ui/user_flow/home_screen/controller/home_screen_controller.dart';
import 'package:talk_in/ui/user_flow/home_screen/widget/listener_deck.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/utils.dart';

class HomeScreen extends GetView<HomeScreenController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.light);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Get.dialog(
          barrierColor: AppColors.black.withValues(alpha: 0.8),
          Dialog(
            backgroundColor: AppColors.transparent,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            child: const ExitAppDialog(),
          ),
        );
      },
      child: Scaffold(
        backgroundColor: BebuTheme.bg,
        body: Stack(
          children: [
            if (BebuTheme.ambientGlow) const Positioned.fill(child: _AmbientGlow()),
            SafeArea(
              bottom: false,
              child: RefreshIndicator(
                color: BebuTheme.pink,
                backgroundColor: BebuTheme.surface2,
                onRefresh: () async => controller.onRefresh(),
                notificationPredicate: (n) => n.depth == 0,
                child: LayoutBuilder(
                  builder: (context, c) {
                    final bottomInset = MediaQuery.paddingOf(context).bottom;
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: c.maxHeight,
                        child: Column(
                          children: [
                            const _HomeHeader(),
                            Expanded(
                              child: Padding(
                                // top: room for the two peeking back cards; bottom: floating nav bar
                                padding: EdgeInsets.fromLTRB(20, 30, 20, 96 + bottomInset),
                                child: const ListenerDeck(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  /// Every control in the header shares this height so they line up.
  static const double controlHeight = 42;

  @override
  Widget build(BuildContext context) {
    // The legacy header registers this controller; profile edits refresh it.
    Get.put(EditProfileController());
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Row(
        children: [
          GetBuilder<EditProfileController>(
            id: Constant.idProfile,
            builder: (_) => PressScale(
              onTap: () => Get.toNamed(AppRoutes.myProfileScreen)?.then((_) => Utils.onChangeStatusBar(brightness: Brightness.light)),
              child: Container(
                width: _HomeHeader.controlHeight,
                height: _HomeHeader.controlHeight,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: BebuTheme.borderStrong)),
                child: ClipOval(child: ListenerPhoto(image: Database.loginUserProfilePic, scrim: false)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GetBuilder<HomeScreenController>(
              id: Constant.idGetListener,
              builder: (controller) => SegmentedPill(
                height: _HomeHeader.controlHeight,
                index: controller.feedIndex,
                onChanged: controller.setFeed,
                segments: [
                  SegmentItem('For You', Icons.local_fire_department_rounded, activeColor: BebuTheme.pink),
                  const SegmentItem('Live', Icons.podcasts_rounded, activeColor: BebuTheme.green),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          const _CoinPill(),
          const SizedBox(width: 8),
          GlassIconButton(
            icon: Icons.notifications_none_rounded,
            size: _HomeHeader.controlHeight,
            color: BebuTheme.surface,
            blur: false,
            onTap: () => Get.toNamed(AppRoutes.userNotificationView),
            tooltip: 'Notifications',
          ),
        ],
      ),
    );
  }
}

class _CoinPill extends StatelessWidget {
  const _CoinPill();

  @override
  Widget build(BuildContext context) {
    final rewards = DailyRewardController.to;
    return GetBuilder<DailyRewardController>(
      id: DailyRewardController.idBadge,
      builder: (_) {
        final gift = rewards.canClaim;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            GetBuilder<HomeScreenController>(
              id: Constant.idCoinUpdate,
              builder: (controller) => CoinPill(
                coins: int.tryParse(Database.userCoin) ?? 0,
                loading: controller.isCoinLoading,
                height: _HomeHeader.controlHeight,
                onTap: () => gift ? rewards.open(context) : Get.toNamed(AppRoutes.myWalletScreen),
              ),
            ),
            if (gift) const Positioned(top: -9, left: -8, child: GiftBadge()),
          ],
        );
      },
    );
  }
}

/// Soft coloured glow behind the deck so the dark background has depth.
class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -80,
            child: _blob(BebuTheme.violet.withValues(alpha: 0.22), 320),
          ),
          Positioned(
            bottom: 40,
            left: -120,
            child: _blob(BebuTheme.pink.withValues(alpha: 0.14), 300),
          ),
        ],
      ),
    );
  }

  Widget _blob(Color color, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      );
}
