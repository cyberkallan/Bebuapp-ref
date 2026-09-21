import 'package:flutter/material.dart';
import 'package:talk_in/ui/user_flow/setting_screen/widget/setting_widget.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: const SettingScreenAppBar(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SettingView(),
          ],
        ),
      ),
    );
  }
}
