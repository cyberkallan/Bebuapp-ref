import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/ui/user_flow/host_verification_screen/controller/host_verification_controller.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class AllLanguageBottomSheet extends StatefulWidget {
  const AllLanguageBottomSheet({super.key});

  @override
  State<AllLanguageBottomSheet> createState() => _AllLanguageBottomSheetState();
}

class _AllLanguageBottomSheetState extends State<AllLanguageBottomSheet> {
  HostVerificationController controller = Get.put(HostVerificationController());
  @override
  Widget build(BuildContext context) {
    return Container(
        height: Get.height * 0.6,
        padding: EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: GetBuilder<HostVerificationController>(
          builder: (controller) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      EnumLocale.txtSelectLanguage.name.tr,
                      style: AppFontStyle.fontStyleW600(
                        fontSize: 16,
                        fontColor: AppColors.onBoardingTxt,
                      ),
                    ).paddingOnly(bottom: 20, top: 20),
                    GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "Done",
                          style: AppFontStyle.fontStyleW500(fontSize: 14, fontColor: AppColors.onBoardingTxt),
                        ),
                      ),
                    )
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: controller.allLanguages.map((lang) {
                        final isSelected = controller.isSelected(lang);
                        return GestureDetector(
                          onTap: () => controller.toggleLanguage(lang),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected ? AppColors.appColor : AppColors.grey.withValues(alpha: 0.2),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(lang,
                                style: AppFontStyle.fontStyleW500(fontSize: 13, fontColor: isSelected ? AppColors.appColor : AppColors.appTextColor)),
                          ),
                        );
                      }).toList(),
                    ).paddingOnly(bottom: 16),
                  ),
                )
              ],
            );
          },
        ));
  }
}
