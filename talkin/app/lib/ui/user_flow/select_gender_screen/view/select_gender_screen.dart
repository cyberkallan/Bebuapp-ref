import 'package:flutter/material.dart';
import 'package:talk_in/ui/user_flow/select_gender_screen/widget/select_gender_screen_widget.dart';
import 'package:talk_in/utils/app_color.dart';

class SelectGenderScreen extends StatelessWidget {
  const SelectGenderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      bottomNavigationBar: saveGenderButton(),
      appBar: AppBar(
        backgroundColor: AppColors.lightPurple,
        automaticallyImplyLeading: false,
        flexibleSpace: const SelectGenderScreenAppBar(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectGenderView(),
          ],
        ),
      ),
    );
  }
}
