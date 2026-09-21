import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/my_wallet_screen/controller/my_wallet_controller.dart';
import 'package:talk_in/ui/user_flow/my_wallet_screen/widget/coin_plan_widget.dart';
import 'package:talk_in/ui/user_flow/my_wallet_screen/widget/my_wallet_screen_widget.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/utils.dart';

class MyWalletScreen extends GetView<MyWalletController> {
  const MyWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.light);
    return Scaffold(
      backgroundColor: BebuTheme.bg,
      extendBody: true,
      body: AuroraBackground(
        intensity: 0.7,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const WalletHeaderBar(),
              Expanded(
                child: RefreshIndicator(
                  color: BebuTheme.pink,
                  backgroundColor: BebuTheme.surface,
                  onRefresh: () => controller.onRefresh(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 150),
                    children: [
                      const WalletBalanceCard(),
                      const SizedBox(height: 26),
                      FadeSlideIn(
                        delayMs: 60,
                        child: const WalletSectionTitle(
                          title: 'Top up coins',
                          subtitle: 'Bigger packs, better price per coin.',
                        ),
                      ),
                      const SizedBox(height: 16),
                      const CoinPlanGrid(),
                      const SizedBox(height: 26),
                      const WalletRecentActivity(),
                      const SizedBox(height: 18),
                      const WalletGuideView(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const WalletCheckoutBar(),
    );
  }
}
