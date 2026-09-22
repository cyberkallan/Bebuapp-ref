import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/motion/coin_burst.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/bottom_bar/controller/bottom_bar_controller.dart';
import 'package:talk_in/ui/user_flow/coin_purchase_screen/widget/coin_purchase_screen_widget.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/utils.dart';

/// Purchase-success celebration: coin burst, count-up, receipt, and a nudge
/// to spend the coins right away.
class CoinPurchaseScreen extends StatelessWidget {
  const CoinPurchaseScreen({super.key});

  void _startTalking() {
    Get.until((r) => r.settings.name == AppRoutes.bottomBar || r.isFirst);
    if (Get.isRegistered<BottomBarController>()) Get.find<BottomBarController>().onClick(1);
  }

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.light);
    final bottom = MediaQuery.paddingOf(context).bottom;
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: BebuTheme.bg,
        body: AuroraBackground(
          intensity: 1.1,
          child: Stack(
            fit: StackFit.expand,
            children: [
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                        children: const [
                          PurchaseHero(),
                          SizedBox(height: 28),
                          PurchaseBalanceCard(),
                          SizedBox(height: 12),
                          PurchaseReceipt(),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 8, 20, bottom + 16),
                      child: FadeSlideIn(
                        delayMs: 1000,
                        child: Column(
                          children: [
                            GradientButton(label: 'Start talking now', icon: Icons.call_rounded, gradient: BebuTheme.pinkGradient, glow: BebuTheme.pink, onTap: _startTalking),
                            const SizedBox(height: 10),
                            GhostButton(label: 'Back to wallet', onTap: Get.back, height: 50),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Two bursts: a fast wide one, then a slower gentle follow-up.
              const CoinBurst(origin: Alignment(0, -0.45), delay: Duration(milliseconds: 260)),
              const CoinBurst(coins: 14, confetti: 30, origin: Alignment(0, -0.5), delay: Duration(milliseconds: 1100), duration: Duration(milliseconds: 3200)),
            ],
          ),
        ),
      ),
    );
  }
}
