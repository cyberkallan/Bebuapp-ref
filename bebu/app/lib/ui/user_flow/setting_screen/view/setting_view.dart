import 'package:flutter/material.dart';
import 'package:talk_in/ui/user_flow/setting_screen/widget/setting_widget.dart';
import 'package:talk_in/utils/app_theme.dart';
import 'package:talk_in/utils/utils.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Utils.onChangeStatusBar(brightness: Brightness.light);
    return Scaffold(
      backgroundColor: BebuTheme.bg,
      body: AuroraBackground(
        intensity: 0.6,
        child: SafeArea(
          child: Column(
            children: [
              const SettingHeaderBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
                  child: const SettingView(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
