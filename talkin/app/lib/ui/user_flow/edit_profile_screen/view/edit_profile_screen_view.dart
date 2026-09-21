import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/edit_profile_screen/widget/edit_profile_screen_widget.dart';
import 'package:talk_in/utils/app_color.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: saveProfileButton(),
      backgroundColor: AppColors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: const EditProfileScreenAppBar(),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
            currentFocus.focusedChild?.unfocus();
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              EditProfileImageView(),
              EditProfileEditInfoView().paddingSymmetric(horizontal: 18),
            ],
          ),
        ),
      ),
    );
  }
}
