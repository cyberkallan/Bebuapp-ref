import 'package:flutter/material.dart';
import 'package:talk_in/ui/host_flow/host_select_gender_screen/widget/host_select_gender_screen_widget.dart';
import 'package:talk_in/utils/app_color.dart';

class HostSelectGenderScreen extends StatelessWidget {
  const HostSelectGenderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      bottomNavigationBar: hostSaveGenderButton(),
      appBar: AppBar(
        backgroundColor: AppColors.lightPurple,
        automaticallyImplyLeading: false,
        flexibleSpace: const HostSelectGenderScreenAppBar(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HostSelectGenderView(),
          ],
        ),
      ),
    );
  }
}
