import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_bar/custom_app_bar.dart';
import 'package:talk_in/localization/localizations_delegate.dart';
import 'package:talk_in/ui/user_flow/app_language_screen/controller/app_language_screen_controller.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class AppLanguageScreenAppBar extends StatelessWidget {
  const AppLanguageScreenAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(120),
      child: CustomAppBar(
        appBarColor: AppColors.lightPurple,
        title: EnumLocale.txtAPPLanguage.name.tr,
        showLeadingIcon: true,
      ),
    );
  }
}

class AppLanguageScreenView extends StatelessWidget {
  const AppLanguageScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppLanguageScreenController>(
      builder: (logic) {
        return ListView.builder(
          itemCount: Constant.countryList.length,
          shrinkWrap: true,
          physics: AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                logic.onChangeLanguage(languages[index], index);
              },
              child: Container(
                width: Get.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: logic.checkedValue == index ? AppColors.appColor : AppColors.grey.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Center(
                        child: Text(
                          Constant.countryList[index]["code"],
                          style: AppFontStyle.fontStyleW700(
                            fontSize: 20,
                            fontColor: AppColors.black,
                          ),
                        ),
                      ),
                    ).paddingAll(6),
                    Text(
                      Constant.countryList[index]["country"],
                      style: AppFontStyle.fontStyleW600(
                        fontSize: 15,
                        fontColor: logic.checkedValue == index ? AppColors.appColor : AppColors.darkGrey.withValues(alpha: 0.6),
                      ),
                    ),
                    Spacer(),
                    Container(
                      height: 18,
                      width: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: logic.checkedValue == index ? AppColors.transparent : AppColors.grey),
                        color: logic.checkedValue == index ? Colors.black : AppColors.white,
                      ),
                      child: logic.checkedValue == index
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
                    ).paddingOnly(right: 22),
                  ],
                ),
              ).paddingOnly(bottom: 16),
            );
          },
        );
      },
    );
  }
}
