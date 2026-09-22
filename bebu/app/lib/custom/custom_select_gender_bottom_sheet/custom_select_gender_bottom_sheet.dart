import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_button/primary_app_button.dart';
import 'package:talk_in/ui/user_flow/edit_profile_screen/controller/edit_profile_screen_controller.dart';
import 'package:talk_in/ui/user_flow/fill_profile_screen/controller/fill_profile_screen_controller.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class CustomSelectGenderBottomSheet extends StatelessWidget {
  const CustomSelectGenderBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
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
              GetBuilder<EditProfileController>(
                id: Constant.idGenderSelect,
                // init: controller,
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
          ).paddingOnly(bottom: 30),
          saveGenderButton(),
        ],
      ),
    );
  }

  GetBuilder<EditProfileController> saveGenderButton() {
    return GetBuilder<EditProfileController>(
      builder: (controller) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.10),
                blurRadius: 18,
                offset: Offset(0, 0),
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
                height: 47,
                text: 'txtSaveGender'.tr,
                textStyle: AppFontStyle.fontStyleW500(
                  fontSize: 16,
                  fontColor: AppColors.white,
                ),
              ).paddingSymmetric(horizontal: 24),
            ],
          ).paddingOnly(top: 10, bottom: 10),
        );
      },
    );
  }
}

class CustomEditeProfileSelectGenderBottomSheet extends StatelessWidget {
  const CustomEditeProfileSelectGenderBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
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
              GetBuilder<FillProfileScreenController>(
                id: Constant.idGenderSelect,
                // init: controller,
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
                                      controller.gender[index]['image'] ?? "",
                                      height: 100,
                                      width: 100,
                                    ).paddingOnly(bottom: 21),
                                  ),
                                  Center(
                                    child: Text(
                                      controller.gender[index]['txt'] ?? "Male",
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
          ).paddingOnly(bottom: 30),
          saveGenderButton(),
        ],
      ),
    );
  }

  GetBuilder<FillProfileScreenController> saveGenderButton() {
    return GetBuilder<FillProfileScreenController>(
      builder: (controller) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.10),
                blurRadius: 18,
                offset: Offset(0, 0),
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
                height: 47,
                text: 'txtSaveGender'.tr,
                textStyle: AppFontStyle.fontStyleW500(
                  fontSize: 16,
                  fontColor: AppColors.white,
                ),
              ).paddingSymmetric(horizontal: 24),
            ],
          ).paddingOnly(top: 10, bottom: 10),
        );
      },
    );
  }
}
