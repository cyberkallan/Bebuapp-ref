import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_bar/custom_app_bar.dart';
import 'package:talk_in/custom/setting_menu_ui/setting_menu.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/become_host_screen/controller/become_host_screen_controller.dart';
import 'package:talk_in/ui/user_flow/help_center_screen/shimmer/help_center_shimmer.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class BecomeHostScreenAppBar extends StatelessWidget {
  const BecomeHostScreenAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(120),
      child: CustomAppBar(
        title: EnumLocale.txtBecomeListener.name.tr,
        showLeadingIcon: true,
      ),
    );
  }
}

class BecomeHostScreenView extends StatelessWidget {
  BecomeHostScreenView({super.key});
  final controller = Get.put(BecomeHostScreenController());

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingMainMenu(
          imageHeight: 80,
          rightSpace: Get.width * 0.012,
          text: EnumLocale.txtYouWantToBecomeListener.name.tr,
          subText: EnumLocale.txtBecomeHostDescription.name.tr,
          topImage: AppAsset.becomeHostBlur,
        ).paddingOnly(bottom: 20),
        GetBuilder<BecomeHostScreenController>(
          builder: (controller) {
            return SettingMenu(
              icon: AppAsset.listenersVerification,
              title: controller.listenersRequestCheckModel?.status == true
                  ? EnumLocale.txtListenerVerification.name.tr
                  : EnumLocale.txtBecomeListener.name.tr,
              onTap: () {
                if (controller.listenersRequestCheckModel?.status == true) {
                  Get.toNamed(AppRoutes.hostRequestSentSuccessfullyScreen);
                } else {
                  Get.toNamed(AppRoutes.hostVerificationScreen);
                }
              },
            ).paddingOnly(bottom: 22);
          },
        ),
        Text(
          EnumLocale.txtFrequentlyAskedQuestions.name.tr,
          style: AppFontStyle.fontStyleW700(
            fontSize: 16,
            fontColor: AppColors.black,
          ),
        ).paddingSymmetric(horizontal: 16),
        GetBuilder<BecomeHostScreenController>(
          id: Constant.idFAQListeners,
          builder: (controller) {
            return controller.isLoading == true
                ? HelpCenterShimmer()
                : Column(
                    children: List.generate(
                      controller.faqModel?.data?.length ?? 0,
                      (index) {
                        final isExpanded = controller.expandedIndex == index;

                        final faqData = controller.faqList[index];
                        return SettingMainMenuListTile(
                          isExpanded: isExpanded,
                          onTap: () => controller.toggleExpanded(index),
                          title: "${faqData.question}",
                          subTitle: "${faqData.answer}",
                        ).paddingOnly(top: 22, bottom: 16);
                      },
                    ),
                  );
          },
        ),
      ],
    );
  }
}
