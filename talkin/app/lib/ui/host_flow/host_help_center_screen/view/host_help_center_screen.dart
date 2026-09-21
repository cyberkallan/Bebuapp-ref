import 'package:flutter/material.dart';
import 'package:talk_in/ui/host_flow/host_help_center_screen/widget/host_help_center_screen_widget.dart';

class HostHelpCenterScreen extends StatelessWidget {
  const HostHelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: const HostHelpCenterAppBar(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HostHelpCenterView(),
            ],
          ),
        ),
      ),
    );
  }
}
