import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_bar/custom_app_bar.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/ui/user_flow/select_gender_screen/controller/select_gender_screen_controller.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class SelectGenderScreenAppBar extends StatelessWidget {
  const SelectGenderScreenAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(120),
      child: CustomAppBar(
        title: EnumLocale.txtChooseYourGender.name.tr,
        showLeadingIcon: true,
        appBarColor: AppColors.lightPurple,
        // appBarColor: AppColors.purple200.withValues(alpha: 0.1),
      ),
    );
  }
}

class SelectGenderView extends StatelessWidget {
  const SelectGenderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          EnumLocale.txtSelectYourGender.name.tr,
          style: AppFontStyle.fontStyleW700(
            fontSize: 24,
            fontColor: AppColors.black,
          ),
        ).paddingOnly(bottom: 2, top: 18),
        Text(
          EnumLocale.txtIfSelectWrongGenderLifeBan.name.tr,
          style: AppFontStyle.fontStyleW500(
            fontSize: 15,
            fontColor: AppColors.profileText,
          ),
        ).paddingOnly(bottom: 40),
        GetBuilder<SelectGenderScreenController>(
          id: Constant.idGenderSelect,
          builder: (controller) {
            return Row(
              children: List.generate(
                2,
                (index) {
                  bool selected = controller.selectedIndex == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => controller.selectGender(index),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            end: Alignment.bottomCenter,
                            begin: Alignment.topCenter,
                            colors: [
                              Color(0xffF7EFFF).withValues(alpha: 0.20),
                              Color(0xffF7EFFF),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(23),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              height: 20,
                              width: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: selected ? AppColors.transparent : AppColors.grey),
                                color: selected ? Colors.black : AppColors.white,
                              ),
                              child: selected
                                  ? Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.appColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Container(
                                        height: 22,
                                        width: 22,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: AppColors.white),
                                          color: AppColors.appColor,
                                        ),
                                      ).paddingAll(0.5),
                                    )
                                  : null,
                            ).paddingOnly(bottom: 2, right: 10),
                            Center(
                              child: Image.asset(
                                controller.gender[index]['image'],
                                height: 100,
                                width: 100,
                              ).paddingOnly(bottom: 21),
                            ),
                            Center(
                              child: Text(
                                controller.gender[index]['txt'],
                                style: AppFontStyle.fontStyleW600(
                                  fontSize: 15,
                                  fontColor: AppColors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).paddingSymmetric(horizontal: 15),
                    ),
                  );
                },
              ),
            );
          },
        )
      ],
    );
  }
}

GetBuilder<GetxController> saveGenderButton() {
  return GetBuilder<SelectGenderScreenController>(
    builder: (controller) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.10),
              blurRadius: 18,
              offset: Offset(0, 0),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PrimaryAppButton(
              onTap: () {
                Get.back();
              },
              color: AppColors.appColor,
              height: Get.height * 0.056,
              text: EnumLocale.txtSaveGender.name.tr,
              textStyle: AppFontStyle.fontStyleW500(fontSize: 16, fontColor: AppColors.white),
            ).paddingSymmetric(horizontal: 24),
          ],
        ).paddingOnly(top: 10, bottom: 10),
      );
    },
  );
}
