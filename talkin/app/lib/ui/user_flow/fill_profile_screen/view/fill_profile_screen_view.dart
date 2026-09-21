import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/fill_profile_screen/widget/fill_profile_screen_widget.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/utils.dart';

class FillProfileScreen extends StatelessWidget {
  const FillProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Utils.showToast(Get.context!, EnumLocale.txtPleaseFillProfile.name.tr);
        }
      },
      child: Scaffold(
        bottomNavigationBar: saveProfileButton(),
        backgroundColor: AppColors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: const FillProfileScreenAppBar(),
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
                FillProfileImageView(),
                FillProfileEditInfoView().paddingSymmetric(horizontal: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
