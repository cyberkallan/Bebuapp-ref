import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talk_in/custom/dialog/exit_app_dialog.dart';
import 'package:talk_in/custom/listeners/listener_photo_card.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/edit_profile_screen/controller/edit_profile_screen_controller.dart';
import 'package:talk_in/ui/user_flow/home_screen/controller/home_screen_controller.dart';
import 'package:talk_in/ui/user_flow/home_screen/widget/listener_deck.dart';
import 'package:talk_in/utils/app_asset.dart';
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
            const Positioned.fill(child: _AmbientGlow()),
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
                                // leave room for the floating nav bar
                                padding: EdgeInsets.fromLTRB(20, 6, 20, 96 + bottomInset),
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

  @override
  Widget build(BuildContext context) {
    // The legacy header registers this controller; profile edits refresh it.
    Get.put(EditProfileController());
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Row(
        children: [
          GetBuilder<EditProfileController>(
            id: Constant.idProfile,
            builder: (_) => PressScale(
              onTap: () => Get.toNamed(AppRoutes.myProfileScreen)?.then((_) => Utils.onChangeStatusBar(brightness: Brightness.light)),
              child: Container(
                width: 44,
                height: 44,
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
                index: controller.feedIndex,
                onChanged: controller.setFeed,
                segments: const [
                  SegmentItem('For You', Icons.local_fire_department_rounded),
                  SegmentItem('Live', Icons.podcasts_rounded),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          const _CoinPill(),
          const SizedBox(width: 8),
          GlassIconButton(
            icon: Icons.notifications_none_rounded,
            color: BebuTheme.surface,
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
    return GetBuilder<HomeScreenController>(
      id: Constant.idCoinUpdate,
      builder: (controller) {
        final coins = Database.userCoin.toString();
        return PressScale(
          onTap: () => Get.toNamed(AppRoutes.myWalletScreen),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: BebuTheme.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: BebuTheme.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(AppAsset.starCoin, height: 20, width: 20),
                const SizedBox(width: 6),
                controller.isCoinLoading
                    ? Shimmer.fromColors(
                        baseColor: BebuTheme.surface3,
                        highlightColor: BebuTheme.textFaint,
                        child: Container(width: 28, height: 12, decoration: BoxDecoration(color: BebuTheme.surface3, borderRadius: BorderRadius.circular(6))),
                      )
                    : Text(coins, style: BebuTheme.label(size: 14, color: BebuTheme.amber, weight: FontWeight.w700)),
              ],
            ),
          ),
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
