import 'package:flutter/material.dart';
import 'package:talk_in/ui/user_flow/coin_history_screen/widget/coin_history_screen_widget.dart';
import 'package:talk_in/utils/app_color.dart';

class CoinHistoryScreen extends StatelessWidget {
  const CoinHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.lightPurple,
        automaticallyImplyLeading: false,
        flexibleSpace: const CoinHistoryScreenAppBar(),
      ),
      body: Column(
        children: [
          CoinHistoryScreenTabBar(),
          CoinHistoryScreenTabBarScreen(),
        ],
      ),
    );
  }
}
