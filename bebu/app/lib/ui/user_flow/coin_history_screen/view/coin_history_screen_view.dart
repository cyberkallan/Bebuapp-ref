import 'package:flutter/material.dart';
import 'package:talk_in/ui/user_flow/coin_history_screen/widget/coin_history_screen_widget.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/utils.dart';

/// Coin movements and payments, grouped by day, with a date-range filter.
class CoinHistoryScreen extends StatelessWidget {
  const CoinHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.light);
    return Scaffold(
      backgroundColor: BebuTheme.bg,
      body: AuroraBackground(
        intensity: 0.6,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: const [
              HistoryHeader(),
              HistoryTabs(),
              Expanded(child: HistoryBody()),
            ],
          ),
        ),
      ),
    );
  }
}
