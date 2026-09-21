import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talk_in/custom/listeners/recent_listeners.dart';
import 'package:talk_in/routes/app_routes.dart';
import 'package:talk_in/ui/user_flow/search_screen/controller/search_screen_controller.dart';
import 'package:talk_in/ui/user_flow/search_screen/shimmer/search_list_shimmer.dart';
import 'package:talk_in/utils/app_asset.dart';
import 'package:talk_in/utils/app_color.dart';
import 'package:talk_in/utils/database.dart';
import 'package:talk_in/utils/enums.dart';
import 'package:talk_in/utils/font_style.dart';

class SearchTopView extends StatelessWidget {
  const SearchTopView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SearchScreenController>(
      // init: SearchController(),
      builder: (searchController) {
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
                      color: searchController.hasText ? AppColors.black : AppColors.otpScreenGrey,
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
                        controller: searchController.searchController,
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
                        if (searchController.hasText) {
                          searchController.clearText();
                        }
                      },
                      child: searchController.hasText
                          ? Image.asset(
                              AppAsset.closeFillIcon // define this in AppAsset
                              ,
                              height: 22,
                              width: 22,
                              color: searchController.hasText ? AppColors.profileLanguage.withValues(alpha: 0.5) : AppColors.otpScreenGrey,
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
    );
  }
}

class RecentListenersSearchView extends StatelessWidget {
  const RecentListenersSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SearchScreenController>(
      builder: (controller) {
        return Container(
          width: Get.width,
          decoration: BoxDecoration(color: AppColors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                EnumLocale.txtRecentPeople.name.tr,
                style: AppFontStyle.fontStyleW600(
                  fontSize: 18,
                  fontColor: AppColors.black,
                ),
              ).paddingOnly(bottom: 18, top: 18, right: 16, left: 16),
              controller.isLoading
                  ? SearchListShimmer().paddingSymmetric(horizontal: 16)
                  : controller.recentSearchedListeners.isEmpty
                      ? Expanded(
                          child: Center(
                            child: Image.asset(AppAsset.noListenerFound).paddingAll(80),
                          ),
                        )
                      : Expanded(
                          // Only wrap ListView.builder in Expanded
                          child: ListView.builder(
                            itemCount: controller.recentSearchedListeners.length,
                            itemBuilder: (context, index) {
                              final listener = controller.recentSearchedListeners[index];
                              return Column(
                                children: [
                                  RecentListeners(
                                    onTap: () {
                                      Get.toNamed(
                                        AppRoutes.profileDetailScreenView,
                                        arguments: listener.id,
                                      );
                                    },
                                    callCount: listener.callCount.toString(),
                                    language: listener.language?[0].toString() ?? '',
                                    name: listener.name ?? '',
                                    age: listener.age.toString(),
                                    image: listener.image ?? '',
                                    status: listener.statusLabel ?? '',
                                    closIcon: true,
                                    onCloseTap: () async {
                                      final idToRemove = listener.id;
                                      if (idToRemove != null && idToRemove.isNotEmpty) {
                                        List<String> history = Database.searchData;
                                        history.remove(idToRemove);
                                        await Database.onSetSearchDataStore(history);
                                        controller.update(); // Refresh UI
                                      }
                                    },
                                  ),
                                  controller.recentSearchedListeners.length == 1
                                      ? SizedBox.shrink()
                                      : Divider(
                                          color: AppColors.lightGrey,
                                          height: Get.height * 0.04,
                                        ),
                                ],
                              );
                            },
                          ),
                        ),
            ],
          ).paddingOnly(bottom: 18),
        );
      },
    );
  }
}
