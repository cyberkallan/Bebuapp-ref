import 'package:flutter/material.dart';
import 'package:talk_in/ui/host_flow/host_setting_screen/widget/host_setting_widget.dart';

class HostSettingScreen extends StatelessWidget {
  const HostSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: const HostSettingScreenAppBar(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            HostSettingView(),
          ],
        ),
      ),
    );
  }
}
