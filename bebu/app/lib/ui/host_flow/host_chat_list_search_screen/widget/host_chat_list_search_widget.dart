import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/host_flow/host_chat_list_search_screen/controller/host_chat_list_search_controller.dart';
import 'package:talk_in/ui/user_flow/chat_screen/widget/chat_screen_widget.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/utils.dart';

class HostChatListSearchWidget extends StatelessWidget {
  const HostChatListSearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            GetBuilder<HostChatListSearchController>(
              builder: (controller) {
                return Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Image.asset(
                          height: 16,
                          AppAsset.backArrowIcon,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              AppAsset.searchIcon,
                              height: 18,
                              width: 18,
                              color: controller.hasText ? AppColors.black : AppColors.otpScreenGrey,
                            ),
                            const SizedBox(width: 12),
                            Container(
                              height: 15,
                              width: 1,
                              color: AppColors.grey.withValues(alpha: 0.4),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: controller.searchController,
                                decoration: InputDecoration(
                                  hintText: EnumLocale.txtSearchPeople.name.tr,
                                  border: InputBorder.none,
                                ),
                                textInputAction: TextInputAction.done,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (controller.hasText) {
                                  controller.clearText();
                                }
                              },
                              child: controller.hasText
                                  ? Image.asset(
                                      AppAsset.closeFillIcon,
                                      height: 22,
                                      width: 22,
                                      color: controller.hasText ? AppColors.profileLanguage.withValues(alpha: 0.5) : AppColors.otpScreenGrey,
                                    )
                                  : SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ).paddingOnly(right: 16),
                    ),
                  ],
                );
              },
            ),
            8.height,
            Expanded(
              child: Container(
                color: AppColors.white,
                child: GetBuilder<HostChatListSearchController>(
                  builder: (controller) {
                    return controller.displayedListeners.isEmpty
                        ? SizedBox(
                            height: Get.height,
                            child: Center(
                              child: Image.asset(
                                AppAsset.noChatFound,
                                height: 250,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: controller.displayedListeners.length,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  SearchChatViewItem(
                                    onTap: () {
                                      Get.toNamed(
                                        AppRoutes.hostPersonalChatScreen,
                                        arguments: [
                                          controller.displayedListeners[index].chatUserId,
                                          controller.displayedListeners[index].fullName,
                                          controller.displayedListeners[index].isOnline,
                                          controller.displayedListeners[index].profilePic,
                                          // controller.displayedListeners[index].ratePrivateAudioCall,
                                          // controller.displayedListeners[index].ratePrivateVideoCall,
                                        ],
                                      );
                                    },
                                    isOnline: controller.displayedListeners[index].isOnline ?? false,
                                    lastMsgTime: controller.displayedListeners[index].messageTime.toString(),
                                    lastMsg: controller.displayedListeners[index].lastMessage ?? '',
                                    index: index,
                                    name: controller.displayedListeners[index].fullName ?? '',
                                    image: controller.displayedListeners[index].profilePic ?? '',
                                  ).paddingOnly(left: 14, right: 14),
                                  controller.displayedListeners.length == 1
                                      ? SizedBox.shrink()
                                      : Divider(
                                          color: AppColors.lightGrey,
                                          height: 0,
                                        ),
                                ],
                              );
                            },
                          );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
