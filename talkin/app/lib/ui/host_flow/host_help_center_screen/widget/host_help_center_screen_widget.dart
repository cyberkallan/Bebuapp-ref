import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/app_bar/custom_app_bar.dart';
import 'package:talk_in/custom/setting_menu_ui/setting_menu.dart';
import 'package:talk_in/ui/host_flow/host_help_center_screen/controller/host_help_center_screen_controller.dart';
import 'package:talk_in/ui/user_flow/help_center_screen/shimmer/help_center_shimmer.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/constant.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';
import 'package:url_launcher/url_launcher.dart';

class HostHelpCenterAppBar extends StatelessWidget {
  const HostHelpCenterAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(120),
      child: CustomAppBar(
        title: EnumLocale.txtHelpCenter.name.tr,
        showLeadingIcon: true,
      ),
    );
  }
}

class HostHelpCenterView extends StatelessWidget {
  const HostHelpCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingMainMenu(
          imageHeight: 75,
          rightSpace: Get.width * 0.012,
          text: EnumLocale.txtNeedAnyHelpFAQ.name.tr,
          subText: EnumLocale.txtHelpCenterDescription.name.tr,
          topImage: AppAsset.helpCenterBlur,
        ).paddingOnly(bottom: 20),
        SettingMenu(
          icon: AppAsset.helpCenterGirl,
          title: EnumLocale.txtHaveAnIssue.name.tr,
          onTap: () async {
            final helpdeskEmail = Database.settingApiModel?.data?.helpdeskEmail ?? '';
            final userEmail = Database.fetchLoginUserProfileModel?.user?.email ?? 'no-reply@yourapp.com';

            if (helpdeskEmail.isEmpty) {
              Get.snackbar("Error", "Helpdesk email not available");
              return;
            }

            final Uri emailUri = Uri(
              scheme: 'mailto',
              path: helpdeskEmail,
              query: Uri.encodeFull(
                'subject=Support Request from $userEmail&body=User Email: $userEmail\n\nPlease describe your issue here.',
              ),
            );

            if (await canLaunchUrl(emailUri)) {
              await launchUrl(emailUri);
            } else {
              Get.snackbar("Error", "Could not open email client");
            }
          },
        ).paddingOnly(bottom: 22),
        Text(
          EnumLocale.txtFrequentlyAskedQuestions.name.tr,
          style: AppFontStyle.fontStyleW700(
            fontSize: 16,
            fontColor: AppColors.black,
          ),
        ).paddingSymmetric(horizontal: 16),
        GetBuilder<HostHelpCenterScreenController>(
          id: Constant.idFAQListeners,
          builder: (controller) {
            return controller.isLoading == true
                ? HelpCenterShimmer()
                : Column(
                    children: List.generate(
                      controller.faqList.length,
                      (index) {
                        final isExpanded = controller.expandedIndex == index;

                        final faqData = controller.faqList[index];
                        return SettingMainMenuListTile(
                          isExpanded: isExpanded,
                          onTap: () => controller.toggleExpansion(index),
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
