import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/my_wallet_screen/controller/my_wallet_controller.dart';
import 'package:talk_in/ui/user_flow/my_wallet_screen/widget/coin_plan_widget.dart';
import 'package:talk_in/ui/user_flow/my_wallet_screen/widget/my_wallet_screen_widget.dart';
import 'package:talk_in/utils/app_color.dart';

class MyWalletScreen extends GetView<MyWalletController> {
  const MyWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: GetBuilder<MyWalletController>(builder: (controller) {
        return Column(
          children: [
            MyWalletScreenTopView(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await controller.onRefresh();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      CoinPlanWidget(),
                      WalletGuideView(),

                      // AddCoinBalanceView(),
                    ],
                  ),
                ),
              ),
            )
          ],
        );
      }),
    );
  }
}
