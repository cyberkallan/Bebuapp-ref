import 'package:flutter/material.dart';
import 'package:talk_in/ui/host_flow/host_withdraw_coin_screen/widget/host_withdraw_coin_widget.dart';
import 'package:talk_in/utils/app_color.dart';

class HostWithdrawCoinScreen extends StatelessWidget {
  const HostWithdrawCoinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPurple,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: const HostWithdrawCoinAppBar(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            HostWithdrawCoinTopView(),
            HostWithdrawCoinView(),
          ],
        ),
      ),
    );
  }
}
